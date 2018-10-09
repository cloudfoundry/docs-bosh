# Cloud Provider Interface (Version 2)

For an overview of the sequence of CPI calls, the following resources are helpful:

- [BOSH components](bosh-components.md) and its example component interaction diagram
- [CLI v2 architecture doc](https://github.com/cloudfoundry/bosh-cli/blob/master/docs/architecture.md#deploy-command-flow) and [`bosh create-env` flow](https://github.com/cloudfoundry/bosh-init/blob/master/docs/init-cli-flow.png) where calls to the CPI are marked as `cloud`.

Examples of API request and response:

- [Building a CPI: RPC - Request](https://bosh.io/docs/build-cpi.html#request)
- [Building a CPI: RPC - Response](https://bosh.io/docs/build-cpi.html#response)


Library:

- Ruby: `bosh-cpi-ruby` gem [v2.5.0](https://github.com/cloudfoundry/bosh-cpi-ruby/releases/tag/v2.5.0)
- GoLang: `bosh-cpi-go` [library](https://github.com/cppforlife/bosh-cpi-go)

#### Migration from V1 contracts

Detailed instructions on how to migrate from V1 to V2 contracts can be found [here](v2-migration-guide.md).

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

- All V1 contracts must still be supported. See [CPI API V1](cpi-api-v1.md).
- To differentiate V2 calls the caller needs to pass in `"api_version": 2` in the header of the request.

### Reference Table (Based on each component version)

The director must understand version 2, CPI must be version 2, and Stemcell must contain an Agent suitable for version 2 to completely avoid the registry. `user-metadata` refers to the agent settings sent with `create_vm`.

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

\* see below for information on settings to write to user-metadata.

### Agent/VM Bootstrap Settings

When using the registry, the agent needed a minimal set of settings on bootstrap, including the registry location. Without the registry, a more complete set of information is given to the agent via the `user-metadata` through `create_vm`. The `user-metadata` is IaaS-specific. For example, AWS uses the `user_data` field during instance creation.

**CPI V1 & registry is used in V2 (see above for conditions)**
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
The registry is then consulted for the remainder of the required settings. The CPI has already written disk settings, etc.

**CPI V2, when Registry is bypassed**
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
**Note** that the `persistent` disks will not be available when the CPI writes these settings. When the Director instructs the CPI to attach a disk, the `attach_disk` method is expected to return information on the attach point. The Director then informs the Agent about the disk, and the Agent updates its disk settings.


### Implementation

CPI version 2 differs from version 1 by the following:
- CPI [info call](cpi-api-v2-method/info.md) will return `api_version`.
- CPI accepts `api_version` to establish api contract.
  - Director will send CPI `api_version` based on CPI's info response for all CPI calls.
- Director will send stemcell `api_version` for all CPI calls.

### Changes in V2 api contracts

 * [info](cpi-api-v2-method/info.md)
 * VM Management
    * [create_vm](cpi-api-v2-method/create-vm.md)
    * [delete_vm](cpi-api-v2-method/delete-vm.md)
 * Disk Management
    * [attach_disk](cpi-api-v2-method/attach-disk.md)
    * [detach_disk](cpi-api-v2-method/detach-disk.md)
