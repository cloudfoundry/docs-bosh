# has_disk

Checks for disk presence in the IaaS.

This method is mostly used by the consistency check tool (cloudcheck) to determine if the disk still exists.


## Arguments

 * `disk_cid` [String]: Cloud ID of the disk to check; returned from `create_disk`.


## Result

 * `exists` [Boolean]: True if disk is present.


## Examples


### Implementations

 * [cloudfoundry/bosh-vsphere-cpi-release](https://github.com/cloudfoundry/bosh-vsphere-cpi-release/blob/dfe878579cbab768af07a12bb5543cd016cbb762/src/vsphere_cpi/lib/cloud/vsphere/cloud.rb#L129)


## Related

 * [create_disk](create-disk.md)
