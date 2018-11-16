# create_disk

Creates disk with specific size. Disk does not belong to any given VM.


## Arguments

 * `size` [Integer]: Size of the disk in MiB.
 * `cloud_properties` [Hash]: Cloud properties hash specified in the deployment manifest under the disk pool.
 * `vm_cid` [String]: Cloud ID of the VM created disk will most _likely_ be attached; it could be used to .optimize disk placement so that disk is located near the VM.


## Returned

 * `disk_cid` [String]: Cloud ID of the created disk.


## Examples


### API Request

```json
[
  25000,
  {
    "type": "gp2",
    "encrypted": true
  },
  "i-2387475"
]
```

### Implementations

 * [cppforlife/bosh-warden-cpi-release](https://github.com/cppforlife/bosh-warden-cpi-release/blob/master/src/github.com/cppforlife/bosh-warden-cpi/action/create_disk.go)


## Related

 * [attach_disk](attach-disk.md)
 * [delete_disk](delete-disk.md)
