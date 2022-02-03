# set_vm_metadata

Sets VM's metadata to make it easier for operators to categorize VM-based resources when looking at the IaaS management console. We recommend to set VM name based on the passed `name` key (note `name` may be missing).

For example AWS CPI uses tags to store metadata for operators to see in the AWS Console.


## Arguments

 * `vm_cid` [String]: Cloud ID of the VM to modify; returned from `create_vm`.
 * `metadata` [Hash]: Collection of key-value pairs, including the top-level `tags` in the deployment manifest. CPI should not rely on presence of specific keys.


## Result

No return value


## Examples


### API Request

```json
[
  "i-387459",
  {
    "director": "director-784430",
    "deployment": "redis",
    "name": "redis/ce7d2040-212e-4d5a-a62d-952a12c50741",
    "job": "redis",
    "id": "ce7d2040-212e-4d5a-a62d-952a12c50741",
    "index": "1",
    "tag-name": "tag-value"
  }
]
```


### Implementations

 * [cloudfoundry/bosh-vsphere-cpi-release](https://github.com/cloudfoundry/bosh-vsphere-cpi-release/blob/dfe878579cbab768af07a12bb5543cd016cbb762/src/vsphere_cpi/lib/cloud/vsphere/cloud.rb#L433)


## Related

 * [create_vm](create-vm.md)
