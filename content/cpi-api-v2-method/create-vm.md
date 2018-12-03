# create_vm

Creates a new VM based on the stemcell. The newly created VM must be powered on and accessible on the provided networks.

Waiting for the VM to finish booting is not required because the Director waits until the Agent on the VM responds back.

If the VM's creation fails, please make sure to properly delete the associated resources.

As of V2 of the CPI API contract, `create_vm` returns an array of the resultant instance ID and the networks associated with the VM.


## Arguments

 * `agent_id` [String]: ID selected by the Director for the VM's agent.
 * `stemcell_cid` [String]: Cloud ID of the stemcell to use as a base image for new VM.
 * `cloud_properties` [Hash]: Cloud properties hash specified in the deployment manifest under the VM's resource pool.
 * `networks` [Hash]: Networks hash that specifies which VM networks must be configured.
 * `disk_cids` [Array of strings] Array of disk cloud IDs for the disks that the created VM will most _likely_ attach. The disk cloud IDs could be used to optimize VM placement so that disks are located nearby.
 * `environment` [Hash]: Resource pool's env hash specified in the deployment manifest, including initial properties added by the BOSH director as shown below. It gets passed by the CPI to the agent where it can be found in the user data's `env` hash in `/var/vcap/bosh/settings.json`. Additionally, the director will append the following guaranteed values:
     * `bosh` [Hash]: A collection of properties used by the BOSH Agent, and optionally the CPI.
         * `group` [String]: A description of the requested VM in the format `<director-name>-<deployment-name>-<job-name>`.
         * `groups` [Array]: A collection of descriptions for the requested VM, combining `director-name`, `deployment-name` and `job-name` in a range of strings separated by a `-`.


## Result

* Array of results
   * `vm_cid` [String]: Cloud ID of the created VM.
   * `networks` [Hash]: Networks associated with the VM.

## Agent Settings

For the Agent to successfully start on the created VM, several bootstrapping settings must be exposed which include network configuration, message bus location (NATS/HTTPS), agent id, etc. Each infrastructure might have a different way of providing such settings to the Agent. For example AWS CPI uses instance user metadata and potentially the BOSH Registry. vSphere CPI uses CDROM drive.

As of CPI V2, the registry may be avoided if the stemcell API version is sufficient. See [CPI API V2](../cpi-api-v2.md) and [CPI V2 Migration Guide](../v2-migration-guide.md) for more information on how the CPI, Agent, and Director behave in a registry-less environment.

Most CPIs choose to communicate with the default Agent. Hence, the communication settings follow a certain format:

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
  "ntp": null,
  "mbus": "",
  "blobstore": {
    "provider": "",
    "options": {}
  },
  "env": {
    "bosh": {
      "password": "",
      "keep_root_password": false,
      "remove_dev_tools": false,
      "remove_static_libraries": false,
      "authorized_keys": null,
      "swap_size": null,
      "blobstores": [
        {
          "provider": "local",
          "options": {
            "blobstore_path": "/var/vcap/micro_bosh/data/cache"
          }
        }
      ],
      "mbus": {
        "cert": {
          "ca": "-----BEGIN CERTIFICATE---- ... -----END CERTIFICATE-----",
          "certificate": "-----BEGIN RSA PRIVATE KEY----- ... -----END RSA PRIVATE KEY-----",
          "private_key": "-----BEGIN CERTIFICATE---- ... -----END CERTIFICATE-----"
        },
        "urls": [
          "https://mbus:mbus-password@0.0.0.0:6868"
        ]
      },
      "ipv6": {
        "enable": false
      },
      "job_dir": {
        "tmpfs": false,
        "tmpfs_size": "",
      },
      "ntp": [
        "0.pool.ntp.org",
        "1.pool.ntp.org"
      ],
      "parallel": null
    }
  }
}
```

See [Agent Configuration](../vm-config.md#agent) for an overview of the Agent configuration file locations.


## Examples


### API Request

```json
{
  "method": "create_vm",
  "arguments": [
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
        "blobstores": [
          {
            "options": {
              "endpoint": "http://10.0.1.10:25250",
              "password": "<pwd>",
              "tls": {
                "cert": {
                  "ca": "-----BEGIN CERTIFICATE----- ... -----END CERTIFICATE-----"
                }
              },
              "user": "agent"
            },
            "provider": "dav"
          }
        ],
        "mbus": {
          "cert": {
            "ca": "-----BEGIN CERTIFICATE----- ... -----END CERTIFICATE-----",
            "certificate": "-----BEGIN CERTIFICATE----- ... -----END CERTIFICATE-----",
            "private_key": "-----BEGIN RSA PRIVATE KEY----- ... -----END RSA PRIVATE KEY-----"
          }
        },
        "password": "",
        "group": "my-group",
        "groups": [
          "my-second-group",
          "another-group"
        ]
      }
    }
  ],
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

### API response

Response:

```json
{
  "result": [
    "<instance-id>",
    {
      "private": {
        "type": "manual",
        "netmask": "255.255.255.0",
        "gateway": "10.230.13.1",
        "ip": "10.230.13.6",
        "dns": ["8.8.8.8"],
        "default": [ "dns", "gateway" ],
        "cloud_properties": { "net_id": "subnet-48rt54" }
      }
    }
  ],
  "error": null,
  "log": ""
}
```

### Implementations

 * [cppforlife/bosh-warden-cpi-release](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/create_vm.go)


## Related

 * [delete_vm](delete-vm.md)
