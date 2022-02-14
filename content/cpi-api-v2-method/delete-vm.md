# delete_vm

Deletes the VM.

This method will be called while the VM still has persistent disks attached. It is important to make sure that the IaaS behaves appropriately in this case and properly disassociates the persistent disks from the VM.

To avoid losing track of VMs, make sure to raise an error if VM deletion is not absolutely certain.


## Arguments

- **vm_cid** [String]: Cloud ID of the VM to delete; returned from `create_vm`.


## Result

No return value


## Examples

### API request

```json
{
  "method": "delete_vm",
  "arguments": [
    "<vm_cid>"
  ],
  "context": {
    "director_uuid": "<director-uuid>",
    "request_id": "<cpi-request-id>",
  },
  "api_version": 2,
}
```

### Implementations

 * [bosh-warden-cpi-release](https://github.com/cloudfoundry/bosh-warden-cpi-release/blob/master/src/bosh-warden-cpi/action/delete_vm.go)

#### Changes for V2 of the API contract

The signature for `delete_vm` is the same as in V1 pf the API contract. For CPIs that previously used the registry to track mount points, V2 does not necessarily use the registry. The registry is used if the stemcell API version is not sufficient. The Agent receives an `unmount_disk` from the Director and deletes the persistent disk settings when not using the registry. See [CPI V2 Migration Guide](../cpi-api-v2-migration-guide.md) for more information.


## Related

 * [delete_vm V1](../cpi-api-v1-method/delete-vm.md)
 * [create_vm](create-vm.md)
