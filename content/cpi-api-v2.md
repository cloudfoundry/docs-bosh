# Cloud Provider Interface (Version 2)

For an overview of the sequence of the CPI calls, please have a look at the following resources:

- [BOSH components](bosh-components.md) and its example component interaction diagram
- [CLI v2 architecture doc](https://github.com/cloudfoundry/bosh-cli/blob/master/docs/architecture.md#deploy-command-flow) and [`bosh create-env` flow](https://github.com/cloudfoundry/bosh-init/blob/master/docs/init-cli-flow.png) where calls to the CPI are marked as `cloud`.

Examples of API request and response:

- [Building a CPI: RPC - Request](https://bosh.io/docs/build-cpi.html#request)
- [Building a CPI: RPC - Response](https://bosh.io/docs/build-cpi.html#response)


Libraries:

- Ruby: `bosh-cpi-ruby` gem [v2.5.0](https://github.com/cloudfoundry/bosh-cpi-ruby/releases/tag/v2.5.0)
- GoLang: `bosh-cpi-go` [library](https://github.com/cppforlife/bosh-cpi-go)

#### Migration from V1 of the CPI API contract

Detailed instructions on how to migrate an existing CPI from V1 to V2 of the contract can be found [here](v2-migration-guide.md).

---

## Glossary {: #glossary }

- **cloud ID** is an ID (string) that the Director uses to reference any created infrastructure resource. Typically, CPI methods return cloud IDs and will later expect them as parameters for methods that manage resources. For example the AWS CPI's `create_vm` method would return the cloud ID `i-f789df`, and a later call to `attach_disk` would need this cloud ID as an input parameter.

- **cloud_properties** is a hash that can be specified for several object types (resource pool, disk pool, stemcell, network) to provide infrastructure specific settings to the CPI for a specific object. It is the CPI's responsibility to parse and understand the contents of the hash. For example, the `cloud_properties` for a `resource_pool` object can specify the `instance_type` property if the AWS CPI is used:

```yaml
resource_pools:
- name: large_machines
  cloud_properties: {instance_type: r3.8xlarge}
```
`instance_type` is specific to AWS in this example, and is meaningless in the context of other CPIs.


## Methods

### Agent/VM Bootstrap Settings

A complete set of information is given to the agent via `user-metadata` through `create_vm`. The contents of `user-metadata` are IaaS-specific. For example, AWS uses the `user_data` field during instance creation.

**CPI contract**
```json
{
  "agent_id": "...",
  "dns": {},
  "networks": {},
  "disks": {
    "system": {"path": "/dev/sda1"},
    "ephemeral": {"path": "/dev/sdb1"},
    "persistent": {},
  },
  "vm": {
    "name": "..."
  }
}
```
**Note** that the `persistent` disks will not be available when the CPI writes these settings. When the Director instructs the CPI to attach a disk, the `attach_disk` method is expected to return information on the attach point. The Director then informs the Agent about the disk, and the Agent updates its disk settings accordingly.


