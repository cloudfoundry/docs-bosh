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

 * [cppforlife/bosh-warden-cpi-release](https://github.com/cloudfoundry/bosh-warden-cpi-release/blob/master/src/bosh-warden-cpi/action/detach_disk.go)

#### Changes for V2 of the API contract

The signature for `detach_disk` is the same as in V1 of the API contract. For CPIs that previously used the registry to track mount points, V2 does not necessarily use the registry. The registry should be used if the stemcell API version is not sufficient. Without the registry, the Agent receives a message from the Director to remove the persistent disk from its settings. See [CPI V2 Migration Guide](../cpi-api-v2-migration-guide.md) for more information.

## Related

 * [detach_disk V1](../cpi-api-v1-method/detach-disk.md)
 * [attach_disk](attach-disk.md)
 * [delete_disk](delete-disk.md)
