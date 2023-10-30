# Cloud Provider Interface (Version 2)

For an overview of the sequence of the CPI calls, please have a look at the following resources:

- [BOSH components](bosh-components.md) and its example component interaction diagram
- [CLI v2 architecture doc](https://github.com/cloudfoundry/bosh-cli/blob/master/docs/architecture.md#deploy-command-flow) and [`bosh create-env` flow](https://github.com/cloudfoundry/bosh-init/blob/master/docs/init-cli-flow.png) where calls to the CPI are marked as `cloud`.

Examples of API request and response:

- [Building a CPI: RPC - Request](https://bosh.io/docs/build-cpi.html#request)
- [Building a CPI: RPC - Response](https://bosh.io/docs/build-cpi.html#response)


If you're looking to get started on building a CPI, this [short guide](build-cpi.md) may be helpful. To learn more about the technical implementation, continue reading or refer to the [RPC Interface](cpi-api-rpc.md) for more details.


Libraries:

- Ruby: `bosh-cpi-ruby` gem [v2.5.0](https://github.com/cloudfoundry/bosh-cpi-ruby/releases/tag/v2.5.0)
- GoLang: `bosh-cpi-go` [library](https://github.com/cloudfoundry/bosh-cpi-go)

#### Migration from V1 of the CPI API contract

Detailed instructions on how to migrate an existing CPI from V1 to V2 of the contract can be found [here](cpi-api-v2-migration-guide.md).

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

- To differentiate calls using V2 of the contract, the caller passes `"api_version": 2` in the header of the request.
- V1 of the CPI API contract is deprecated, and need not be implemented.
    - Reference [CPI API V1](cpi-api-v1.md).

### Reference Table (Based on each component version)

For registry-less operation to be possible, the director and CPI must implement v2 of the API contract and the stemcell must contain a version of the agent implementing v2 as well. In the table below, `user-metadata` refers to the agent settings sent with `create_vm`.

| Director | CPI | Stemcell  | Should update registry   | Add *full agent settings** to IaaS `user-metadata`?   |
|----------|-----|-----------|----------------------|---|
| 1  | 1  | 1  | Update registry | No |
| 1  | 1  | 2  | Update registry | No |
| 1  | 2  | 2  | Update registry | No |
| **2**  | **2**  | **2**  | **Do not write to registry** | **Yes** |
| 1  | 2  | 1  | Update registry | No |
| 2  | 2  | 1  | Update registry | No |
| 2  | 1  | 1  | Update registry | No |
| 2  | 1  | 2  | Update registry | No |

\* see below for information on the settings to write to `user-metadata`.

### Agent/VM Bootstrap Settings

When using the registry, the agent needs a minimal set of settings on bootstrap, including the registry location. When operating in registry-less mode, a more complete set of information is given to the agent via `user-metadata` through `create_vm`. The contents of `user-metadata` are IaaS-specific. For example, AWS uses the `user_data` field during instance creation.

**Registry is used, CPI contract V1 and V2 (see above for conditions)**
```json
{
  "dns": {},
  "networks": {},
  "registry": {
    "endpoint": "...",
    "user": "...",
    "password": "..."
  }
}
```
The remainder of the required settings are then fetched from the registry. The CPI has already written disk settings, etc.

**Registry is bypassed, CPI contract V2 only**
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

### API contract changes since V1

CPI contract version 2 differs from version 1 by the following:

- CPI [info call](cpi-api-v2-method/info.md) will return `api_version`.
- CPI accepts `api_version` to determine which version of the API contract to use.
    - Director will send CPI `api_version` based on the CPI's info response for all CPI calls.
- Director will send stemcell `api_version` for all CPI calls.

#### API method changes

* General
    * [info](cpi-api-v2-method/info.md)
* VM Management
    * [create_vm](cpi-api-v2-method/create-vm.md)
    * [delete_vm](cpi-api-v2-method/delete-vm.md)
* Disk Management
    * [attach_disk](cpi-api-v2-method/attach-disk.md)
    * [detach_disk](cpi-api-v2-method/detach-disk.md)
