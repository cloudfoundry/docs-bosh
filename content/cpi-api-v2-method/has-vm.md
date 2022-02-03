# has_vm

Checks for VM presence in the IaaS.

This method is mostly used by the consistency check tool (cloudcheck) to determine if the VM still exists.


## Arguments

 * `vm_cid` [String]: Cloud ID of the VM to check; returned from `create_vm`.


## Returned

 * `exists` [Boolean]: True if VM is present.


## Examples


### Implementations

 * [cppforlife/bosh-warden-cpi-release](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/has_vm.go)


## Related

 * [create_vm](create-vm.md)
