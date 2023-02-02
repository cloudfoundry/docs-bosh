# set_disk_metadata

Sets disk's metadata to make it easier for operators to categorize disks when looking at the IaaS management console. For example AWS CPI uses tags to store metadata for operators to see in the AWS Console.

Disk metadata is written when the disk is attached to a VM. Metadata is not removed when disk is detached or VM is deleted.

What is called “_metadata_” here is actually implemented as tags by most CPIs.
The following default disk tags are forced by Bosh, whatever happens. These
cannot be overridden.

```json
{
  "instance_id":    "c50f32a0-65f4-40a2-9dde-bff12560c14d", // the stable, unique ID of the (VM) instance in its group, to which the disk has been attached
  "instance_index": "1",                                    // the human-readable identifier of the (VM) instance in its instance group
  "attached_at":    "YYYY-MM-DDThh:mm:ssZ",                 // the last time at which `set_disk_metadata` method has been called on the disk
  "instance_group": "traefik",       // the name of the group to which the (VM) instance belongs
  "deployment":     "traefik",       // the name of deployment to which the 'instance_group' belongs
  "director":       "director name", // the name of the director that has deployed the deployment, as shown by `bosh env`
}
```

!!! note
    This `set_disk_metadata` method is called by BOSH v262+.


## Arguments

 * `disk_cid` [String]: Cloud ID of the disk to modify; returned from `create_disk`.
 * `metadata` [Hash]: Collection of key-value pairs. CPI should not rely on presence of specific keys.


## Result

No return value


## Examples


### API Request

```json
[
  "vol-3475945",
  {
    "director": "director-784430",
    "deployment": "redis",
    "instance_id": "ce7d2040-212e-4d5a-a62d-952a12c50741",
    "job": "redis",
    "instance_index": "1",
    "instance_name": "redis/ce7d2040-212e-4d5a-a62d-952a12c50741",
    "attached_at": "2017-08-10T12:03:32Z"
  }
]
```


### Implementations

 * [cloudfoundry/bosh-openstack-cpi-release](https://github.com/cloudfoundry/bosh-openstack-cpi-release/blob/0c8ee8951cab41d0ddc86591719d55d8a783ac98/src/bosh_openstack_cpi/lib/cloud/openstack/cloud.rb#L629)


## Related

 * [create_disk](create-disk.md)
