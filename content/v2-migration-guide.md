## Migrating from V1 to V2 contracts

##### CPI Changes with V2 contracts:

  - CPI [`info`](cpi-api-v2-method/info.md) method exposes supported `api_version`.
  - CPI [`create_vm`](cpi-api-v2-method/create-vm.md) method returns an array of vm_id, network_info.
  - CPI [`attach_disk`](cpi-api-v2-method/attach-disk.md) method returns disk hints.
  - CPI [`detach_disk`](cpi-api-v2-method/detach-disk.md) method has no changes.
  - CPI [`delete_vm`](cpi-api-v2-method/delete-vm.md) method has no changes.

##### V2 flow depending on registry availability (all examples are from `bosh-aws-cpi`)

  - `create_vm`:
    - Returns `network_info`, that director will use to perform additional tasks (future scoped for director).
    - Depending on which stemcell `api_version` CPI receives in `context`
      - when stemcell `api_version` is **>= 2**
        - CPI does not update registry.
        - Adds the agent settings into the [user_metadata](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L45-L54) when it send request to IaaS to [create instance](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_core.rb#L94-L102).
      - when stemcell `api_version` is **< 2**
        - it should `update_registry` with all required [agent settings](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L58-L60) same as V1.

  - `delete_vm`:
    - No changes in api contract.
    - Depending on which stemcell `api_version` CPI receives in `context`
      - When stemcell `api_version` is **>= 2**
        - New CPI doesn't attempt try to delete `instance_id` from registry, as the `instance_id` will not exist in registry to begin with.
      - When stemcell `api_version` is **< 2**
        - [Delete entry](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L110) with `instance_id` same as V1.

  - `attach_disk`:
    - Returns `disk_hints` which will be used by director to perform additional tasks
      - `disk_hints` format did not change; it is the same as the values put into registry from V1 contract.
      - Examples:
        ```
        Older CPIs updates settings with disk settings as strings
        e.g "/dev/sdc"
      	    "3"
        Newer CPIs returns settings with a hash:
      	e.g {"path" => "/dev/sdc"}
      	    {"volume_id" => "3"}
      	    {"lun" => "0", "host_device_id" => "{host-device-id}"}
        ```
    - Depending on which stemcell `api_version` CPI receives in `context`
      - When stemcell `api_version` is **>= 2**
        - It doesn't try to update registry with `disk_hints`.
      - When stemcell `api_version` is **< 2**
        - It [updates the registry](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/1d7c31ec1ea0bb65a287adfc1898810a615218b8/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L76-L80) with `disk_hints` same as V1.


  - `detach_disk`:
    - No changes in api contract
    - Depending on which stemcell `api_version` CPI receives in `context`
      - When stemcell `api_version` is **>= 2**
        - It doesn't try to delete `disk_id` entry in agent settings in registry.
      - When stemcell `api_version` is **< 2**
        - It  [deletes](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/1d7c31ec1ea0bb65a287adfc1898810a615218b8/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb#L94-L98) `disk_id` from agent settings from registry same as V1.

##### Agent changes with V2 contracts:

- Agent will check metadata service (depending on IaaS) to get settings (for `settings.json`) before falling back to registry (if the full settings was not fetched; no `agent_id` in the current settings).

- Agent `mount_disk` accepts disk hints along with the disk cid. It stores the disk hints in `persistent_disk_hints.json`. It will then mount the disk.
- Agent `unmount_disk` unmounts the disk according to what is stored in `persistent_disk_hints.json` and then remove the disk entry from the file.
- Agent `update_persistent_disk` method stores disk hints locally on `persistent_disk_hints.json`.


##### Stemcell changes with V2 contracts:

`stemcell.MF` should contain `api_version` if it contains a V2 supported agent in it, so that the director, CPI and cli can use registry-less operations. In order to get new behaviour `api_version: 2` must be present in `stemcell.MF`, or it will be default to version 1.

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

### Migration steps
!!! note
    CPI V2 must fully support the V1 api contract.

##### Ruby ![](https://cdn.emojidex.com/emoji/mdpi/Ruby.png)

- Update your gem in CPI to [v2.5.0](https://github.com/cloudfoundry/bosh-cpi-ruby/releases/tag/v2.5.0)

  ```
  gem install bosh_cpi -v 2.5.0
  ```

- For code reference you can check each method in the updated [cloud_v2.rb](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/src/bosh_aws_cpi/lib/cloud/aws/cloud_v2.rb) in bosh-aws-cpi

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

- Which version of cpi is specified in `cpi.json`.
- Usage of V2 vs V1 director
  - For testing, the director is specifying [`director.cpi_api_test_max_version`](https://github.com/cloudfoundry-incubator/bosh-cpi-certification/blob/82dcf1843a1c617e73b59e4640af2090e9e0c37f/aws/assets/ops/director_cpi_version.yml) in its properties to use only the specified version of CPI.
- On CPI side you can specify `debug.cpi.api_version` for debugging. Examples:
  - [spec](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/jobs/aws_cpi/spec#L14-L16)

  ```yaml
   debug.cpi.api_version:
      description: api_version supported by cpi (can be used as an override for fallback).
      default: null
  ```
  - [cpi.json](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/f27c51db1930d1d4c12cbbf074962380377e9e74/jobs/aws_cpi/templates/cpi.json.erb#L34-L38)
  - [config.rb](https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/1d7c31ec1ea0bb65a287adfc1898810a615218b8/src/bosh_aws_cpi/lib/cloud/aws/config.rb#L75-L109) to load debug version if specified.
