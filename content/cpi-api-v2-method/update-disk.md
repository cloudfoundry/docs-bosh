# update_disk

Update the disk using IaaS-native methods, ensuring it's detached from all VMs first. Activate this feature with the following director configuration:

```yaml
director:
  enable_cpi_update_disk: true
```

Updating disk properties directly via the IaaS, such as changing the disk type or specific disk settings without needing to create a completely new disk, offers significant benefits in minimizing downtime. This approach is very effective for deployments with multiple large disks, as it bypasses the time-consuming task of disk creation and data transfer.

Should the native disk update operation encounter limitations, indicated by a `Bosh::Clouds::NotSupported` error, due to either the infrastructure's inability to process the request or if the method is not implemented, the Director will default to generating a new disk and migrating the data.

!!! note
    Before enabling this feature, ensure that the `director.enable_cpi_resize_disk` property is disabled, as the Director gives priority to the `resize_disk` method due to its broader implementation across CPIs. However, it's worth noting that the `update_disk` method not only matches the capabilities of `resize_disk` but also offers the additional functionality of updating cloud properties.

## Director behavior during VM recreation

When `enable_cpi_update_disk` is enabled and a VM is being recreated (e.g., due to a stemcell update or cloud property change), the Director calls `update_disk` while the disk is already in a detached state. This avoids a redundant detach-update-attach cycle:

1. Detach disk from the old VM
2. Call `update_disk` (disk is already detached)
3. Delete old VM, create new VM
4. Attach the (possibly new) disk to the new VM

If the CPI does not support `update_disk`, the Director falls back to the standard copy-based disk migration path transparently.

## Arguments

- `disk_cid` [String]: Cloud ID of the disk to update; returned from `create_disk`.
- `new_size` [Integer]: New disk size in MiB.
- `cloud_properties` [Hash]: New cloud properties for the disk. The properties are specific to the IaaS and are opaque to the Director. The Director does not validate the properties and passes them to the CPI as-is.

## Result

- `new_disk_cid` [String or nil]: If the disk was replaced (e.g., via snapshot and recreate due to an incompatible type change), returns the new disk's Cloud ID. The Director persists this new CID and uses it for subsequent operations. If the disk was updated in-place, the CPI may return `nil` or the original disk CID - in both cases, the Director continues using the existing CID.

## Examples

### API

```json
[
  "disk-cid-abc123",
  32768,
  {"type": "hyperdisk-balanced"}
]
```

**Response (disk replaced):**

```json
"new-disk-cid-def456"
```

**Response (in-place update):**

```json
null
```

### Implementations

- [cloudfoundry/bosh-azure-cpi-release](https://github.com/cloudfoundry/bosh-azure-cpi-release/blob/fc16e6f65b0533f83052812dc0d6c1edefc9ac28/src/bosh_azure_cpi/lib/cloud/azure/cloud.rb#L482)
- [cloudfoundry/bosh-google-cpi-release](https://github.com/cloudfoundry/bosh-google-cpi-release/blob/master/src/bosh-google-cpi/action/update_disk.go)

## Related

- [resize_disk](resize-disk.md)
- [create_disk](create-disk.md)
