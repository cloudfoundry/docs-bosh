# Cloud Provider Interface

For an overview of the sequence of CPI calls, the following resources are helpful:

- [BOSH components](bosh-components.md) and its example component interaction diagram
- [CLI v2 architecture doc](https://github.com/cloudfoundry/bosh-cli/blob/master/docs/architecture.md#deploy-command-flow) and [`bosh create-env` flow](https://github.com/cloudfoundry/bosh-init/blob/master/docs/init-cli-flow.png) where calls to the CPI are marked as `cloud`.

Examples of API request and response:

- [Building a CPI: RPC - Request](https://bosh.io/docs/build-cpi.html#request)
- [Building a CPI: RPC - Response](https://bosh.io/docs/build-cpi.html#response)

---
## Glossary {: #glossary }

- **cloud ID** is an ID (string) that the Director uses to reference any created infrastructure resource; typically CPI methods return cloud IDs and later receive them. For example AWS CPI's `create_vm` method would return `i-f789df` and `attach_disk` would take it.

- **cloud_properties** is a hash that can be specified for several objects (resource pool, disk pool, stemcell, network) to provide infrastructure specific settings to the CPI for that object. Only CPIs know the meaning of its contents. For example resource pool's `cloud_properties` for AWS can specify `instance_type`:

```yaml
resource_pools:
- name: large_machines
  cloud_properties: {instance_type: r3.8xlarge}
```


## Methods

 * [info](cpi-api-v1-method/info.md)
 * Stemcells
    * [create_stemcell](cpi-api-v1-method/create-stemcell.md)
    * [delete_stemcell](cpi-api-v1-method/delete-stemcell.md)
 * VM Management
    * [create_vm](cpi-api-v1-method/create-vm.md)
    * [delete_vm](cpi-api-v1-method/delete-vm.md)
    * [has_vm](cpi-api-v1-method/has-vm.md)
    * [reboot_vm](cpi-api-v1-method/reboot-vm.md)
    * [set_vm_metadata](cpi-api-v1-method/set-vm-metadata.md)
    * [calculate_vm_cloud_properties](cpi-api-v1-method/calculate-vm-cloud-properties.md)
 * Disk Management
    * [create_disk](cpi-api-v1-method/create-disk.md)
    * [delete_disk](cpi-api-v1-method/delete-disk.md)
    * [resize_disk](cpi-api-v1-method/resize-disk.md)
    * [has_disk](cpi-api-v1-method/has-disk.md)
    * [attach_disk](cpi-api-v1-method/attach-disk.md)
    * [detach_disk](cpi-api-v1-method/detach-disk.md)
    * [set_disk_metadata](cpi-api-v1-method/set-disk-metadata.md)
    * [get_disks](cpi-api-v1-method/get-disks.md)
    * Snapshot Management
       * [snapshot_disk](cpi-api-v1-method/snapshot-disk.md)
       * [delete_snapshot](cpi-api-v1-method/delete-snapshot.md)
 * Deprecated
    * [configure_networks](cpi-api-v1-method/configure-networks.md)
    * [current_vm_id](cpi-api-v1-method/current-vm-id.md)
