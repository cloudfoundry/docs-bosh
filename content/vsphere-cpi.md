This topic describes cloud properties for different resources created by the vSphere CPI.

## AZs {: #azs }

Schema for `cloud_properties` section:

* **datacenters** [Array, optional]: Array of datacenters to use for VM placement. Must have only one and it must match datacenter configured in global CPI options.
    * **name** [String, required]: Datacenter name.
    * **clusters** [Array, required]: Array of clusters to use for VM placement.
        * **&lt;cluster name&gt;** [String, required]: Cluster name.
            * **resource_pool** [String, optional]: Name of vSphere Resource Pool to use for VM placement.
            * **drs_rules** [Array, optional]: Array of DRS rules applied to [constrain VM placement](vm-anti-affinity.md#vsphere). Must have only one.
                * **name** [String, required]: Name of a DRS rule that the Director will create.
                * **type** [String, required]: Type of a DRS rule. Currently only `separate_vms` is supported.

Example:

```yaml
azs:
- name: z1
  cloud_properties:
    datacenters:
    - name: my-dc
      clusters:
      - {my-vsphere-cluster: {resource_pool: my-vsphere-res-pool}}
```

---
## Networks {: #networks }

Schema for `cloud_properties` section used by manual network subnet:

* **name** [String, required]: Name of the vSphere network. Example: `VM Network`.

**Note:** To assign a distributed virtual portgroup when
there exists a standard virtual portgroup with the same name,
prepend the distributed virtual switch's name followed by a slash to the
distributed virtual portgroup, e.g. `dvs/distributed-portgroup-1`. This may
be required when working with VxRack. Available in v28+.

**Note:** The name may also be an NSX opaque network. Available in v40+.

Example of manual network:

```yaml
networks:
- name: default
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    cloud_properties:
      name: VM Network
```

vSphere CPI does not support dynamic or vip networks.

---
## VM Types / VM Extensions {: #resource-pools }

Schema for `cloud_properties` section:

* **cpu** [Integer, required]: Number of CPUs. Example: `1`.
* **ram** [Integer, required]: RAM in megabytes. Example: `1024`.
* **disk** [Integer, required]: Ephemeral disk size in megabytes. Example: `10240`.
* **cpu\_hot\_add\_enabled** [Boolean, optional]: Allows operator to add additional CPU resources while the VM is on. Default: `false`. Available in v21+.
* **memory\_hot\_add\_enabled** [Boolean, optional]: Allows operator to add additional memory resources while the VM is on. Default: `false`. Available in v21+.
* **upgrade\_hw\_version** [Boolean, optional]: Upgrades the virtual hardware version of a virtual machine to the latest supported version on the ESXi host. Overrides the global upgrade_hw_version. Default: `false`.
* **nested\_hardware\_virtualization** [Boolean, optional]: Exposes hardware assisted virtualization to the VM. Default: `false`.
* **datastores** [Array, optional]: Allows operator to specify a list of ephemeral datastores, datastore clusters for the VM. Datastore names are exact datastore names and not regex patterns. At least one of these datastores must be accessible from clusters provided in `resource_pools.cloud_properties`/`azs.cloud_properties` or in the global CPI configuration. Available in v23+. Datastore Clusters can be specified as an array of datastore cluster names. Available in v47+
* **datacenters** [Array, optional]: Used to override the VM placement specified under `azs.cloud_properties`. The format is the same as under [`AZs`](#azs).
* **nsx** [Dictionary, optional]: [VMware NSX](http://www.vmware.com/products/nsx.html) additions section. Available in CPI v30+ and NSX v6.1+.
    * **security_groups** [Array, optional]: A collection of [security group](https://pubs.vmware.com/NSX-6/index.jsp#com.vmware.nsx.admin.doc/GUID-16B3134E-DDF1-445A-8646-BB0E98C3C9B5.html) names that the instances should belong to. The CPI will create the security groups if they do not exist.
    BOSH will also automatically create security groups based on metadata such as deployment name and instance group name. The full list of groups can be seen under [create_vm's environment groups](cpi-api-v1.md#create-vm).
    * **lbs** [Array, optional]: A collection of [NSX Edge Load Balancers](https://pubs.vmware.com/NSX-6/index.jsp?topic=%2Fcom.vmware.nsx.admin.doc%2FGUID-152982CF-108F-47A6-B86A-0F0F6A56D628.html) (LBs) to which instances should be attached. The LB and [Server Pool](https://pubs.vmware.com/NSX-6/index.jsp?topic=%2Fcom.vmware.nsx.admin.doc%2FGUID-D5A3BDBA-57A6-43F4-AE5E-3A387FE69EDC.html) must exist prior to the deployment.
        * **edge_name** [String, required]: Name of the NSX Edge.
        * **pool_name** [String, required]: Name of the Edge's Server Pool.
        * **security_group** [String, required]: Name of the Pool's target Security Group. The CPI will add the VM to the specified security group (creating the security group if needed), then add the security group to the specified Server Pool.
        * **port** [Integer, required]: The port that the VM's service is listening on (e.g. 80 for HTTP).
        * **monitor_port** [Integer, optional]: The healthcheck port that the VM is listening on. Defaults to the value of `port`.
* **vmx_options** [Dictionary, optional]: Allows operator to specify [VM advanced configuration options](https://docs.vmware.com/en/VMware-vSphere/6.0/com.vmware.vsphere.resmgmt.doc/GUID-F8C7EF4D-D023-4F54-A2AB-8CF840C10939.html). All values are subject to YAML's type interpretation, and given that for certain configuration options vSphere will accept only a specific value type please take note of the difference between values with similar appearances such as: `true` vs `"true"` and `"1234"` vs `1234`. Refer to the vSphere documentation for more information about what configuration options are accepted. Available in v42+.
* **nsxt** [Dictionary, optional]: [VMware NSX](http://www.vmware.com/products/nsx.html) additions section. Available in CPI v45+.
    * **ns_groups** [Array, optional]: A collection of [NS Groups](http://pubs.vmware.com/nsxt-11/index.jsp?topic=%2Fcom.vmware.nsxt.admin.doc%2FGUID-718E769B-8D89-485B-8DBD-04F1F82CFE14.html) names that the instances should belong to. Available in NSX-T v1.1+.
    * **vif_type** [String, optional]: Supported types: `PARENT`, `null`. Overrides the global `default_vif_type`. Available in NSX-T v2.0+.
    * **lb** [Dictionary, optional]: NSX-T logical Load Balancer. Available in CPI v48+
        * **server_pools** [Array, optional] Server Pool must exist prior to the deployment. For static server pool, VM is directly added to the server pool. If server pool is dynamic, CPI looks up the NSGroup and adds the VM to the NSGroup.
            * **name** [String, required]: Name of the Server Pool
            * **port** [Integer, required]: The port that the VM's service is listening on (e.g. 80 for HTTP)

Example of a VM asked to be placed into a specific vSphere resource pool with NSX-V and NSX-T integration:

```yaml
resource_pools:
- name: nsx
  network: default
  stemcell:
    name: bosh-vsphere-esxi-ubuntu-trusty-go_agent
    version: latest
  cloud_properties:
    cpu: 1
    ram: 1_024
    disk: 10_240
    datastores: [prod-ds-1, prod-ds-2, {clusters: [vcpi-sp1: {}  , vcpi-sp2: {}]}]
    datacenters:
    - name: my-dc
      clusters:
      - my-vsphere-cluster: {resource_pool: other-vsphere-res-pool}
    nsx: # NSX-V configuration
      security_groups: [public, dmz]
      lbs:
      - edge_name: my-lb
        pool_name: https-pool
        security_group: https-sg
        port: 443
        monitor_port: 4443 # optional, defaults to `port` value
    vmx_options:
      sched.mem.maxmemctl: "1330"
    nsxt: # NSX-T configuration
      ns_groups: [public, dmz]
      vif_type: PARENT
      lb:
        server_pools:
        - name: cpi-pool-1
          port: 80
```

---
## Disk Types {: #disk-pools }

Schema for `cloud_properties` section:

* **type** [String, optional]: Type of the
  [disk](http://pubs.vmware.com/vi-sdk/visdk250/ReferenceGuide/vim.VirtualDiskManager.VirtualDiskType.html):
  `thick`, `thin`, `preallocated`, `eagerZeroedThick`. Defaults to
  `preallocated`. Available in v12. Overrides the global `default_disk_type`.

* **datastores** [Array, optional]: List of datastore names, datastore clusters for storing persistent disks. Overrides the global `persistent_datastore_pattern`. These names are exact datastore names and not regex patterns. Available in v29+. Datastore Clusters can be specified as an array of datastore cluster names. Available in v47+

Example of 10GB disk:

```yaml
disk_pools:
- name: default
  disk_size: 10_240
```

Example of disk with type eagerZeroedThick:

```yaml
disk_pools:
- name: default
  disk_size: 10_240
  cloud_properties:
    type: eagerZeroedThick
```

Example of disk stored in specific datastores:

```yaml
disk_pools:
- name: default
  disk_size: 10_240
  cloud_properties:
    datastores: ['prod-ds-1', 'prod-ds-2', {clusters: [vcpi-sp1: {}  , vcpi-sp2: {}]}]
```

---
## Global Configuration {: #global }

The CPI can only talk to a single vCenter installation and manage VMs within a single vSphere datacenter.

Schema:

* **host** [String, required]: IP address of the vCenter. Example: `172.16.68.3`.
* **user** [String, required]: Username for the API access. Example: `root`.
* **password** [String, required]: Password for the API access. Example: `vmware`
* **http_logging** [Boolean, optional]: Enables logging all HTTP requests and responses to vSphere API. Default: `false`. Available in v37+.
* **default\_disk\_type** [String, optional]: Sets the default
  [disk type](https://www.vmware.com/support/developer/converter-sdk/conv51_apireference/vim.VirtualDiskManager.VirtualDiskType.html).
  Can be either `thin` or `preallocated`, defaults to `preallocated`. `preallocated`
  sets "all space allocated at [VM] creation time and the space is zeroed on demand as the space is used",
  and `thin`, "virtual disk is allocated and zeroed on demand as the space is used."
  Applies to both ephemeral and persistent disks.

* **datacenters** [Array, optional]: Array of datacenters to use for VM placement. Must have only one.
    * **name** [String, required]: Datacenter name.
    * **vm_folder** [String, required]: Path to a folder (relative to the datacenter) for storing created VMs. Folder will be automatically created if not found.
    * **template_folder** [String, required]: Path to a folder (relative to the datacenter) for storing uploaded stemcells. Folder will be automatically created if not found.
    * **disk_path** [String, required]: Path to a *disk* folder for storing persistent disks. Folder will be automatically created in the datastore if not found.
    * **datastore_pattern** [String, required]: Pattern for selecting datastores for storing ephemeral disks and replicated stemcells.
    * **persistent\_datastore\_pattern** [String, required]: Pattern for selecting datastores for storing persistent disks.
    * **clusters** [Array, required]: Array of clusters to use for VM placement.
        * **&lt;cluster name&gt;** [String, required]: Cluster name.
            * **resource_pool** [String, optional]: Specific vSphere resource pool to use within the cluster.
* **nsx** [Dictionary, optional]: NSX-V configuration options.  This is required if the other NSX features are used below (e.g. 'security_groups' for `resource_pools`).
    * **address** [String, required]: The NSX server's address. Can be a hostname (e.g. `nsx-server.example.com`) or an IP address.
    * **user** [String, required]: The login username for the NSX server.
    * **password** [String, required]: The login password for the NSX server.
    * **ca_cert** [String, optional]: A CA certificate that can authenticate the NSX server certificate. **Required** if the NSX Manager has a self-signed SSL certificate. Must be in PEM format.
* **enable\_auto\_anti\_affinity\_drs\_rules** [Boolean, optional]: Creates DRS rule to place VMs on separate hosts. DRS Automation Level must be set to "Fully Automated"; does not work when DRS is set to "Partially Automated" or "Manual". May cause VMs to fail to power on if there are more VMs than hosts after initial deployment. Default: `false`. Available in v33+.
* **upgrade\_hw\_version** [Boolean, optional]: Upgrades the virtual hardware version of a virtual machine to the latest supported version on the ESXi host. Default: `false`.
* **nsxt** [Dictionary, optional]: NSX-T configuration options. Available in v45+.
    * **host** [String, required]: The NSX-T server's address. Can be a hostname (e.g. `nsx-server.example.com`) or an IP address.
    * **username** [String, required]: The login username for the NSX-T server.
    * **password** [String, required]: The login password for the NSX-T server.
    * **ca_cert** [String, optional]: A CA certificate that can authenticate the NSX-T server certificate. **Required** if the NSX-T Manager has a self-signed SSL certificate. Must be in PEM format.
    * **default_vif_type** [String, optional]: Supported Types: `PARENT`. Default VIF type attached to logical port. Available in NSX-T v2.0+.

!!! note
    If the NSX-V or NSX-T Manager has a self-signed certificate, the certificate must be set in the `ca_cert` property.

Example of a CPI configuration that will place VMs into `BOSH_CL` cluster within `BOSH_DC`:

```yaml
properties:
  vcenter:
    address: 172.16.68.3
    user: root
    password: vmware
    datacenters:
    - name: BOSH_DC
      vm_folder: prod-vms
      template_folder: prod-templates
      disk_path: prod-disks
      datastore_pattern: '^prod-ds$'
      persistent_datastore_pattern: '^prod-ds$'
      clusters: [BOSH_CL]
```

Example that places VMs by default into `BOSH_RP` vSphere resource pool with NSX integration and enables VM anti-affinity DRS rule:

```yaml
properties:
  vcenter:
    address: 172.16.68.3
    user: root
    password: vmware
    default_disk_type: thin
    enable_auto_anti_affinity_drs_rules: true
    datacenters:
    - name: BOSH_DC
      vm_folder: prod-vms
      template_folder: prod-templates
      disk_path: prod-disks
      datastore_pattern: '\Aprod-ds\z'
      persistent_datastore_pattern: '\Aprod-ds\z'
      clusters:
      - BOSH_CL: {resource_pool: BOSH_RP}
    nsx:
      address: 172.16.68.4
      user: administrator@vsphere.local
      password: vmware
```

---
## Example Cloud Config {: #cloud-config }

```yaml
azs:
- name: z1
  cloud_properties:
    datacenters:
    - clusters: [z1: {}]
- name: z2
  cloud_properties:
    datacenters:
    - clusters: [z2: {}]

vm_types:
- name: default
  cloud_properties:
    cpu: 2
    ram: 1024
    disk: 3240
- name: large
  cloud_properties:
    cpu: 2
    ram: 4096
    disk: 30_240

disk_types:
- name: default
  disk_size: 3000
- name: large
  disk_size: 50_000

networks:
- name: default
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    az: z1
    dns: [8.8.8.8]
    cloud_properties:
      name: vm-net1
  - range: 10.10.1.0/24
    gateway: 10.10.1.1
    az: z1
    dns: [8.8.8.8]
    cloud_properties:
      name: vm-net2

compilation:
  workers: 5
  reuse_compilation_vms: true
  az: z1
  vm_type: large
  network: default
```

---
## Notes {: #notes }

* Assigned VM names (e.g. `vm-8dg349-s7cn74-...`) should not be manually changed since the CPI uses them to find created VMs. You can use [`bosh vms --details`](sysadmin-commands.md#health) to find which VM is assigned which job. VMs are also tagged with their assigned job, index and deployment.

* Storage DRS and vMotion can be used with vSphere CPI version v18 and above. For additional details see [Storage DRS and vMotion Support](vsphere-vmotion-support.md).

* `allow_mixed_datastores` configuration has been deprecated in favor of setting same datastore pattern for `datastore_pattern` and `persistent_datastore_pattern` keys.

* The vSphere CPI requires access to port 80/443 for all the ESXi hosts in your
vSphere resource pool(s).  In order to upload stemcells to vSphere, the
vSphere CPI makes use of an API call that returns a URL that the CPI should
make a `POST` request to in order to upload the stemcell. This URL could have
a hostname that resolves to any one of the ESXi hosts that are associated
with your vSphere resource pool(s).

* Setting `enable_auto_anti_affinity_drs_rules` to true may cause `bosh deploy` to fail after the initial deployment if there are more VMs than hosts. A workaround is to set `enable_auto_anti_affinity_drs_rules` to false to perform subsequent deployments.

* Support for specifying Datastore Clusters for ephemeral and persistent disks is available with vSphere CPI version v47 and above. For additional detais see [Release Notes for v47](https://github.com/cloudfoundry-incubator/bosh-vsphere-cpi-release/releases/tag/v47)

### VMs {: #vms }

VMs have randomly generated cloud identifiers, in the format `"vm-#{SecureRandom.uuid}"`. They are stored on a datacenter as follows:

`datacenter.name/vm/vm_folder.name/vm_cid`

e.g.

 `TEST_DATACENTER/vm/58bc710b-aec7-41f6-bb78-7d65f8033e51/vm-f050dbdb-ddcf-4524-b6d8-fad1135c6f7e`

Your datacenter will be queried for the path above to try and find a matching VM.

There is nothing in the CPI that prevents using an id generated by the cloud for the cloud id. Indeed, the AWS CPI uses the instance ids generated on AWS
for cloud ids. The create_vm() CPI call returns the cid of the created VM, so it's up to the CPI implementor to decide what to use for cloud id.

Although it's technically possible to use the instanceUuid on vSphere (much like how we use AWS instance ids), it's worth noting that this breaks backwards compatibility and would require a fairly hefty migration. This would open up the possibility of allowing an operator to move a VM out of its containing folder on a datacenter, as it would be possible to identify a VM independent of its inventory location.

### Networks {: #networks }

Networks are uniquely identified by datacenter and network name (which must be unique within the datacenter).

### Datastores {: #datastores }

Datastores are identified by their name and are matched by a regular expression that matches against that name. For example, consider the following datastores in folders:

- `/foo/bar/datastore1`
- `/foo/bar/anothername`
- `/foo/baz/datastore1`

The name of datastore is the last part of each line above, e.g. 'datastore1'. An operator may choose to select both `/foo/bar/datastore1` and `/foo/baz/datastore1` with the regular expression 'datastore' or even 'datastore1'. They cannot, however, select both `/foo/bar/datastore1` and `/foo/bar/anothername` by using a regular expression that matches against directory structure, e.g. `/foo/bar`.

Ephemeral and persistent datastores are consumed before shared datastores.

#### Datastore Paths {: #datastore-paths }

Persistent disks are stored on datastores in the following paths:

`/<datacenter disk path from manifest>/disk-<random disk uuid>.vmdk`

#### Linked Clones {: #linked-clones }

The vSphere CPI uses linked clones by default. Linked clones require the clone to be on the same datastore as the source so stemcells are automatically copied to each datastore that their clones will be on. These stemcells look like `sc-<uuid> / <datastore managed object id>` in the inventory. In the datastore browser the "/" will be quoted to "%2f".

### Clusters {: #clusters }

Each datacenter can have multiple clusters in the cloud properties.

A cluster is identified by its name and its datacenter. Its location within folders in each datacenter does not matter.

In vSphere, cluster names do not need to be unique per datacenter, only their paths needs to be unique. The current vSphere CPI code does not handle this and would only see one cluster if two had the same name.

Clusters do not have any unique ID like a VM's instanceUuid.

#### VM Placement {: #vm-placement }

When placing a VM, a cluster is chosen (along with a datastore) based on the VM's memory, ephemeral disk, and persistent disk requirements.

VMs are placed on clusters and datastores based on a weighted random algorithm. The weights are calculated by how many times the requested memory, ephemeral and persistent disk could fit on the cluster.

During VM placement local datastores and shared datastores are not treated differently. All datastores registered on a cluster are treated the same.

##### Locality {: #locality }

When recreating an existing VM, the CPI tries to create it in a cluster and datastore that are near the largest of its existing persistent disks.

### Datacenters {: #datacenters }

The vSphere CPI only supports a single datacenter and errors if more than one is defined in the manifest. It is identified by name.

The current code will not work with a datacenter inside a folder.
