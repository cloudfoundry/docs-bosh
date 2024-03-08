# resize_disk

Resizes disk with IaaS-native methods. Assume that disk was detached from all VMs. Set property [`director.enable_cpi_resize_disk`](http://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh&version=263#p=director.enable_cpi_resize_disk) to `true` to have the Director call this method.

Depending on the capabilities of the underlying infrastructure, this method may raise an `Bosh::Clouds::NotSupported` error when the `new_size` is smaller than the current disk size. The same error is raised when the method is not implemented.

If `Bosh::Clouds::NotSupported` is raised, the Director falls back to creating a new disk and copying data.


## Arguments

 * `disk_cid` [String]: Cloud ID of the disk to resize; returned from `create_disk`.
 * `new_size` [Integer]: New disk size in MiB.


## Result

No return value


## Examples

### Implementations

 * [cloudfoundry/bosh-openstack-cpi-release](https://github.com/cloudfoundry/bosh-openstack-cpi-release/blob/88e1c6d402b3c4ce23ad39ebdf5ab5fc93790127/src/bosh_openstack_cpi/lib/cloud/openstack/cloud.rb#L701)
 * [cloudfoundry/bosh-aws-cpi-release](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/7906dc66c61d4667ad74beeda3e5627f997ad740/src/bosh_aws_cpi/lib/cloud/aws/cloud_core.rb#L165)


## Related

 * [create_disk](create-disk.md)
