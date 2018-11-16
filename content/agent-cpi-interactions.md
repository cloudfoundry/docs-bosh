Here is an overview of the interactions between the CPI and the Agent on CloudStack as an example:

* The CPI drives the IaaS and the Agent.
* The Agent is a versatile process which configures the OS to leverage IaaS-provisioned resources (network interfaces, disks, etc.), and perform other BOSH tasks (job compilation, job instantiation, etc.)
* The CPI asks the IaaS to instantiate VM template, VMs, volumes and possibly other constructs (floating IPs, security groups, connect LBs, etc.)
* The Agent is initially driven by the CPI through the bosh-registry, and then by the Director through NATS-based messaging. The registry provides Director-side metadata to the Agent.

![image](images/cpi-interactions-overview.png)

<!--
Image source in Saas (no need to own an OmniGraffle license and run MacOS)
https://www.gliffy.com/go/html5/9205487?toke=&app=1b5094b0-6042-11e2-bcfd-0800200c9a66&dev=false
-->

The following sequence diagram illustrates in more detail the CPI, agent, and registry interactions,
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
    participant bosh_registry
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
  cpi -> cloudstack_api : create vm \nand set user-data;
  cpi -> bosh_registry : feed bosh registry: \n(networking, root+eph disks, \nbosh nats, blobstore
  cloudstack_api -> vrouter : set user data\nin metadata\n service;
  cloudstack_api -> vm : provision vm;
  activate vm
  vm -> bosh_agent : vm boostraps in dhcp,\nbosh-agent starts \n (reading agent.json);
  bosh_agent -> vrouter : query metadata server:\nget bosh_registry address from user data;
  bosh_agent -> bosh_registry : gets bootstrap info, ip adress and disks;
  bosh_agent -> vm : reconfigure network static ip;
  bosh_agent -> vm : mount and partition ephemeral disk;


  hide footbox
@enduml
-->

---
## Agent config file formats {: #agent-config }

This section details the configuration and protocols supported by the Agent.

[VM Configuration Locations](vm-config.html#agent) provides a list of Agent configuration files and their roles.

----
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
      "UseRegistry": true
    }
  }
}
```

Sample `agent.json` which configures the agent ot read from a config drive. See [reference sample config-drive json](https://github.com/cloudfoundry/bosh-agent/blob/cecf354d90f6cedf540799fb50395adb034b16d2/integration/assets/config-drive-agent.json). See [config drive integration test](https://github.com/cloudfoundry/bosh-agent/blob/cecf354d90f6cedf540799fb50395adb034b16d2/integration/config_drive_test.go):

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
      "UseRegistry": true
    }
  }
}
```

----
### Metadata server {: #metadata }

The metadata server initially serves the registry URL and DNS server list.

Following is a sample content of the user-data part of the HTTP metadata

```json
{
  "server": {"name": "vm-384sd4-r7re9e"},
  "registry": {"endpoint": "http://192.168.0.255:8080/client/api"},
  "dns": {"nameserver": ["10.234.50.180"]}
}
```

The supported format of the metadata server by the bosh-agent is documented in [UserDataContentsType](https://godoc.org/github.com/cloudfoundry/bosh-agent/infrastructure#UserDataContentsType) and [http\_metadata\_service_test.go](https://github.com/cloudfoundry/bosh-agent/blob/1dca3244702c18bf2c36483c529d4e7b3fb92b2e/infrastructure/http_metadata_service_test.go), along with the expected behavior of the bosh agent when reading this config.

----
### Registry {: #registry }

The registry provides bosh-side metadata to the bosh agent.

From the [Warden CPI documentation](https://github.com/cppforlife/bosh-warden-cpi-release/blob/be1869737c0bfba96662dde3499c9181863f91a7/docs/bosh-micro-usage.md):

* The registry is used by the CPI to pass data to the Agent. The registry is started on a server specified by registry properties.
* If SSH tunnel options are provided, a reverse ssh tunnel is created from the MicroBOSH VM to the registry, making the registry available to the agent on remote machine.

#### Registry HTTP protocol {: #registry-protocol }

The Agent expects to communicate with the bosh registry over a REST API documented in [api\_controller\_spec.rb](https://github.com/cloudfoundry/bosh/blob/2f73281f1a2a155ee807e7c0c9b8187c5a742f78/bosh-registry/spec/unit/bosh/registry/api_controller_spec.rb)

Reference registry client and servers implementations are available in:

* go-lang through [frodenas/bosh-registry](https://github.com/frodenas/bosh-registry)
* java through [cloudfoundry-community/bosh-cloudstack-cpi-core](https://github.com/cloudfoundry-community/bosh-cloudstack-cpi-core/tree/44d14a5f184d2d5e8f1f2fcd6344e734d3344673/src/main/java/com/orange/oss/cloudfoundry/cscpi/boshregistry)

#### Registry settings format {: #registry-format }

The JSON payload of the settings stored in the registry, and its format supported by the Agent are documented in [settings_test.go](https://github.com/cloudfoundry/bosh-agent/blob/ebf9a36dfddf783ffae5ae3748787d259a29374a/settings/settings_test.go)

Sample registry content:

```json
{
  "agent_id": "agent-xxxxxx",
  "blobstore": {
    "provider": "local",
    "options": {
      "endpoint": "http://xx.xx.xx.xx:25250",
      "password": "password",
      "blobstore_path": "/var/vcap/micro_bosh/data/cache",
      "user": "agent"
    }
  },
  "disks": {
    "system": "/dev/xvda",
    "ephemeral": "/dev/sdb",
    "persistent": {}
  },
  "env": {},
  "networks": {
    "default": {
      "type": "manual",
      "ip": "10.234.228.158",
      "netmask": "255.255.255.192",
      "cloud_properties": {"name": "3112 - preprod - back"},
      "dns": [
        "10.234.50.180",
        "10.234.71.124"
      ],
      "gateway": "10.234.228.129",
      "mac": null
    }
  },
  "ntp": [],
  "mbus": "nats://nats:nats-password@yy.yy.yyy:4222",
  "vm": {"name": "vm-yyyy"},
  "trusted_certs": null
}
```

----
### settings.json file {: #settings_json }

`/var/vcap/bosh/settings.json`: Local copy of the bootstrap settings used by the Agent to configure network and system properties for the VM. They are refreshed every time Agent is restarted.

The `settings.json` payload format is the same as the settings format initially returned by the registry.
