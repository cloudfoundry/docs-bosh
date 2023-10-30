# attach_disk

Attaches a given disk to a given VM.

## Arguments

 * `vm_cid` [String]: Cloud ID of the VM.
 * `disk_cid` [String]: Cloud ID of the disk.


## Result

 * `disk_hints` [Hash or String]: Disks that are associated with the VM

 The `disk_hints` vary between each IaaS. The `disk_hints` describe the physical attach point of the disk. The Agent is updated with a mapping of volume ID to attach point.
 For example, the AWS implementation of the CPI simply returns a string representing the device block id:

 `"/dev/sdd"`


## Agent settings

For the Agent to eventually format, partition and mount the newly attached disk, it needs to identify the disk attachment from inside the OS. The Agent can currently identify attached disks based on either their device path, disk's ID, or SCSI volume ID. For example, the sample settings below show that the CPI attached a disk `vol-7447851` at `/dev/sdd`:

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

See [CPI API V2](../cpi-api-v2.md) and [CPI V2 Migration Guide](../cpi-api-v2-migration-guide.md) for more details about `api_version` for stemcell and CPI within the `context` portion of the request.


### Implementations

 * [cppforlife/bosh-warden-cpi-release](https://github.com/cloudfoundry/bosh-warden-cpi-release/blob/master/src/bosh-warden-cpi/action/attach_disk.go)


## Related

 * [attach_disk V1](../cpi-api-v1-method/attach-disk.md)
 * [create_disk](create-disk.md)
 * [detach_disk](detach-disk.md)
