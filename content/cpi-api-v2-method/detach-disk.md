# detach_disk

Detaches disk from the VM.

If the persistent disk is attached to a VM that will be deleted, it's more likely `delete_vm` CPI method will be called without a call to `detach_disk` with an expectation that `delete_vm` will make sure disks are disassociated from the VM upon its deletion.

Agent settings should have been updated to remove information about given disk.


## Arguments

 * `vm_cid` [String]: Cloud ID of the VM.
 * `disk_cid` [String]: Cloud ID of the disk.


## Result

No return value


## Examples

### API request


```json
{
  "method": "detach_disk",
  "arguments": [
    "i-0377ec1efc3f06cf8",
    "vol-044c8ae985721d217"
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
  "result": true,
  "error": null,
  "log": ""
}
```


### Implementations

 * [cppforlife/bosh-warden-cpi-release](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/detach_disk.go)

 #### Changes for V2

 The signature for `detach_disk` is the same as V1, but for CPIs that previously used the registry to track mount points, V2 does not use the registry.

## Related

 * [attach_disk](attach-disk.md)
 * [delete_disk V1](../cpi-api-v1-method/delete-disk.md)
