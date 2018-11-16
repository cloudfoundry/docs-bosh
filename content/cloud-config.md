!!! warning
    If you are using Director version between v241 and v256, once you opt into using cloud config all deployments must be converted to use new format. If you want to deploy both v1 and v2 manifests, update to Director v257+.

Previously each deployment manifest specified IaaS and IaaS agnostic configuration in a single file. As more deployments are managed by the Director, it becomes inconvenient to keep shared IaaS configuration in sync in all deployment manifests. In addition, multiple deployments typically want to use the same network subnet, hence IP ranges need to be separated and reserved.

The cloud config is a YAML file that defines IaaS specific configuration used by the Director and all deployments. It allows us to separate IaaS specific configuration into its own file and keep deployment manifests IaaS agnostic.

---
## Updating and retrieving cloud config {: #update }

To update cloud config on the Director use [`bosh update-cloud-config` command](cli-v2.md#update-cloud-config).

!!! note
    See [example cloud config](#example) for AWS below.

```shell
$ bosh -e vbox update-cloud-config cloud.yml

$ bosh -e vbox cloud-config
Acting as user 'admin' on 'micro'

azs:
- name: z1
  cloud_properties:
    availability_zone: us-east-1b
- name: z2
  cloud_properties:
    availability_zone: us-east-1c
...
```

Once cloud config is updated, all existing deployments will be considered outdated, as indicated by [`bosh deployments` command](cli-v2.md#deployments). The Director will apply cloud config changes to each deployment during the next run of `bosh deploy` command for that deployment.

```shell
$ bosh -e vbox deployments
Using environment '192.168.56.6' as '?'

Name       Release(s)       Stemcell(s)             Team(s)  Cloud Config
zookeeper  zookeeper/0.0.5  bosh-warden-.../3421.4  -        outdated

1 deployment

Succeeded
```

---
## Example {: #example }

```yaml
azs:
- name: z1
  cloud_properties: {availability_zone: us-east-1a}
- name: z2
  cloud_properties: {availability_zone: us-east-1b}

vm_types:
- name: small
  cloud_properties:
    instance_type: t2.micro
    ephemeral_disk: {size: 3000, type: gp2}
- name: medium
  cloud_properties:
    instance_type: m3.medium
    ephemeral_disk: {size: 30000, type: gp2}

disk_types:
- name: small
  disk_size: 3000
  cloud_properties: {type: gp2}
- name: large
  disk_size: 50_000
  cloud_properties: {type: gp2}

networks:
- name: private
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    az: z1
    static: [10.10.0.62]
    dns: [10.10.0.2]
    cloud_properties: {subnet: subnet-f2744a86}
  - range: 10.10.64.0/24
    gateway: 10.10.64.1
    az: z2
    static: [10.10.64.121, 10.10.64.122]
    dns: [10.10.0.2]
    cloud_properties: {subnet: subnet-eb8bd3ad}
- name: vip
  type: vip

compilation:
  workers: 5
  reuse_compilation_vms: true
  az: z1
  vm_type: medium
  network: private
```

- [See AWS CPI example](aws-cpi.md#cloud-config)
- [See Azure CPI example](azure-cpi.md#cloud-config)
- [See OpenStack CPI example](openstack-cpi.md#cloud-config)
- [See SoftLayer CPI example](softlayer-cpi.md#cloud-config)
- [See Google Cloud Platform CPI example](google-cpi.md#cloud-config)
- [See vSphere CPI example](vsphere-cpi.md#cloud-config)

---
## AZs Block {: #azs }

**azs** [Array, required]: Specifies the AZs available to deployments. At least one should be specified.

* **name** [String, required]: Name of an AZ within the Director.
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties needed to associated with AZ; for most IaaSes, some data here is actually required. See [CPI Specific `cloud_properties`](#azs-cloud-properties) below. Example: `availability_zone`. Default is `{}` (empty Hash).

See [first class AZs](azs.md) for more details.

Example:

```yaml
azs:
- name: z1
  cloud_properties:
    availability_zone: us-east-1c
- name: z2
  cloud_properties:
    availability_zone: us-east-1d
```

### CPI Specific `cloud_properties` {: #azs-cloud-properties }

- [See AWS CPI AZ cloud properties](aws-cpi.md#azs)
- [See Azure CPI AZ cloud properties](azure-cpi.md#azs)
- [See OpenStack CPI AZ cloud properties](openstack-cpi.md#azs)
- [See SoftLayer CPI AZ cloud properties](softlayer-cpi.md#azs)
- [See Google Cloud Platform CPI AZ cloud properties](google-cpi.md#azs)
- [See vSphere CPI AZ cloud properties](vsphere-cpi.md#azs)
- [See vCloud CPI AZ cloud properties](vcloud-cpi.md#azs)

---
## Networks Block {: #networks }

**networks** [Array, required]: Each sub-block listed in the Networks block specifies a network configuration that jobs can reference. There are three different network types: `manual`, `dynamic`, and `vip`. At least one should be specified.

See [networks](networks.md) for more details.

### CPI Specific `cloud_properties` {: #networks-cloud-properties }

- [See AWS CPI network cloud properties](aws-cpi.md#networks)
- [See Azure CPI network cloud properties](azure-cpi.md#networks)
- [See OpenStack CPI network cloud properties](openstack-cpi.md#networks)
- [See SoftLayer CPI network cloud properties](softlayer-cpi.md#networks)
- [See Google Cloud Plaform CPI network cloud properties](google-cpi.md#networks)
- [See vSphere CPI network cloud properties](vsphere-cpi.md#networks)
- [See vCloud CPI network cloud properties](vcloud-cpi.md#networks)

---
## VM Types Block {: #vm-types }

**vm_types** [Array, required]: Specifies the [VM types](terminology.md#vm-type) available to deployments. At least one should be specified.

* **name** [String, required]: A unique name used to identify and reference the VM type
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties needed to create VMs; for most IaaSes, some data here is actually required. See [CPI Specific `cloud_properties`](#vm-types-cloud-properties) below. Example: `instance_type: m3.medium`. Default is `{}` (empty Hash).

Example:

```yaml
vm_types:
- name: default
  cloud_properties:
    instance_type: m1.small
```

### CPI Specific `cloud_properties` {: #vm-types-cloud-properties }

- [See AWS CPI VM types cloud properties](aws-cpi.md#resource-pools)
- [See Azure CPI VM types cloud properties](azure-cpi.md#resource-pools)
- [See OpenStack CPI VM types cloud properties](openstack-cpi.md#resource-pools)
- [See SoftLayer CPI VM types cloud properties](softlayer-cpi.md#resource-pools)
- [See Google Cloud Platform CPI VM types cloud properties](google-cpi.md#resource-pools)
- [See vSphere CPI VM types cloud properties](vsphere-cpi.md#resource-pools)
- [See vCloud CPI VM types cloud properties](vcloud-cpi.md#resource-pools)

---
## VM Extensions Block {: #vm-extensions }

!!! note
    This feature is available with bosh-release v255.4+.

**vm_extensions** [Array, optional]: Specifies the [VM extensions](terminology.md#vm-extension) available to deployments.

* **name** [String, required]: A unique name used to identify and reference the VM extension
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties needed to configure VMs. Example: `elbs: [...]`. Default is `{}` (empty Hash).

Example:

```yaml
vm_extensions:
- name: pub-lbs
  cloud_properties:
    elbs: [main]
```

Any IaaS specific configuration could be placed into a VM extension's `cloud_properties`.

---
## Disk Types Block {: #disk-types }

**disk_types** [Array, required]: Specifies the [disk types](terminology.md#disk-types) available to deployments. At least one should be specified.

* **name** [String, required]: A unique name used to identify and reference the disk type
* **disk_size** [Integer, required]: Specifies the disk size. `disk_size` must be a positive integer. BOSH creates a [persistent disk](persistent-disks.md) of that size in megabytes and attaches it to each job instance VM.
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties needed to create disks. Examples: `type`, `iops`. Default is `{}` (empty Hash).

Example:

```yaml
disk_types:
- name: default
  disk_size: 2
  cloud_properties:
    type: gp2
```

### CPI Specific `cloud_properties` {: #disk-types-cloud-properties }

- [See AWS CPI disk type cloud properties](aws-cpi.md#disk-pools)
- [See Azure CPI disk type cloud properties](azure-cpi.md#disk-pools)
- [See OpenStack CPI disk type cloud properties](openstack-cpi.md#disk-pools)
- [See SoftLayer CPI disk type cloud properties](softlayer-cpi.md#disk-pools)
- [See Google Cloud Platform CPI disk type cloud properties](google-cpi.md#disk-pools)
- [See vSphere CPI disk type cloud properties](vsphere-cpi.md#disk-pools)
- [See vCloud CPI disk type cloud properties](vcloud-cpi.md#disk-pools)

---
## Compilation Block {: #compilation }

The Director creates compilation VMs for release compilation. The Director will compile each release on every necessary stemcell used in a deployment. A compilation definition allows to specify VM characteristics.

**compilation** [Hash, required]: Properties of compilation VMs.

* **workers** [Integer, required]: The maximum number of compilation VMs.
* **az** [String, required]: Name of the AZ defined in AZs section to use for creating compilation VMs.
* **vm_type** [String, optional]: Name of the VM type defined in VM types section to use for creating compilation VMs. Alternatively, you can specify the `vm_resources`, or `cloud_properties` key.
* **orphan_workers** [Boolean, optional]: When enabled, BOSH will orphan compilation VMs after they finishing compiling packages for the VMs to be deleted asynchronously (instead of blocking the deployment). Default `false`. Available in bosh-release v267+.
* **vm_resources** [Hash, optional]: Specifies generic VM resources such as CPU, RAM and disk size that are automatically translated into correct VM cloud properties to determine VM size. VM size is determined on best effort basis as some IaaSes may not support exact size configuration. Currently some CPIs (Google and Azure) do not support this functionality. Available in bosh-release v264+.
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties needed to create VMs. Most IaaSes require this. Examples: `instance_type`, `availability_zone`. Default is `{}` (empty Hash).
* **network** [String, required]: References a valid network name defined in the Networks block. BOSH assigns network properties to compilation VMs according to the type and properties of the specified network.
* **reuse\_compilation\_vms** [Boolean, optional]: If `false`, BOSH creates a new compilation VM for each new package compilation and destroys the VM when compilation is complete. If `true`, compilation VMs are re-used when compiling packages. Defaults to `false`.
* **env** [Hash, optional]: Same as [`env` for instance groups](manifest-v2.md#instance-groups).

Example:

```yaml
compilation:
  workers: 2
  reuse_compilation_vms: true
  az: z1
  vm_type: default
  network: private
```
