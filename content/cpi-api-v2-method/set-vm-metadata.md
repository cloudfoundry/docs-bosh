# set_vm_metadata

Sets VM's metadata to make it easier for operators to categorize VM-based resources when looking at the IaaS management console. We recommend to set VM name based on the passed `name` key (note `name` may be missing).

For example AWS CPI uses tags to store metadata for operators to see in the AWS
Console. Same goes for Azure and Google CPIs. What is called “_metadata_” here
is actually implemented as tags by most CPIs.

The following default tags are forced by Bosh, whatever happens. These cannot be overridden.

```json
{
  "director":       "director name", // the director name, as shown by `bosh env`
  "deployment":     "traefik",       // the name of deployment to which the 'instance_group' belongs
  "instance_group": "traefik",       // the name of the group to which the (VM) instance belongs
  "job":            "traefik",       // 'job' is an old alias for 'instance_group', here it holds the exact same value
  "id":    "c50f32a0-65f4-40a2-9dde-bff12560c14d",         // the stable, unique ID of the (VM) instance in its group
  "name":  "traefik/c50f32a0-65f4-40a2-9dde-bff12560c14d", // the full name of the (VM) instance, composed of '<instance_group>/<instance_id>'
  "index": "1",                                            // the human-readable identifier of the (VM) instance in its instance group
  "created_at": "YYYY-MM-DDThh:mm:ssZ"                     // the last time at which `set_vm_metadata` method has been called on the (VM) instance
}
```

Compilation VMs also have this tag that details the package being compiled by
the VM:

```json
{
  "compiling": "package name"
}
```

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
