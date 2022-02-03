# get_disks

Returns list of disks _currently_ attached to the VM.

This method is mostly used by the consistency check tool (cloudcheck) to determine if the VM has required disks attached.


## Arguments

* `vm_cid` [String]: Cloud ID of the VM.


## Result

* `disk_cids` [Array of strings]: Array of `disk_cid`s that are currently attached to the VM.


## Related

 * [create_disk](create-disk.md)
 * [attach_disk](attach-disk.md)
