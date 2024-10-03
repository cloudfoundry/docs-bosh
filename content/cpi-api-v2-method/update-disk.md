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

## Arguments

 * `disk_cid` [String]: Cloud ID of the disk to update; returned from `create_disk`.
 * `new_size` [Integer]: New disk size in MiB.
 * `cloud_properties` [Hash]: New cloud properties for the disk. The properties are specific to the IaaS and are opaque to the Director. The Director does not validate the properties and passes them to the CPI as-is.

## Result

No return value

## Examples

### Implementations

 * [cloudfoundry/bosh-azure-cpi-release](https://github.com/cloudfoundry/bosh-azure-cpi-release/blob/fc16e6f65b0533f83052812dc0d6c1edefc9ac28/src/bosh_azure_cpi/lib/cloud/azure/cloud.rb#L482)

## Related

 * [resize_disk](resize-disk.md)
 * [create_disk](create-disk.md)