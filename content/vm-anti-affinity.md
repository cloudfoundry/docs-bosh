For certain deployment jobs, you might want to distribute the instances across multiple physical resources of the IaaS. Even though an IaaS abstracts away the underlying hardware resources, most have specific APIs to configure VM affinity and anti-affinity rules.

One popular example of a deployment job that needs this type of configuration is Hadoop Datanode. If multiple Datanode instances are placed on the same physical machine, replicated data becomes unavailable if that machine fails. To make replication useful in this scenario, BOSH allows you to configure the resource pool for a deployment job. You configure VM anti-affinity rules for an IaaS using the `cloud_properties` sub-block of:
 - the `resource_pools` block in your [deployment manifest](deployment-manifest.md) - deployment manifests v1
 - the `vm_extensions` or `vm_type` block in your [cloud config](cloud-config.md) - deployment manifests v2

Currently only vSphere and OpenStack CPIs provide a way to do so.

---
## vSphere Configuration {: #vsphere }

The vSphere [VM-VM Affinity Rules](http://pubs.vmware.com/vsphere-51/index.jsp#com.vmware.vsphere.resmgmt.doc/GUID-94FCC204-115A-4918-9533-BFC588338ECB.html) feature allows you to specify whether VMs should run on the same host or be kept on separate hosts. As of BOSH version 101 (stemcell 2693), you can configure the vSphere CPI to include all VMs of a specified BOSH resource pool within a single DRS rule and separate the VMs among multiple hosts.

The following resource pool and job configuration manifest example instructs BOSH to:

* Create seven hadoop-datanode VMs in the `my-vsphere-cluster` vSphere cluster.
* Create a `separate-hadoop-datanodes-rule` DRS rule in the `my-vsphere-cluster` vSphere cluster.
* Configure the DRS rule with a `type` that separates the associated VMs onto different hosts.
* Associate the seven VMs with the DRS rule.

```yaml
# deployment manifests v1
# Assuming that a Hadoop release is used...

resource_pools:
- name: hadoop-datanodes
  cloud_properties:
    datacenters:
    - name: my-dc
      clusters:
      - my-vsphere-cluster:
          drs_rules:
          - name: separate-hadoop-datanodes-rule
            type: separate_vms

jobs:
- name: hadoop-datanode
  templates:
  - {name: hadoop-datanode, release: hadoop}
  instances: 7
  resource_pool: hadoop-datanodes
  persistent_disk: 10_240
  networks:
  - name: default
```

If the vSphere CPI does not place the VMs on different hosts, check that you have done the following:

- Associated multiple healthy hosts to the vSphere cluster.
- Enabled DRS for the vSphere cluster. You can modify the DRS automation level in the cluster settings.
- Enabled a DRS rule and associated it with the appropriate VMs.
- Given the DRS enough time to move the VMs to different hosts.

Notes:

- The vSphere CPI currently only supports one DRS rule per BOSH resource pool.
- If a BOSH resource pool contains only one VM, the vSphere CPI does not create a DRS rule. After BOSH adds a second VM, the vSphere CPI will create and apply a DRS rule to all VMs in the BOSH resource pool.
- You can also use YAML Anchors in the config. E.g

```yaml
# deployment manifests v1
# Assuming there are 2 clusters which need same DRS rule...

resource_pools:
- name: hadoop-datanodes
  cloud_properties:
    datacenters:
    - name: my-dc
      clusters:
      - my-vsphere-cluster1:
          drs_rules: &default_drs_rule
          - name: separate-hadoop-datanodes-rule
            type: separate_vms
      - my-vsphere-cluster2:
          drs_rules: *default_drs_rules
```

---
## OpenStack Configuration {: #openstack }

### Must be or should be...

Depending on the role of the instances group in your deployment you may require a hard-affinity (must-be) or a soft-affinity (should-be) policy, OpenStack supports both of them.

#### [Hard affinity](https://specs.openstack.org/openstack/nova-specs/specs/rocky/implemented/complex-anti-affinity-policies.html)

Hard affinity is also known as affinity or strict affinity.
You can specify whether the instances in a group **must be**:
- collocated on the same physical machine - the `affinity` policy
- spread onto as many physical machines as possible - the `anti-affinity` policy

**Must be** - expressing obligation, it is a **hard** requirement.
Assume there are two physical machines and three instances in a group to collocate, in this case two of them can be collocated (depending on available resources) but during the collocation the third one, we will get an CPI error: `No valid host was found. There are not enough hosts available.`

Hard affinity is done by OpenStack's [Filter scheduler](http://docs.openstack.org/developer/nova/devref/filter_scheduler.html) during a **filtering** step.
Filter scheduler allows to customize compute node selection algorithm which determines placement of new VMs. To enforce anti-affinity among VMs, `ServerGroupAntiAffinityFilter` is available:

> **ServerGroupAntiAffinityFilter** - This filter implements anti-affinity for a server group. First you must create a server group with a policy of 'anti-affinity' via the server groups API. Then, when you boot a new server, provide a scheduler hint of 'group=<uuid>' where <uuid> is the UUID of the server group you created. This will result in the server getting added to the group. When the server gets scheduled, anti-affinity will be enforced among all servers in that group.

You can also change the `max_server_per_host` rule (OpenStack Rocky and newer) to increase the max limit on the number of instances in a group on a given physical machine.


#### [Soft affinity](http://specs.openstack.org/openstack/nova-specs/specs/kilo/approved/soft-affinity-for-server-group.html)

You might want to have a less strict affinity and anti-affinity rule than the hard affinity, soft affinity is something like a good-to-have affinity rule.
You can specify whether the instances in a group **should be**:
- collocated on the same physical machine - the `soft-affinity` policy
- spread onto as many physical machines as possible - the `soft-anti-affinity` policy

With `soft-affinity` policy BOSH can requests OpenStack to schedule the instances in a group to the same physical machine (affinity) if possible (soft-affinity).
However if it is not possible the instances will be collocated on a small amount of different physical machines.
With `soft-anti-affinity` policy BOSH can requests OpenStack to spread the instances in a group as much as possible.

Soft affinity is done by OpenStack's [Filter scheduler](http://docs.openstack.org/developer/nova/devref/filter_scheduler.html) during a **weighting** step.

> **ServerGroupSoftAntiAffinityWeigher** The weigher can compute the weight based on the number of instances that run on the same server group as a negative value. The largest weight defines the preferred host for the new instance. For the multiplier only a positive value is meaningful for the calculation as a negative value would mean that the anti-affinity weigher would prefer collocating placement.

Note that you can change `scheduler_host_subset_size` property too, it's `1` by default. New instances are scheduled on a host that is chosen randomly from a subset of the `scheduler_host_subset_size` best hosts.


### BOSH Manifest

Both for the hard and soft affinity you have to create OpenStack's server groups first:
- hard affinity:
  ```
  openstack server group create --policy affinity my_instances_sg
  ```
- hard anti-affinity:
  ```
  openstack server group create --policy anti-affinity my_instances_sg
  ```
- soft affinity:
  ```
  openstack server group create --policy soft-affinity my_instances_sg --os-compute-api-version 2.15
  ```
- soft anti-affinity:
  ```
  openstack server group create --policy soft-anti-affinity my_instances_sg --os-compute-api-version 2.15
  ```


You can list all server groups using:
```
openstack server group list
```

Assume that the server group was created with the appropriate policy and its UUID is `abcdefgh-1234-47d6-f2bd-2932a9ae949c`.
The following configuration manifest example instructs BOSH to create seven `hadoop-datanode` VMs and add them to this server group `hadoop_datanodes`:

#### Deployment Manifests V1

```yaml
# Assuming that a Hadoop release is used...

resource_pools:
- name: hadoop-datanodes
  cloud_properties:
    instance_type: m3.xlarge
    scheduler_hints:
      group: abcdefgh-1234-47d6-f2bd-2932a9ae949c

jobs:
- name: hadoop-datanode
  templates:
  - {name: hadoop-datanode, release: hadoop}
  instances: 7
  resource_pool: hadoop-datanodes
  persistent_disk: 10_240
  networks:
  - name: default
```

#### Deployment Manifests V2

- [cloud config](cloud-config.md)

  ```yaml
  vm_extensions:
  - name: hadoop_datanodes
    cloud_properties:
      scheduler_hints:
        group: abcdefgh-1234-47d6-f2bd-2932a9ae949c
  ```

- [deployment manifest](deployment-manifest.md)

  ```yaml
  instance_groups:
  - name: hadoop-datanode
    instances: 7
    vm_extensions:
    - hadoop_datanodes
  ```

- you can modify your manifest using an operation file like this:

  ```yaml
  ---
  - type: replace
    path: /instance_groups/name=hadoop-datanode/vm_extensions?/-
    value: hadoop_datanodes
  ```
