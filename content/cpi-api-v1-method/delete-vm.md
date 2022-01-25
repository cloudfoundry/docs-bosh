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

 * [bosh-warden-cpi-release](https://github.com/cloudfoundry/bosh-warden-cpi-release/blob/master/src/bosh-warden-cpi/action/delete_vm.go)


## Related

 * [create_vm](create-vm.md)
