## Migrating from V1 to V2 of the CPI API contract

##### CPI Changes in V2 of the API contract:

  - CPI [`info`](cpi-api-v2-method/info.md) method exposes supported `api_version`.
  - CPI [`create_vm`](cpi-api-v2-method/create-vm.md) method returns an array of vm_id, network_info.
    - CPI adds agent settings, i.e. agent id, networks, disks (previously sent to registry) into VM metadata / user-data
  - CPI [`attach_disk`](cpi-api-v2-method/attach-disk.md) method returns disk hints.
  - CPI [`detach_disk`](cpi-api-v2-method/detach-disk.md) method has no changes.
  - CPI [`delete_vm`](cpi-api-v2-method/delete-vm.md) method has no changes.

##### V2 flow depending on registry availability (all examples are from `bosh-aws-cpi`)

  - `create_vm`:
    - Returns `network_info`, that the director will use to perform additional tasks (future scoped for director).
    - Depending on which stemcell `api_version` the CPI receives in `context`
      - when the stemcell `api_version` is **>= 2**
        - The CPI does not update the registry.
        - Adds the agent settings into the [user_metadata](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L45-L54) when it send the [create instance](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_core.rb#L94-L102) request to the IaaS.
      - when the stemcell `api_version` is **< 2**
        - The CPI should call `update_registry` with all the required [agent settings](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L58-L60). This is the same as in V1.

  - `delete_vm`:
    - No changes in the API contract.
    - Depending on which stemcell `api_version` the CPI receives in `context`
      - When the stemcell `api_version` is **>= 2**
        - The new CPI does not attempt to delete `instance_id` from the registry, as the `instance_id` will not exist in registry to begin with.
      - When the stemcell `api_version` is **< 2**
        - The CPI calls [Delete entry](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L110) with `instance_id`, which is the same behaviour as in V1.

  - `attach_disk`:
    - Returns `disk_hints`, which will be used by director to perform additional tasks
      - The format of `disk_hints` did not change; it is the same as the values put into the registry in the context of the V1 contract.
      - Examples:
        ```
        Older CPIs update settings with disk settings as strings
        e.g "/dev/sdc"
      	    "3"
        Newer CPIs returns settings as a hash:
      	e.g {"path" => "/dev/sdc"}
      	    {"volume_id" => "3"}
      	    {"lun" => "0", "host_device_id" => "{host-device-id}"}
        ```
    - Depending on which stemcell `api_version` the CPI receives in `context`
      - When the stemcell `api_version` is **>= 2**
        - The CPI does not try to update the registry with `disk_hints`.
      - When sthe temcell `api_version` is **< 2**
        - The CPI [updates the registry](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/1d7c31ec1ea0bb65a287adfc1898810a615218b8/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L76-L80) with `disk_hints`, which is the same behaviour as in V1.


  - `detach_disk`:
    - No changes in the API contract
    - Depending on which stemcell `api_version` the CPI receives in `context`
      - When the stemcell `api_version` is **>= 2**
        - The CPI does not try to delete the `disk_id` entry in the agent settings inside the registry.
      - When the stemcell `api_version` is **< 2**
        - The CPI  [deletes](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/1d7c31ec1ea0bb65a287adfc1898810a615218b8/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L94-L98) `disk_id` from the agent settings inside the registry, which is the same behaviour as in V1.

##### Agent changes in V2 of the API contract:

- The BOSH agent will leverage the IaaS' metadata service to obtain its settings (for `settings.json`) before falling back to the registry (if the full settings were not fetched or if there is no `agent_id` in the current settings).

- The `mount_disk` action accepts disk hints along with the disk cid. It stores the disk hints in `persistent_disk_hints.json`. It will then mount the disk.
- The `unmount_disk` action unmounts the disk according to what is stored in `persistent_disk_hints.json` and then removes the disk entry from the file.
- The `update_persistent_disk` action stores disk hints locally in `persistent_disk_hints.json`.


##### Stemcell changes in V2 of the API contract:

`stemcell.MF` must contain an `api_version: 2` entry if the stemcell has a V2-compatible agent installed. This will enable the director, CPI and cli to run in registry-less mode. If the entry is missing, the agent will fallback to the V1 contract and use the registry.

```yaml
---
#### stemcell api_version
api_version: 2
name: bosh-aws-xen-hvm-ubuntu-xenial-go_agent
version: '621.74'
bosh_protocol: '1'
sha1: da39a3ee5e6b4b0d3255bfef95601890afd80709
operating_system: ubuntu-xenial
stemcell_formats:
- aws-light
cloud_properties:
  ami:
    us-east-1: ami-xxxxxx
    us-west-1: ami-xxxxxx
```

### Updating existing CPIs for registry-less operation
!!! note
    CPIs implementing the V2 contract must also fully support the V1 API contract.

##### Ruby ![](https://cdn.emojidex.com/emoji/mdpi/Ruby.png)

- Update the CPI Ruby gem to [v2.5.0](https://github.com/cloudfoundry/bosh-cpi-ruby/releases/tag/v2.5.0)

  ```
  gem install bosh_cpi -v 2.5.0
  ```

- For reference code you can check the updated [cloud_v2.rb](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb) in bosh-aws-cpi.

##### GoLang ![](cpi-api-v2-method/gopher.jpg)

- Update [the CPI GO library](https://github.com/cppforlife/bosh-cpi-go) to the latest version:
  ```
  go get -u github.com/cppforlife/bosh-cpi-go
  ```
- For reference code, see these CPIs using the library:
    - [Warden CPI](https://github.com/cppforlife/bosh-warden-cpi-release)
    - [VirtualBox CPI](https://github.com/cppforlife/bosh-virtualbox-cpi-release)
    - [Docker CPI](https://github.com/cppforlife/bosh-docker-cpi-release)
    - [Kubernetes CPI](https://github.com/bosh-cpis/bosh-kubernetes-cpi-release)

---

### Reference pipeline to test a CPI with all combinations of the Director, CLI and  Stemcell
This pipeline will use all permutations of the V1 and V2 contracts for the director, CLI and stemcell:
[Pipeline for CPI V2 testing](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/49447ba7ee208c31dddc1b7e3ec2a5f05c88ea99/ci/pipeline_cpi_v2.yml.erb)

**NOTE:** A few other factors must be considered.

- Which version of the cpi API is specified in `cpi.json`.
- Director using the V1 or V2 API contract
  - For testing, the director is specifying [`director.cpi_api_test_max_version`](https://github.com/cloudfoundry-incubator/bosh-cpi-certification/blob/82dcf1843a1c617e73b59e4640af2090e9e0c37f/aws/assets/ops/director_cpi_version.yml) in its properties to use only the specified version of CPI contract.
- On the CPI side you can specify `debug.cpi.api_version` for debugging. Examples:
  - [spec](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/jobs/aws_cpi/spec#L14-L16)

  ```yaml
   debug.cpi.api_version:
      description: api_version supported by cpi (can be used as an override for fallback).
      default: null
  ```
  - [cpi.json](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/jobs/aws_cpi/templates/cpi.json.erb#L34-L38)
  - [config.rb](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/1d7c31ec1ea0bb65a287adfc1898810a615218b8/src/bosh_aws_cpi/lib/cloud/aws/config.rb#L75-L109) to load debug version if specified.
