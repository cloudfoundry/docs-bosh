# delete_disk

Deletes disk. Assume that disk was detached from all VMs.

To avoid losing track of disks, make sure to raise an error if disk deletion is not absolutely certain.


## Arguments

 * `disk_cid` [String]: Cloud ID of the disk to delete; returned from `create_disk`.


## Result

No return value


## Examples


### Implementations

 * [cloudfoundry/bosh-warden-cpi-release](https://github.com/cloudfoundry/bosh-warden-cpi-release/blob/master/src/bosh-warden-cpi/action/delete_disk.go)


## Related

 * [detach_disk](detach-disk.md)
 * [create_disk](create-disk.md)
