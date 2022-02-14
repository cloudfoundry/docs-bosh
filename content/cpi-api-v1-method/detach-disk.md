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


### Implementations

 * [cppforlife/bosh-warden-cpi-release](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/detach_disk.go)


## Related

 * [attach_disk](../cpi-api-v2-method/attach-disk.md)
 * [delete_disk](../cpi-api-v2-method/delete-disk.md)
