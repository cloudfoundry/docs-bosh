---
title: Manifest v2 Schema
---

<p class="note">Note: This feature is available with bosh-release v255.4+.</p>

<p class="note">Warning: If you are using director version between v241 and v256, once you opt into using cloud config all deployments must be converted to use new format. If you want to deploy both v1 and v2 manifests, update to director v257+.</p>

The deployment manifest is a YAML file that defines the components and properties of the deployment. When an operator initiates a new deployment using the CLI, the Director receives a manifest and creates or updates a deployment with matching name.

Assuming that you are using [cloud config](cloud-config.html), your deployment manifest is expected to have:

* [Deployment Identification](#deployment): A name for the deployment and the UUID of the Director managing the deployment
* [Features Block](#features): Opts into Director features to be used in this deployment
* [Releases Block](#releases): Name and version of each release in a deployment
* [Stemcells Block](#stemcells): Name and version of each stemcell in a deployment
* [Update Block](#update): Defines how BOSH updates instances during deployment
* [Instance Groups Block](#instance-groups): Configuration and resource information for instance groups
* [Addons](#addons): Configures deployment specific addons
* [Properties Block](#properties): Describes global properties and generalized configuration information
* [Variables Block](#variables): Variables configuration
* [Tags Block](#tags): Sets additional tags for the deployment

---
## <a id='deployment'></a> Deployment Identification

**name** [String, required]: The name of the deployment. A single Director can manage multiple deployments and distinguishes them by name.

**director_uuid** [String, required]: Not required by CLI v2. This string must match the UUID of the currently targeted Director for the CLI to allow any operations on the deployment. Use `bosh status` to display the UUID of the currently targeted Director.

Example:

```yaml
name: my-redis
```

---
## <a id='features'></a> Features Block

**features** [Hash, options]: Specifies Director features that should be used within this deployment.

* **use\_dns\_addresses** [Boolean, optional]: Enables or disables returning of DNS addresses in links. Defaults to global Director `use_dns_addresses` configuration.

Example:

```yaml
features:
  use_dns_addresses: true
```

---
## <a id='releases'></a> Releases Block

**releases** [Array, required]: The name and version of each release in the deployment.

* **name** [String, required]: Name of a release used in the deployment.
* **version** [String, required]: The version of the release to use. Version can be `latest`.
* **url** [String, optional]: URL of a release to download. Works with CLI v2.
* **sha1** [String, optional]: SHA1 of asset referenced via URL. Works with CLI v2.

Example:

```yaml
releases:
- name: redis
  version: 12
```

Example with a URL:

```yaml
releases:
- name: concourse
  version: 3.3.2
  url: https://bosh.io/d/github.com/concourse/concourse?v=3.3.2
  sha1: 2c876303dc6866afb845e728eab58abae8ff3be2
```

---
## <a id='stemcells'></a> Stemcells Block

**stemcells** [Array, required]: The name and version of each stemcell in the deployment.

* **alias** [String, required]: Name of a stemcell used in the deployment
* **os** [String, optional]: Operating system of a matching stemcell. Example: `ubuntu-trusty`.
* **version** [String, required]: The version of a matching stemcell. Version can be `latest`.
* **name** [String, optional]: Full name of a matching stemcell. Either `name` or `os` keys can be specified.

Example:

```yaml
stemcells:
- alias: default
  os: ubuntu-trusty
  version: 3147
- alias: default2
  name: bosh-aws-xen-hvm-ubuntu-trusty-go_agent
  version: 3149
```

---
## <a id='update'></a> Update Block

**update** [Hash, required]: This specifies instance update properties. These properties control how BOSH updates instances during the deployment.

* **canaries** [Integer, required]: The number of [canary](./terminology.html#canary) instances.
* **max\_in\_flight** [Integer, required]: The maximum number of non-canary instances to update in parallel.
* **canary\_watch\_time** [Integer or Range, required]: Only applies to monit start operation.
    * If the `canary_watch_time` is an integer, the Director sleeps for that many milliseconds, then checks whether the canary instances are healthy.
    * If the `canary_watch_time` is a range (low-high), the Director:
        * Waits for `low` milliseconds
        * Waits until instances are healthy or `high` milliseconds have passed since instances started updating
* **update\_watch\_time** [Integer or Range, required]: Only applies to monit start operation.
    * If the `update_watch_time` is an integer, the Director sleeps for that many milliseconds, then checks whether the instances are healthy.
    * If the `update_watch_time` is a range (low-high), the Director:
        * Waits for `low` milliseconds
        * Waits until instances are healthy or `high` milliseconds have passed since instances started updating
* **serial** [Boolean, optional]: If disabled (set to `false`), instance groups will be deployed in parallel, otherwise - sequentially. Instances within a group will still follow `canary` and `max_in_flight` configuration. Defaults to `true`.

See [job lifecycle](job-lifecycle.html) for more details on startup/shutdown procedure within each VM.

Example:

```yaml
update:
  canaries: 1
  max_in_flight: 10
  canary_watch_time: 1000-30000
  update_watch_time: 1000-30000
```

---
## <a id='instance-groups'></a> Instance Groups Block

**instance_groups** [Array, required]: Specifies the mapping between release [jobs](./terminology.html#job) and instance groups.

* **name** [String, required]: A unique name used to identify and reference instance group.
* **azs** [Array, required]: List of AZs associated with this instance group (should only be used when using [first class AZs](azs.html)). Example: `[z1, z2]`.
* **instances** [Integer, required]: The number of instances in this group. Each instance is a VM.
* **jobs** [Array, required]: Specifies the name and release of jobs that will be installed on each instance.
  * **name** [String, required]: The job name
  * **release** [String, required]: The release where the job exists
  * **consumes** [Hash, optional]: Links consumed by the job. [Read more about link configuration](links.html#deployment)
  * **provides** [Hash, optional]: Links provided by the job. [Read more about link configuration](links.html#deployment)
  * **properties** [Hash, optional]: Specifies job properties. Properties allow BOSH to configure jobs to a specific environment. `properties` defined in a Job block are accessible only to that job. Only properties specified here will be provided to the job.
* **vm_type** [String, required]: A valid VM type name from the cloud config.
* **vm_extensions** [Array, optional]: A valid list of VM extension names from the cloud config.
* **stemcell** [String, required]: A valid stemcell alias from the Stemcells Block.
* **persistent\_disk\_type** [String, optional]: A valid disk type name from the cloud config. [Read more about persistent disks](./persistent-disks.html)
* **networks** [Array, required]: Specifies the networks this instance requires. Each network can have the following properties specified:
  * **name** [String, required]: A valid network name from the cloud config.
  * **static_ips** [Array, optional]: Array of IP addresses reserved for the instances on the network.
  * **default** [Array, optional]: Specifies which network components (DNS, Gateway) BOSH populates by default from this network. This property is required if more than one network is specified.
* **update** [Hash, optional]: Specific update settings for this instance group. Use this to override [global job update settings](#update) on a per-instance-group basis.
* **migrated_from** [Array, optional]: Specific migration settings for this instance group. Use this to [rename and/or migrate instance groups](migrated-from.html).
* **lifecycle** [String, optional]: Specifies the kind of workload the instance group represents. Valid values are `service` and `errand`; defaults to `service`. A `service` runs indefinitely and restarts if it fails. An `errand` starts with a manual trigger and does not restart if it fails.
* **properties** [Hash, optional]: Specifies instance group properties. Deprecated in favor of job level properties and links.
* **env** [Hash, optional]: Specifies advanced BOSH Agent configuration for each instance in the group.
  * **bosh** [Hash, optional]:
      * **password** [String, optional]: Crypted password for `vcap/root` user (will be placed into /etc/shadow on Linux).
      * **keep\_root\_password** [Boolean, optional]: Keep password for `root` and only change password for `vcap`. Default: `false`.
      * **remove\_dev\_tools** [Boolean, optional]: Remove [compilers and dev tools](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/blob/master/stemcell_builder/stages/dev_tools_config/assets/generate_dev_tools_file_list_ubuntu.sh) on non-compilation VMs. Default: `false`.
      * **remove\_static\_libraries** [Boolean, optional]: Remove [static libraries](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/blob/master/stemcell_builder/stages/static_libraries_config/assets/static_libraries_list.txt) on non-compilation VMs. Default: `false`.
      * **swap\_size** [Integer, optional]: Size of swap partition in MB to create. Set this to 0 to avoid having a swap partition created. Default: RAM size of used VM type up to half of the ephemeral disk size.

Example:

```yaml
instance_groups:
- name: redis-master
  instances: 1
  azs: [z1, z2]
  jobs:
  - name: redis-server
    release: redis
    properties:
      port: 3606
  vm_type: medium
  vm_extensions: [public-lbs]
  stemcell: default
  persistent_disk_type: medium
  networks:
  - name: default

- name: redis-slave
  instances: 2
  azs: [z1, z2]
  jobs:
  - name: redis-server
    release: redis
    properties: {}
  vm_type: medium
  stemcell: default
  persistent_disk_type: medium
  networks:
  - name: default
```

---
## <a id='addons'></a> Addons Block

**addons** [Array, required]: Specifies the [addons](./terminology.html#addon) to be applied to this deployments.

See [Addons Block](runtime-config.html#addons) for the schema.

Unlike addons specified in a runtime config, addons specified in the deployment manifest do not respect inclusion and exclusion rules for `deployments`.

Example:

```
addons:
- name: logging
  jobs:
  - name: logging-agent
    release: logging
    properties:
      ...
```

---
## <a id='properties'></a> Properties Block

**properties** [Hash, optional]: Describes global properties. Deprecated in favor of job level properties and links.

---
## <a id='variables'></a> Variables Block

**variables** [Array, optional]: Describes variables.

* **name** [String, required]: Unique name used to identify a variable. Example: `admin_password`
* **type** [String, required]: Type of a variable. Currently supported variable types are `certificate`, `password`, `rsa`, and `ssh`. Example: `password`.
* **options** [Hash, optional]: Specifies generation options used for generating variable value if variable is not found. Example: `{is_ca: true, common_name: some-ca}`

Example:

```
variables:
- name: admin_password
  type: password
- name: default_ca
  type: certificate
  options:
    is_ca: true
    common_name: some-ca
- name: director_ssl
  type: certificate
  options:
    ca: default_ca
    common_name: cc.cf.internal
    alternative_names: [cc.cf.internal]
```

See [CLI Variable Interpolation](cli-int.html) for more details about variables.

---
## <a id='tags'></a> Tags Block

**tags** [Hash, optional]: Specifies key value pairs to be sent to the CPI for VM tagging. Combined with runtime config level tags during the deploy. Available in bosh-release v258+.

Example:

```yaml
tags:
  project: cf
```
