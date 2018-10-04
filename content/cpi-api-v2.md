# Cloud Provider Interface

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
* Reg./reg. : Registry

| Director | CPI | Stemcell  | Should update Reg.   | Add agent setting to IaaS `user-metadata`   |
|----------|-----|-----------|----------------------|---|
| 1  | 1  | 1  | Update Reg.  | Don't add agent setting to IaaS  |
| 1  | 1  | 2  | Update Reg.  | Don't add agent setting to IaaS  |
| 1  | 2  | 2  | Update Reg.  | Don't add agent setting to IaaS  |
| 2  | 2  | 2  | DON'T add anything to reg.   | Yes, agent will read `user-metadata` and not call reg.  |
| 1  | 2  | 1  | Update Reg.  | Don't add agent setting to IaaS  |
| 2  | 2  | 1  | Update Reg.  | Don't add agent setting to IaaS (no agent support)  |
| 2  | 1  | 1  | Update Reg. (CPI will by default update reg.)  | Don't add agent setting to IaaS |
| 2  | 1  | 2  | Update Reg. (CPI will by default update reg.)  | Don't add agent setting to IaaS |

### Implementation

API version 2 of CPIs will differ from version 1 by the following:

 - Director will send CPI api_version based on info response from for all CPI calls.

   ```json
    {
       "log": "",
       "error": null,
       "result": {
         "api_version": 2, //cpi_api_version
         "stemcell_formats": [
           "dummy",
         ]
       }
    }
   ```

 - Director will also send stemcell `api_version` for all CPI calls.
 - Director will be expecting V2 responses when:
   - CPI info call provide max supported version as >=2 **AND**
   - Stemcell api_version is >=2 **AND**
   - `api_version: 2` is present in the header.


  ```json
   "context": {
    "director_uuid": "<director-uuid>",
    "request_id": "<cpi-request-id>",
    "vm": {
      "stemcell": {
        "api_version": 2
      }
    }
  },
  "api_version": 2
  ```


### Changes in V2 contracts

 * [info](cpi-api-v2-method/info.md)
 * VM Management
    * [create_vm](cpi-api-v2-method/create-vm.md)
    * [delete_vm](cpi-api-v2-method/delete-vm.md)
 * Disk Management
    * [attach_disk](cpi-api-v2-method/attach-disk.md)
    * [detach_disk](cpi-api-v2-method/detach-disk.md)


#### Additional methods in V1:

* Networking
   * [create_network](cpi-api-v1-method/create-network.md)
   * [delete_network](cpi-api-v1-method/delete-network.md)
