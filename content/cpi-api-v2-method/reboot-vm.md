# reboot_vm

Reboots the VM. Assume that VM can be either be powered on or off at the time of the call.

Waiting for the VM to finish rebooting is not required because the Director waits until the Agent on the VM responds back.


## Arguments

 * `vm_cid` [String]: Cloud ID of the VM to reboot; returned from `create_vm`.


## Result

No return value


## Examples


### Implementations

 * [cloudfoundry/bosh-vsphere-cpi-release](https://github.com/cloudfoundry/bosh-vsphere-cpi-release/blob/dfe878579cbab768af07a12bb5543cd016cbb762/src/vsphere_cpi/lib/cloud/vsphere/cloud.rb#L409)
