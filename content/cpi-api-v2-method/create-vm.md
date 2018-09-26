# create_vm

Creates a new VM based on the stemcell. Created VM must be powered on and accessible on the provided networks.

Waiting for the VM to finish booting is not required because the Director waits until the Agent on the VM responds back.

Make sure to properly delete created resources if VM cannot be successfully created.


## Arguments

 * `agent_id` [String]: ID selected by the Director for the VM's agent.
 * `stemcell_cid` [String]: Cloud ID of the stemcell to use as a base image for new VM.
 * `cloud_properties` [Hash]: Cloud properties hash specified in the deployment manifest under VM's resource pool.
 * `networks` [Hash]: Networks hash that specifies which VM networks must be configured.
 * `disk_cids` [Array of strings] Array of disk cloud IDs for each disk that created VM will most _likely_ be attached; they could be used to optimize VM placement so that disks are located nearby.
 * `environment` [Hash]: Resource pool's env hash specified in deployment manifest including initial properties added by the BOSH director as shown below.


## Result

* Array of results
   * `vm_cid` [String]: Cloud ID of the created VM.
   * `networks` [Hash]: Networks associated with the VM.

## Agent Settings

For the Agent to successfully start on the created VM, several bootstrapping settings must be exposed which include network configuration, message bus location (NATS/HTTPS), agent id, etc. Each infrastructure might have a different way of providing such settings to the Agent. For example AWS CPI uses instance user metadata and BOSH Registry. vSphere CPI uses CDROM drive. Most CPIs choose to communicate with default Agent hence communication settings follow certain format:

```yaml
{
  "agent_id": "4149ba0f-38d9-4485-476f-1581be36f290",

  "vm": { "name": "i-347844" },

  "networks": {
    "private": {
      "type": "manual",
      "netmask": "255.255.255.0",
      "gateway": "10.230.13.1",
      "ip": "10.230.13.6",
      "default": [ "dns", "gateway" ],
      "cloud_properties": { "net_id": "d29fdb0d-44d8-4e04-818d-5b03888f8eaa" }
    },
    "public": {
      "type": "vip",
      "ip": "173.101.112.104",
      "cloud_properties": {}
    }
  },

  "disks": {
    "system": "/dev/sda",
    "ephemeral": "/dev/sdb",
    "persistent": {}
  },

  "mbus": "https://mbus:mbus-password@0.0.0.0:6868"

  "ntp": [ "0.pool.ntp.org", "1.pool.ntp.org" ],

  "blobstore": {
    "provider": "local",
    "options": { "blobstore_path": "/var/vcap/micro_bosh/data/cache" }
  },

  "env": {},

  "context": {
    "director_uuid": "<director-uuid>",
    "request_id": "<cpi-request-id>",
    "vm": {
      "stemcell": {
        "api_version": 2
      }
    }
  },
  
  "api_version": 2
}
```

See [Agent Configuration](../vm-config.md#agent) for an overview of the Agent configuration file locations.


## Examples


### API Request

```json
[
  "4149ba0f-38d9-4485-476f-1581be36f290",
  "ami-478585",
  { "instance_type": "m1.small" },
  {
    "private": {
      "type": "manual",
      "netmask": "255.255.255.0",
      "gateway": "10.230.13.1",
      "ip": "10.230.13.6",
      "default": [ "dns", "gateway" ],
      "cloud_properties": { "net_id": "subnet-48rt54" }
      },
      "private2": {
      "type": "dynamic",
      "cloud_properties": { "net_id": "subnet-e12364" }
    },
    "public": {
      "type": "vip",
      "ip": "173.101.112.104",
      "cloud_properties": {}
    }
  },
  [ "vol-3475945" ],
  {
    "bosh": {
      "group": "my-group",
      "groups": [
        "my-second-group",
        "another-group"
      ]
    }
  }
]
```

### API response

Response:

```json
{
  "result": [
    "<instance-id>",
    { //networks
      "private": {
        "type": "manual",
        "netmask": "255.255.255.0",
        "gateway": "10.230.13.1",
        "ip": "10.230.13.6",
        "default": [ "dns", "gateway" ],
        "cloud_properties": { "net_id": "subnet-48rt54" }
        },
        "private2": {
        "type": "dynamic",
        "cloud_properties": { "net_id": "subnet-e12364" }
      },
      "public": {
        "type": "vip",
        "ip": "173.101.112.104",
        "cloud_properties": {}
      }
    }
  ],
  "error": null,
  "log": ""
}

### Implementations

 * [cppforlife/bosh-warden-cpi-release](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/create_vm.go)


## Related

 * [delete_vm](delete-vm.md)
