# delete_vm

Deletes the VM.

This method will be called while the VM still has persistent disks attached. It's important to make sure that IaaS behaves appropriately in this case and properly disassociates persistent disks from the VM.

To avoid losing track of VMs, make sure to raise an error if VM deletion is not absolutely certain.


## Arguments

- **vm_cid** [String]: Cloud ID of the VM to delete; returned from `create_vm`.


## Result

No return value


## Examples

### Implementations

 * [cppforlife/bosh-warden-cpi-release](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/delete_vm.go)

#### Changes for V2

The signature for `delete_vm` is the same as V1, but for CPIs that previously used the registry to track mount points, V2 does not use the registry.


## Related

 * [create_vm](create-vm.md)
