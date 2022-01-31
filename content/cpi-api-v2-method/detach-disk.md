# detach_disk

Detaches disk from the VM.

If the persistent disk is attached to a VM that will be deleted, it is more likely that the `delete_vm` CPI method will be called without a call to `detach_disk`. The expectation here is that `delete_vm` will make sure the disks are disassociated from the VM upon its deletion.

Agent settings must have been updated to remove information about the given disk.


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

 #### Changes for V2 of the API contract

See [CPI V2 Migration Guide](../v2-migration-guide.md) for more information.

## Related

 * [attach_disk](attach-disk.md)
 * [delete_disk V1](../cpi-api-v1-method/delete-disk.md)
