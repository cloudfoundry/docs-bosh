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

---
## How to update CPI to support new contracts:

##### CPI Changes with V2 contracts:

- CPI `info` method should expose `api_version` supported.
- CPI V2 should use stemcell `api_version` to differentiate behaviour from older agents and it will be passed to all CPI calls from director in the payload context (example above in implementation section).

##### Agent changes with V2 contracts:

- Agent will now first check metadata service (based on IaaS) to get settings (for `settings.json`) before falling back to registry (if registry URL is specified in the metadata service).
- With new contracts agent will save disk_hints (`persistent_disk_hints.json`) locally and use it to mount/unmount disks.


##### Stemcell changes with V2 contracts:

- `stemcell.MF` should contain `api_version` if it contains a v2 supported agent in it, so that the director, CPI and cli can support registry-less operation.
	-  if `api_version` is not provided in the `stemcell.MF` it treats it as V1 API call
	-  in order to get new behaviour `api_version: 2` must be present

  ```yaml
  ---
  #### stemcell api_version
  api_version: 2
  name: bosh-aws-xen-hvm-ubuntu-trusty-go_agent
  version: '3546.14'
  bosh_protocol: '1'
  sha1: c186de6ef6e034bc93513440b9071b5f4696fa32
  operating_system: ubuntu-trusty
  stemcell_formats:
  - aws-light
  cloud_properties:
    ami:
      us-east-1: ami-xxxxxx
      us-west-1: ami-xxxxxx
  ```


### Migrating from V1 CPI to V2

`NOTE: all the actions associated with V1 should be supported along with V2 changes`

##### Ruby ![](https://cdn.emojidex.com/emoji/mdpi/Ruby.png)

- Update your gem in CPI to [v2.5.0](https://github.com/cloudfoundry/bosh-cpi-ruby/releases/tag/v2.5.0)

  ```
  gem install bosh_cpi -v 2.5.0
  ```

- For code reference you can check each method in the updated [cloud_v2.rb](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb) in bosh-aws-cpi

###### Updated flow based on registry availability (all examples are from `bosh-aws-cpi`)

- create_vm:
  - it should return `network_info` now which director will use to perform additional tasks (future scoped for director)
  - based on which stemcell `api_version` CPI receives in `context`, if its **>=2**
    - new CPI should not update registry
    - it should add the agent settings into the [user_metadata](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L45-L54) when it send request to IaaS to [create instance](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_core.rb#L94-L102)
  - if stemcell `api_version` is **< 2**
    - it should `update_registry` with all required [agent settings](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L58-L60) same as V1.


- delete_vm:
  - no change in input arguments and response.
  - based on which stemcell `api_version` CPI receives in `context`, if its **>=2**
    - new CPI should not try to delete `instance_id` from registry, as the `instance_id` will not exists in registry to begin with.
  - if stemcell `api_version` is **< 2**
    - [delete entry](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L110) with `instance_id` same as V1.

- attach_disk:
  - it should return `disk_hints` which will be used by director to perform additional tasks
    -  `disk_hints` should be the same as previously updated to registry for agent settings
    - Examples:
    ```
    // Older CPIs updates settings with disk settings as strings
    // e.g "/dev/sdc"
  	//     "3"
  	// Newer CPIs updates settings with a hash:
  	// e.g {"path" => "/dev/sdc"}
  	//     {"volume_id" => "3"}
  	//     {"lun" => "0", "host_device_id" => "{host-device-id}"}
    ```
  - based on which stemcell `api_version` CPI receives in `context`, if its **>=2**
    - it should not try to update registry with disk_hints
  - if stemcell `api_version` is **< 2**
    - it should [update the registry](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/1d7c31ec1ea0bb65a287adfc1898810a615218b8/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L76-L80) with disk_hints same as V1


- detach_disk:
  - no changes in input arguments and response
  - based on which stemcell `api_version` CPI receives in `context`, if its **>=2**
    - it should not try to delete `disk_id` entry in agent settings in registry
  - if stemcell `api_version` is **< 2**
    - it should [delete](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/1d7c31ec1ea0bb65a287adfc1898810a615218b8/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L94-L98) `disk_id` from agent settings from registry same as V1


##### GoLang ![](cpi-api-v2-method/gopher.jpg)

Check CPIs using this library:

- [Warden CPI](https://github.com/cppforlife/bosh-warden-cpi-release)
- [VirtualBox CPI](https://github.com/cppforlife/bosh-virtualbox-cpi-release)
- [Docker CPI](https://github.com/cppforlife/bosh-docker-cpi-release)
- [Kubernetes CPI](https://github.com/bosh-cpis/bosh-kubernetes-cpi-release)


---

### Reference pipeline to test  CPI with all combination of Director, CLI and  Stemcell
[Pipeline for CPI V2 testing]( https://github.com/cloudfoundry-incubator/bosh-aws-cpi-release/blob/49447ba7ee208c31dddc1b7e3ec2a5f05c88ea99/ci/pipeline_cpi_v2.yml.erb)

**NOTE:** Few other combination should be taken under consideration

- which version of cpi is specified in `cpi.json`.
- director is adding `cpi_api_version ` in its properties or not.
  - **FOR Test phase**: is director specifying [`cpi_api_test_max_version`](https://github.com/cloudfoundry-incubator/bosh-cpi-certification/blob/master/aws/assets/ops/director_cpi_version.yml) in its properties to use only the specified version of CPI.
- On CPI side you can specify cpi api_version for debugging. Examples:
  - [spec](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/jobs/aws_cpi/spec#L14-L16)

  ```yaml
   debug.cpi.api_version:
      description: api_version supported by cpi (can be used as an override for fallback).
      default: null
  ```
  - [cpi.json](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/jobs/aws_cpi/templates/cpi.json.erb#L34-L38)
  - [config.rb](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/1d7c31ec1ea0bb65a287adfc1898810a615218b8/src/bosh_aws_cpi/lib/cloud/aws/config.rb#L75-L109) to load debug version if specified.
