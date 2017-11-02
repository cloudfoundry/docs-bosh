---
title: Cloud Config
---

<p class="note">Warning: If you are using Director version between v241 and v256, once you opt into using cloud config all deployments must be converted to use new format. If you want to deploy both v1 and v2 manifests, update to Director v257+.</p>

Previously each deployment manifest specified IaaS and IaaS agnostic configuration in a single file. As more deployments are managed by the Director, it becomes inconvenient to keep shared IaaS configuration in sync in all deployment manifests. In addition, multiple deployments typically want to use the same network subnet, hence IP ranges need to be separated and reserved.

The cloud config is a YAML file that defines IaaS specific configuration used by the Director and all deployments. It allows us to separate IaaS specific configuration into its own file and keep deployment manifests IaaS agnostic.

---
## <a id='update'></a> Updating and retrieving cloud config

To update cloud config on the Director use [`bosh update-cloud-config` command](cli-v2.html#update-cloud-config).

<p class="note">Note: See <a href="#example">example cloud config</a> for AWS below.</p>

<pre class="terminal">
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
</pre>

Once cloud config is updated, all existing deployments will be considered outdated, as indicated by [`bosh deployments` command](cli-v2.html#deployments). The Director will apply cloud config changes to each deployment during the next run of `bosh deploy` command for that deployment.

<pre class="terminal">
$ bosh -e vbox deployments
Using environment '192.168.56.6' as '?'

Name       Release(s)       Stemcell(s)             Team(s)  Cloud Config
zookeeper  zookeeper/0.0.5  bosh-warden-.../3421.4  -        outdated

1 deployment

Succeeded
</pre>

---
## <a id='example'></a> Example

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

- [See AWS CPI example](aws-cpi.html#cloud-config)
- [See Azure CPI example](azure-cpi.html#cloud-config)
- [See OpenStack CPI example](openstack-cpi.html#cloud-config)
- [See Softlayer CPI example](softlayer-cpi.html#cloud-config)
- [See Google Cloud Platform CPI example](google-cpi.html#cloud-config)
- [See vSphere CPI example](vsphere-cpi.html#cloud-config)

---
## <a id='azs'></a> AZs Block

**azs** [Array, required]: Specifies the AZs available to deployments. At least one should be specified.

* **name** [String, required]: Name of an AZ within the Director.
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties needed to associated with AZ; for most IaaSes, some data here is actually required. See [CPI Specific `cloud_properties`](#azs-cloud-properties) below. Example: `availability_zone`. Default is `{}` (empty Hash).

See [first class AZs](azs.html) for more details.

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

### <a id='azs-cloud-properties'></a> CPI Specific `cloud_properties`

- [See AWS CPI AZ cloud properties](aws-cpi.html#azs)
- [See Azure CPI AZ cloud properties](azure-cpi.html#azs)
- [See OpenStack CPI AZ cloud properties](openstack-cpi.html#azs)
- [See Softlayer CPI AZ cloud properties](softlayer-cpi.html#azs)
- [See Google Cloud Platform CPI AZ cloud properties](google-cpi.html#azs)
- [See vSphere CPI AZ cloud properties](vsphere-cpi.html#azs)
- [See vCloud CPI AZ cloud properties](vcloud-cpi.html#azs)

---
## <a id='networks'></a> Networks Block

**networks** [Array, required]: Each sub-block listed in the Networks block specifies a network configuration that jobs can reference. There are three different network types: `manual`, `dynamic`, and `vip`. At least one should be specified.

See [networks](networks.html) for more details.

### <a id='networks-cloud-properties'></a> CPI Specific `cloud_properties`

- [See AWS CPI network cloud properties](aws-cpi.html#networks)
- [See Azure CPI network cloud properties](azure-cpi.html#networks)
- [See OpenStack CPI network cloud properties](openstack-cpi.html#networks)
- [See Softlayer CPI network cloud properties](softlayer-cpi.html#networks)
- [See Google Cloud Plaform CPI network cloud properties](google-cpi.html#networks)
- [See vSphere CPI network cloud properties](vsphere-cpi.html#networks)
- [See vCloud CPI network cloud properties](vcloud-cpi.html#networks)

---
## <a id='vm-types'></a> VM Types Block

**vm_types** [Array, required]: Specifies the [VM types](./terminology.html#vm-type) available to deployments. At least one should be specified.

* **name** [String, required]: A unique name used to identify and reference the VM type
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties needed to create VMs; for most IaaSes, some data here is actually required. See [CPI Specific `cloud_properties`](#vm-types-cloud-properties) below. Example: `instance_type: m3.medium`. Default is `{}` (empty Hash).

Example:

```yaml
vm_types:
- name: default
  cloud_properties:
    instance_type: m1.small
```

### <a id='vm-types-cloud-properties'></a> CPI Specific `cloud_properties`

- [See AWS CPI VM types cloud properties](aws-cpi.html#resource-pools)
- [See Azure CPI VM types cloud properties](azure-cpi.html#resource-pools)
- [See OpenStack CPI VM types cloud properties](openstack-cpi.html#resource-pools)
- [See Softlayer CPI VM types cloud properties](softlayer-cpi.html#resource-pools)
- [See Google Cloud Platform CPI VM types cloud properties](google-cpi.html#resource-pools)
- [See vSphere CPI VM types cloud properties](vsphere-cpi.html#resource-pools)
- [See vCloud CPI VM types cloud properties](vcloud-cpi.html#resource-pools)

---
## <a id='vm-extensions'></a> VM Extensions Block

<p class="note">Note: This feature is available with bosh-release v255.4+.</p>

**vm_extensions** [Array, optional]: Specifies the [VM extensions](./terminology.html#vm-extension) available to deployments.

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
## <a id='disk-types'></a> Disk Types Block

**disk_types** [Array, required]: Specifies the [disk types](./terminology.html#disk-types) available to deployments. At least one should be specified.

* **name** [String, required]: A unique name used to identify and reference the disk type
* **disk_size** [Integer, required]: Specifies the disk size. `disk_size` must be a positive integer. BOSH creates a [persistent disk](./persistent-disks.html) of that size in megabytes and attaches it to each job instance VM.
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties needed to create disks. Examples: `type`, `iops`. Default is `{}` (empty Hash).

Example:

```yaml
disk_types:
- name: default
  disk_size: 2
  cloud_properties:
    type: gp2
```

### <a id='disk-types-cloud-properties'></a> CPI Specific `cloud_properties`

- [See AWS CPI disk type cloud properties](aws-cpi.html#disk-pools)
- [See Azure CPI disk type cloud properties](azure-cpi.html#disk-pools)
- [See OpenStack CPI disk type cloud properties](openstack-cpi.html#disk-pools)
- [See Softlayer CPI disk type cloud properties](softlayer-cpi.html#disk-pools)
- [See Google Cloud Platform CPI disk type cloud properties](google-cpi.html#disk-pools)
- [See vSphere CPI disk type cloud properties](vsphere-cpi.html#disk-pools)
- [See vCloud CPI disk type cloud properties](vcloud-cpi.html#disk-pools)

---
## <a id='compilation'></a> Compilation Block

The Director creates compilation VMs for release compilation. The Director will compile each release on every necessary stemcell used in a deployment. A compilation definition allows to specify VM characteristics.

**compilation** [Hash, required]: Properties of compilation VMs.

* **workers** [Integer, required]: The maximum number of compilation VMs.
* **az** [String, required]: Name of the AZ defined in AZs section to use for creating compilation VMs.
* **vm_type** [String, required]: Name of the VM type defined in VM types section to use for creating compilation VMs.
* **network** [String, required]: References a valid network name defined in the Networks block. BOSH assigns network properties to compilation VMs according to the type and properties of the specified network.
* **reuse\_compilation\_vms** [Boolean, optional]: If `false`, BOSH creates a new compilation VM for each new package compilation and destroys the VM when compilation is complete. If `true`, compilation VMs are re-used when compiling packages. Defaults to `false`.

Example:

```yaml
compilation:
  workers: 2
  reuse_compilation_vms: true
  az: z1
  vm_type: default
  network: private
```
