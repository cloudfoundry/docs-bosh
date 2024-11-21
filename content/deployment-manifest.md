!!! note
    Once you opt into using cloud config all deployments must be converted to use manifest v2 format that disallows IaaS specific configuration. See [manifest v2 schema](manifest-v2.md) for allowed configurations. v257+ supports deploying both v1 and v2 manifests to the same director.

The deployment manifest is a YAML file that defines the components and properties of the deployment. When an operator initiates a new deployment using the CLI, the Director receives a version of the deployment manifest and creates a new deployment using this manifest.

Contents of a deployment manifest:

* [Deployment Identification](#deployment): A name for the deployment and the UUID of the Director managing the deployment
* [Releases Block](#releases): Name and version of each release in a deployment
* [Networks Block](#networks): Network configuration information
* [Resource Pools Block](#resource-pools): Properties of VMs that BOSH creates and manages
* [Disk Pools Block](#disk-pools): Properties of disk pools that BOSH creates and manages
* [Compilation Block](#compilation): Properties of compilation VMs
* [Update Block](#update): Defines how BOSH updates job instances during deployment
* [Jobs Block](#jobs): Configuration and resource information for jobs
* [Properties Block](#properties): Describes global properties and generalized configuration information

The examples below originate from a [sample deployment manifest](sample-manifest.md).

---
## Deployment Identification {: #deployment }

**name** [String, required]: The name of the deployment. A single Director can manage multiple deployments and distinguishes them by name.

**director_uuid** [String, required]: This string must match the UUID of the currently targeted Director for the CLI to allow any operations on the deployment. Use `bosh status` to display the UUID of the currently targeted Director.

Example:

```yaml
name: my-redis-deployment

director_uuid: cf8dc1fc-9c42-4ffc-96f1-fbad983a6ce6
```

---
## Releases Block {: #releases }

**releases** [Array, required]: The name and version of each release in the deployment.

* **name** [String, required]: Name of a release used in the deployment.
* **version** [String, required]: The version of the release to use. Version can be `latest`.

Example:

```yaml
releases:
- {name: redis, version: 12}
```

### Releases Block using URLs {: #bosh-init-releases }

**releases** [Array, required]: The name, url and possibly SHA1 of each release in the deployment.

* **name** [String, required]: Name of a release used in the deployment.
* **url** [String, required]: URL of the release to use. URL may use the file protocol (`file://`) or HTTP(s) (`http(s)://`). File URLs can be absolute or relative to the current directory of `bosh-init` execution.
* **sha1** [String, required]: The SHA1 of the release tarball. SHA1 is only required when using HTTP(s) URLs.

Example:

```yaml
releases:
- name: bosh
  url: https://bosh.io/d/github.com/cloudfoundry/bosh?v=158
  sha1: a97811864b96bee096477961b5b4dadd449224b4
- name: bosh-aws-cpi
  url: file://bosh-aws-cpi-release-158.tgz
```

### Releases Block using local release directory {: #bosh-releases-create }

**releases** [Array, required]: The name and local release directory of a release in the deployment.

* **name** [String, required]: Name of a release used in the deployment.
* **url** [String, required]: Path to release directory on local filesystem (relative to working directory).
* **version** [String, required]: Must be `create`

Example:

```yaml
releases:
- name: bosh-aws-cpi
  url: /Users/cloudfoundry/workspace/bosh-aws-cpi-release
  version: create
```

---
## Networks Block {: #networks }

**networks** [Array, required]: Each sub-block listed in the Networks block specifies a network configuration that jobs can reference. There are three different network types: `manual`, `dynamic`, and `vip`.

See [networks](networks.md) for more details.

### CPI Specific `cloud_properties` {: #networks-cloud-properties }

- [See AWS CPI network cloud properties](aws-cpi.md#networks)
- [See Azure CPI network cloud properties](azure-cpi.md#networks)
- [See OpenStack CPI network cloud properties](openstack-cpi.md#networks)
- [See Google Cloud Platform CPI network cloud properties](google-cpi.md#networks)
- [See vSphere CPI network cloud properties](vsphere-cpi.md#networks)

---
## Resource Pools Block {: #resource-pools }

**resource_pools** [Array, required]: Specifies the [resource pools](terminology.md#resource-pool) a deployment uses. A deployment manifest can describe multiple resource pools and uses unique names to identify and reference them.

* **name** [String, required]: A unique name used to identify and reference the resource pool
* **network** [String, required]: References a valid network name defined in the Networks block. Newly created resource pool VMs use the described configuration.
* **size** [Integer, optional]: The number of VMs in the resource pool. If you omit this value, BOSH calculates the resource pool size based on the total number of job instances that belong to this resource pool. If you specify this value, BOSH requires that the size be at least as large as the total number of job instances using it.
* **stemcell** [Hash, required]: The stemcell used to create resource pool VMs.
    * **name** [String, required]: The stemcell name
    * **version** [String, required]: The stemcell version
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties needed to create VMs. Most IaaSes require this. See [CPI Specific `cloud_properties`](#resource-pools-cloud-properties) below. Examples: `instance_type`, `availability_zone`. Default is `{}` (empty Hash).
* **env** [Hash, optional]: Describes the VM environment and provides a specific VM environment to the CPI `create_stemcell` call. `env` data is available to BOSH Agents as VM settings. Default is `{}` (empty Hash).

Example:

```yaml
resource_pools:
- name: redis-servers
  network: default
  stemcell:
    name: bosh-aws-xen-ubuntu-xenial-go_agent
    version: 621.74
  cloud_properties:
    instance_type: m1.small
    availability_zone: us-east-1c
```

### Custom bosh-init Stemcell Key Schema {: #bosh-init-stemcells }

**stemcell** [Hash, required]: The stemcell used to create resource pool VMs.

  - **url** [String, required]: URL of the stemcell tarball. URL may use the file protocol (`file://`) or HTTP(s) (`http(s)://`). File URLs can be absolute or relative to the current directory of `bosh-init` execution.
  - **sha1** [String, required]: The SHA1 of the stemcell tarball. SHA1 is only required when using HTTP(s) URLs.

Example:

```yaml
resource_pools:
- name: redis-servers
  network: default
  stemcell:
    url: https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-xenial-go_agent?v=621.74
    sha1: 5a81413223bcee987955038dc903345720fc22a4
  cloud_properties:
    instance_type: m1.small
    availability_zone: us-east-1c
```

### CPI Specific `cloud_properties` {: #resource-pools-cloud-properties }

- [See AWS CPI resource pool cloud properties](aws-cpi.md#resource-pools)
- [See Azure CPI resource pool cloud properties](azure-cpi.md#resource-pools)
- [See OpenStack CPI resource pool cloud properties](openstack-cpi.md#resource-pools)
- [See Google Cloud Platform CPI resource pool cloud properties](google-cpi.md#vm-types)
- [See vSphere CPI resource pool cloud properties](vsphere-cpi.md#resource-pools)

---
## Disk Pools Block {: #disk-pools }

**disk_pools** [Array, required]: Specifies the [disk pools](terminology.md#disk-pool) a deployment uses. A deployment manifest can describe multiple disk pools and uses unique names to identify and reference them.

* **name** [String, required]: A unique name used to identify and reference the disk pool
* **disk_size** [Integer, required]: Specifies the disk size. `disk_size` must be a positive integer. BOSH creates a [persistent disk](persistent-disks.md) of that size in megabytes and attaches it to each job instance VM.
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties needed to create disks. Examples: `type`, `iops`. Default is `{}` (empty Hash).

Example:

```yaml
disk_pools:
- name: default
  disk_size: 2
  cloud_properties:
    type: gp2
```

### CPI Specific `cloud_properties` {: #disk-pools-cloud-properties }

- [See AWS CPI disk pool cloud properties](aws-cpi.md#disk-pools)
- [See Azure CPI disk pool cloud properties](azure-cpi.md#disk-pools)
- [See OpenStack CPI disk pool cloud properties](openstack-cpi.md#disk-pools)
- [See Google Cloud Platform CPI disk pool cloud properties](google-cpi.md#disk-types)
- [See vSphere CPI disk pool cloud properties](vsphere-cpi.md#disk-pools)

---
## Compilation Block {: #compilation }

**compilation** [Hash, required]: Properties of compilation VMs.

* **workers** [Integer, required]: The maximum number of compilation VMs.
* **network** [String, required]: References a valid network name defined in the Networks block. BOSH assigns network properties to compilation VMs according to the type and properties of the specified network.
* **reuse\_compilation\_vms** [Boolean, optional]: If `false`, BOSH creates a new compilation VM for each new package compilation and destroys the VM when compilation is complete. If `true`, compilation VMs are re-used when compiling packages. Defaults to `false`.
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties needed to create compilation VMs; for most IaaSes, some data here is actually required. For the Compilation Block, the required `cloud_properties` are the same as for Resource Pools; see the [CPI Specific `cloud_properties`](#resource-pools-cloud-properties) for Resource Pools. Examples: `instance_type`, `availability_zone`. Default is `{}` (empty Hash).

Example:

```yaml
compilation:
  workers: 2
  network: default
  reuse_compilation_vms: true
  cloud_properties:
    instance_type: c1.medium
    availability_zone: us-east-1c
```

---
## Update Block {: #update }

**update** [Hash, required]: This specifies instance update properties. These properties control how BOSH updates job instances during the deployment.

* **canaries** [Integer or Percentage, required]: The number of [canary](terminology.md#canary) instances.
* **max\_in\_flight** [Integer or Percentage, required]: The maximum number of non-canary instances to update in parallel within an availability zone. Updates will not begin in another availability zone until all VMs are updated in the current availability zone.
    * If the `max_in_flight` is a percentage, the minimum `max_in_flight` will never fall below 1.
* **canary\_watch\_time** [Integer or Range, required]
    * If the `canary_watch_time` is an integer, the Director sleeps for that many milliseconds, then checks whether the canary instances are healthy.
    * If the `canary_watch_time` is a range (low-high), the Director:
        * Waits for `low` milliseconds
        * Waits until instances are healthy or `high` milliseconds have passed since instances started updating
* **update\_watch\_time** [Integer or Range, required]
    * If the `update_watch_time` is an integer, the Director sleeps for that many milliseconds, then checks whether the instances are healthy.
    * If the `update_watch_time` is a range (low-high), the Director:
        * Waits for `low` milliseconds
        * Waits until instances are healthy or `high` milliseconds have passed since instances started updating
* **serial** [Boolean, optional]: If disabled (set to `false`), deployment jobs will be deployed in parallel, otherwise - sequentially. Instances within a deployment job will still follow `canary` and `max_in_flight` configuration. Defaults to `true`.

Examples:

```yaml
update:
  canaries: 1
  max_in_flight: 10
  canary_watch_time: 1000-30000
  update_watch_time: 1000-30000
```

```yaml
update:
  canaries: 10%
  max_in_flight: 50%
  canary_watch_time: 1000-30000
  update_watch_time: 1000-30000
  initial_deploy_az_update_strategy: serial
```

---
## Jobs Block {: #jobs }

**jobs** [Array, required]: Specifies the mapping between BOSH release [jobs](terminology.md#job) and cloud instances. Jobs are defined in the BOSH release. The Jobs block defines how BOSH associates jobs with the VMs started by the IaaS. The most commonly used job properties are:

* **name** [String, required]: A unique name used to identify and reference this  association between a BOSH release job and a VM.
* **templates** [Array, required]: Specifies the name and release of a job template.
    * **name** [String, required]: The job template name
    * **release** [String, required]: The release where the job template exists
* **lifecycle** [String, optional]: Specifies the kind of task the job represents. Valid values are `service` and `errand`; defaults to `service`. A `service` runs indefinitely and restarts if it fails. An `errand` starts with a manual trigger and does not restart if it fails.
* **persistent_disk** [Integer, optional]: Specifies the persistent disk size; defaults to 0 (no persistent disk). If `persistent_disk` is a positive integer, BOSH creates a persistent disk of that size in megabytes and attaches it to each job instance VM. [Read more about persistent disks](persistent-disks.md)
* **properties** [Hash, optional]: Specifies job properties. Properties allow BOSH to configure jobs to a specific environment. `properties` defined in a Job block are accessible only to that job, and override any identically named global properties.
* **resource_pool** [String, required]: A valid resource pool name from the Resource Pools block. BOSH runs instances of this job in a VM from the named resource pool.
* **update** [Hash, optional]: Specific update settings for this job. Use this to override [global job update settings](#update) on a per-job basis.
* **instances** [Integer, required]: The number of job instances. Each instance is a VM running this particular job.
* **networks** [Array, required]: Specifies the networks this job requires. Each network can have the following properties specified:
    * **name** [String, required]: A valid network name from the Networks block
    * **static_ips** [Array, optional]: Array of IP addresses reserved for the job on the network
    * **default** [Array, optional]: Specifies which network components (DNS, Gateway) BOSH populates by default from this network. BOSH references this property if the Networks block defines multiple networks.

Example:

```yaml
jobs:
  - name: redis-master
    instances: 1
    templates:
    - {name: redis-server, release: redis}
    persistent_disk: 10_240
    resource_pool: redis-servers
    networks:
    - name: default

  - name: redis-slave
    instances: 2
    templates:
    - {name: redis-server, release: redis}
    persistent_disk: 10_240
    resource_pool: redis-servers
    networks:
    - name: default
```

---
## Properties Block {: #properties }

**properties** [Hash, optional]: Describes global properties and general configuration information.

Global properties allow BOSH to configure jobs to a specific environment. `properties` defined in the [Properties](#properties) block are accessible to all jobs. Any identically named `properties` in the [Jobs](#jobs) block will override the global property for that job.

By default, general configuration information resides in the template spec file of a job in a BOSH release. If you move this information from the release into the manifest, you can reconfigure a deployment by changing the manifest instead of the release. To do this, add the general configuration information to the manifest in a sub-block of the Properties block. The name of the job template identifies the sub-block.

Typical general configuration information includes but is not limited to:

* Passwords
* Account names
* Shared secrets
* Host names
* IP addresses
* Port numbers

Example:

```yaml
properties:
  redis:
    max_connections: 10
```

### Job Property Precedence {: #properties }

1. BOSH applies the properties in the template spec file to the job.
1. If an identically named property exists in the [Properties](#properties) block of the deployment manifest, the value of this property overrides the previous value.
1. If an identically named property exists in the Properties sub-block of the [Jobs](#jobs) block of the deployment manifest, the value of this property overrides all previous values.

!!! note
    If you declare specific properties in a job template spec, BOSH ignores all other properties. If you do not declare any specific properties in a job template spec, BOSH applies all properties from the deployment manifest to the job.

---
## Cloud Provider Block {: #cloud-provider }

**cloud_provider** [Hash, required]: Specifies CPI configuration for the `bosh-init` to create VMs, etc. Regular deployment manifests cannot specify this block.

* **template** [Hash, required]: Specifies the name of the CPI job and release where the CPI job exists. It will be used by the `bosh-init` to create VMs, persistent disks, etc.
    * **name** [String, required]: The CPI job name.
    * **release** [String, required]: The CPI release name.
* **mbus** [String, required]: HTTPs URL used by the `bosh-init` to contact the Agent on a created VM. The URL includes basic auth credentials that should be customized for each deployment. Example: `"https://mbus:mbus-password@10.0.0.6:6868"`.
* **properties** [Hash, required]: Properties required by the CPI job.

Example from [Initializing BOSH environment on vSphere](init-vsphere.md):

```yaml
cloud_provider:
  template: {name: cpi, release: bosh-vsphere-cpi}

  mbus: "https://mbus:mbus-password@10.0.0.6:6868"

  properties:
    vcenter: { ... }

    agent: {mbus: "https://mbus:mbus-password@0.0.0.0:6868"}

    blobstore:
      provider: local
      path: /var/vcap/micro_bosh/data/cache

    ntp:
    - 0.pool.ntp.org
    - 1.pool.ntp.org
```
