# attach_disk

Attaches disk to the VM.

Typically each VM will have one disk attached at a time to store persistent data; however, there are important cases when multiple disks may be attached to a VM. Most common scenario involves persistent data migration from a smaller to a larger disk. Given a VM with a smaller disk attached, the operator decides to increase the disk size for that VM, so new larger disk is created, it is then attached to the VM. The Agent then copies over the data from one disk to another, and smaller disk subsequently is detached and deleted.

Agent settings should have been updated with necessary information about given disk.


## Arguments

 * `vm_cid` [String]: Cloud ID of the VM.
 * `disk_cid` [String]: Cloud ID of the disk.


## Result

 * `disk_hints` [Hash or String]: Disks that are associated with the VM


## Agent settings

For the Agent to eventually format, partition and mount attached disk, it needs to identify the disk attachment from inside the OS. The Agent can currently identify attached disk based on either device path, disk's ID, or SCSI volume ID. For example settings below show that CPI attached a disk `vol-7447851` at `/dev/sdd`:

```json
{
  "agent_id": "4149ba0f-38d9-4485-476f-1581be36f290",

  "vm": { "name": "i-347844" },

  "networks": { ... },

  "disks": {
  	"system": "/dev/sda",
  	"ephemeral": "/dev/sdb",
  	"persistent": {
  		"vol-3475945": { "volume_id": "3" },
  		"vol-7447851": { "path": "/dev/sdd" },
  	}
  },

  "mbus": "https://mbus:mbus-password@0.0.0.0:6868",

  "ntp": [ ... ],

  "blobstore": { ... },

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

## Examples

### API request

```json
{
  "method": "attach_disk",
  "arguments": [
    "i-0a8d6e89b06c7ef25",
    "vol-01aad1d6b3149cca1"
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

```json
{
  //disk hint response (string/hash)
  "result": "/dev/sdf",
  "error": null,
  "log": ""
}
```

### Implementations

 * [cppforlife/bosh-warden-cpi-release](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/attach_disk.go)


## Related

 * [create_disk V1](../cpi-api-v1-method/create-disk.md)
 * [detach_disk V1](../cpi-api-v1-method/detach-disk.md)
