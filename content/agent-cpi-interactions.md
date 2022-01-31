Here is an overview of the interactions between the CPI and the Agent on CloudStack as an example:

* The CPI drives the IaaS and the Agent.
* The Agent is a versatile process which configures the OS to leverage IaaS-provisioned resources (network interfaces, disks, etc.), and perform other BOSH tasks (job compilation, job instantiation, etc.)
* The CPI asks the IaaS to instantiate VM template, VMs, volumes and possibly other constructs (floating IPs, security groups, connect LBs, etc.)
* The director-to-agent communication happens through NATS-based messaging.
* The initial configuration of the agent is done via the metadata server.


The following sequence diagram illustrates in more detail the CPI, and agent interactions,
in the case of the [CloudStack CPI](https://github.com/cloudfoundry-community/bosh-cloudstack-cpi-release):

![image](images/cpi-sequence-diag.png)

<!--
Image source in plantuml format.
syntax at http://plantuml.com/sequence.html
Render it online http://plantuml.com/plantuml/ or from a private plantuml instance, see  http://plantuml.com/running.html

@startuml
  box "DIRECTOR"
	participant director
  end box
  box "CPI" #LightBlue
	participant cpi
  end box
  box "CLOUDSTACK"
	participant cloudstack_api
	participant vrouter
  end box
  box "VM" #LightBlue
	participant vm
	participant bosh_agent
  end box

  director -> cpi : create_vm;
  activate cpi
  cpi -> cloudstack_api : create vm \nand set user-data
  activate cloudstack_api

  cloudstack_api -> vrouter : set user data\nin metadata\n service
  activate vrouter
  deactivate vrouter
  cloudstack_api -> vm : provision vm

  activate vm
  vm -> bosh_agent : vm boostraps in dhcp,\nbosh-agent starts \n (reading agent.json)
  activate bosh_agent
  cloudstack_api <- vm
  deactivate vm
  cpi <- cloudstack_api : vm state active
  deactivate cloudstack_api

  director <- cpi
  deactivate cpi

  bosh_agent -> vrouter : query metadata server:\nget agent settings from user data
  activate vrouter
  bosh_agent <- vrouter
  deactivate vrouter
  bosh_agent -> vm : reconfigure network static ip
  activate vm
  deactivate vm
  bosh_agent -> vm : mount and partition ephemeral disk
  activate vm
  deactivate vm


  deactivate bosh_agent

  hide footbox
@enduml
-->

---
## Agent settings {: #agent-settings}

This section details the configuration and protocols supported by the Agent.

[VM Configuration Locations](vm-config.html#agent) provides a list of Agent configuration files and their roles.

---
### `agent.json` file {: #agent-json }

`/var/vcap/bosh/agent.json`: Start up settings for the Agent that describe how to find bootstrap settings, and disable certain Agent functionality.

The loading agent.json file is described into [config_test.go](https://github.com/cloudfoundry/bosh-agent/blob/master/app/config_test.go)

The Platform part of the file is documented into [LinuxOptions](https://godoc.org/github.com/cloudfoundry/bosh-agent/platform#LinuxOptions)

The Infrastructure part of the file is documented into [Options](https://godoc.org/github.com/cloudfoundry/bosh-agent/infrastructure#Options) and in particular:

 * the sources of configuration with [SettingsOptions](https://godoc.org/github.com/cloudfoundry/bosh-agent/infrastructure#SettingsOptions):

    * [CDROM](https://godoc.org/github.com/cloudfoundry/bosh-agent/infrastructure#CDROMSourceOptions)
    * [ConfigDrive](https://godoc.org/github.com/cloudfoundry/bosh-agent/infrastructure#ConfigDriveSourceOptions)
    * [HTTP](https://godoc.org/github.com/cloudfoundry/bosh-agent/infrastructure#HTTPSourceOptions)

Sample `agent.json` which configures the agent to read from an HTTP metadata service at a custom URL:

```json
{
  "Platform": {
    "Linux": {
      "CreatePartitionIfNoEphemeralDisk": true,
      "DevicePathResolutionType": "virtio"
    }
  },
  "Infrastructure": {
    "NetworkingType": "static",
    "Settings": {
      "Sources": [
        {
          "Type": "HTTP",
          "URI": "http://10.234.228.142"
        }
      ],
      "UseServerName": true,
    }
  }
}
```

Sample `agent.json` which configures the agent to read from a config drive. See [reference sample config-drive json](https://github.com/cloudfoundry/bosh-agent/blob/cecf354d90f6cedf540799fb50395adb034b16d2/integration/assets/config-drive-agent.json). See [config drive integration test](https://github.com/cloudfoundry/bosh-agent/blob/cecf354d90f6cedf540799fb50395adb034b16d2/integration/config_drive_test.go):

```json
{
  "Platform": {
    "Linux": {
      "UseDefaultTmpDir": true,
      "UsePreformattedPersistentDisk": true,
      "BindMountPersistentDisk": false,
      "DevicePathResolutionType": "virtio"
    }
  },
  "Infrastructure": {
    "Settings": {
      "Sources": [
        {
          "Type": "ConfigDrive",
          "DiskPaths": [
            "/dev/disk/by-label/CONFIG-2",
            "/dev/disk/by-label/config-2"
          ],
          "MetaDataPath": "ec2/latest/meta-data.json",
          "UserDataPath": "ec2/latest/user-data.json"
        }
      ],

      "UseServerName": true,
    }
  }
}
```

---
### Agent settings format {: #agent-settings-format}

The current state of the JSON settings format supported by the Agent is documented in [settings_test.go](https://github.com/cloudfoundry/bosh-agent/blob/master/settings/settings_test.go) as well as in [settings_test.go](https://github.com/cloudfoundry/bosh-agent/blob/master/settings/settings.go).

Some of the properties (for example `blobstore` or `mbus` URLs) can be specified in multiple
places. In general the properties in the `env` section have precedence over the properties defined on
root level.

Sample settings JSON:

```json
{
  "agent_id": "agent-xxxxx",
  "blobstore": { },
  "disks": {
    "ephemeral": "/dev/sdb",
    "persistent": {},
    "raw_ephemeral": null,
    "system": "/dev/xvda"
  },
  "env": {
    "bosh": {
      "authorized_keys": [
        "--AUTHORIZED KEY--"
      ],
      "blobstores": [
        {
          "provider": "local",
          "options": {
            "endpoint": "http://xx.xx.xx.xx:25250",
            "password": "password",
            "blobstore_path": "/var/vcap/micro_bosh/data/cache",
            "user": "agent"
          }
        }
      ],
      "ipv6": {
        "enable": false
      },
      "keep_root_password": true,
      "mbus": {
        "cert": {
          "ca": "--MBUS CA--",
          "certificate": "--MBUS CERT--",
          "private_key": "--MBUS PRIVATE KEY--"
        },
        "urls": [
          "nats://nats:nats-password@yy.yy.yyy:4222"
        ]
      },
      "ntp": [],
      "parallel": 1,
      "password": "*",
      "remove_dev_tools": false,
      "remove_static_libraries": false,
      "swap_size": 8192
    },
    "persistent_disk_fs": "",
    "persistent_disk_mount_options": null,
    "persistent_disk_partitioner": ""
  },
  "mbus": "nats://nats:nats-password@yy.yy.yyy:4222",
  "networks": {
    "default": {
      "default": [
        "dns",
        "gateway"
      ],
      "dns": [
        "8.8.8.8"
      ],
      "gateway": "10.0.1.1",
      "ip": "10.0.1.6",
      "mac": "aa:aa:aa:aa:aa:aa",
      "netmask": "255.255.255.0",
      "preconfigured": false,
      "resolved": false,
      "type": "manual",
      "use_dhcp": true
    }
  },
  "ntp": [],
  "vm": {
    "name": "vm-yyyy"
  }
}
```

----
### settings.json file {: #settings-json }

`/var/vcap/bosh/settings.json`: Local copy of the bootstrap settings used by the Agent to configure network and system properties for the VM. They are refreshed every time Agent is restarted.

The `settings.json` format is the same as the settings format initially transferred to the agent.

---
### Agent settings source {: #agent-settings-source}
The agent settings as described above are transferred to the agent
using the underlying IaaS Metadata functionality.
