# Cloud Provider Interface (Version 1)

For a big picture overview of the sequence of CPI calls, the following resources are helpful:

- [BOSH components](bosh-components.md) and its example component interaction diagram
- [CLI v2 architecture doc](https://github.com/cloudfoundry/bosh-cli/blob/master/docs/architecture.md#deploy-command-flow) and [`bosh create-env` flow](https://github.com/cloudfoundry/bosh-init/blob/master/docs/init-cli-flow.png) where calls to the CPI are marked as `cloud`.

If you're looking to get started on building a CPI, this [short guide](build-cpi.md) may be helpful. To learn more about the technical implementation, continue reading or refer to the [RPC Interface](cpi-api-v1-rpc.md) for more details.


## Glossary {: #glossary }

- **cloud ID** is an ID (string) that the Director uses to reference any created infrastructure resource; typically CPI methods return cloud IDs and later receive them. For example AWS CPI's `create_vm` method would return `i-f789df` and `attach_disk` would take it.

- **cloud_properties** is a hash that can be specified for several objects (resource pool, disk pool, stemcell, network) to provide infrastructure specific settings to the CPI for that object. Only CPIs know the meaning of its contents. For example resource pool's `cloud_properties` for AWS can specify `instance_type`:

```yaml
resource_pools:
- name: large_machines
  cloud_properties: {instance_type: r3.8xlarge}
```


#### Additional methods in V1:

* Networking
    * [create_network](cpi-api-v1-method/create-network.md)
    * [delete_network](cpi-api-v1-method/delete-network.md)
