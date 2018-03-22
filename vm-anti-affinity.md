---
title: VM Anti-affinity
---

For certain deployment jobs, you might want to distribute the instances across multiple physical resources of the IaaS. Even though an IaaS abstracts away the underlying hardware resources, most have specific APIs to configure VM affinity and anti-affinity rules.

One popular example of a deployment job that needs this type of configuration is Hadoop Datanode. If multiple Datanode instances are placed on the same physical machine, replicated data becomes unavailable if that machine fails. To make replication useful in this scenario, BOSH allows you to configure the resource pool for a deployment job. You configure VM anti-affinity rules for an IaaS using the `cloud_properties` sub-block of the `resource_pools` block in your [deployment manifest](./deployment-manifest.html).

Currently only vSphere and OpenStack CPIs provide a way to do so.

---
## <a id='vsphere'></a> vSphere Configuration

The vSphere [VM-VM Affinity Rules](http://pubs.vmware.com/vsphere-51/index.jsp#com.vmware.vsphere.resmgmt.doc/GUID-94FCC204-115A-4918-9533-BFC588338ECB.html) feature allows you to specify whether VMs should run on the same host or be kept on separate hosts. As of BOSH version 101 (stemcell 2693), you can configure the vSphere CPI to include all VMs of a specified BOSH resource pool within a single DRS rule and separate the VMs among multiple hosts.

The following resource pool and job configuration manifest example instructs BOSH to:

* Create seven hadoop-datanode VMs in the `my-vsphere-cluster` vSphere cluster.
* Create a `separate-hadoop-datanodes-rule` DRS rule in the `my-vsphere-cluster` vSphere cluster.
* Configure the DRS rule with a `type` that separates the associated VMs onto different hosts.
* Associate the seven VMs with the DRS rule.

```yaml
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

<div class="note">
  Notes:

	<ul>
	  <li>The vSphere CPI currently only supports
one DRS rule per BOSH resource pool.</li>
    <li>If a BOSH resource pool contains only one VM, the vSphere CPI does not create a DRS rule. After BOSH adds a second VM, the vSphere CPI will create and apply a DRS rule to all VMs in the BOSH resource pool.</li>
  </ul>
</div>

---
## <a id='openstack'></a> OpenStack Configuration

OpenStack's [Filter scheduler](http://docs.openstack.org/developer/nova/devref/filter_scheduler.html) allows to customize compute node selection algorithm which determines placement of new VMs. To enforce anti-affinity among VMs, `ServerGroupAntiAffinityFilter` is available:

> ServerGroupAntiAffinityFilter - This filter implements anti-affinity for a server group. First you must create a server group with a policy of 'anti-affinity' via the server groups API. Then, when you boot a new server, provide a scheduler hint of 'group=<uuid>' where <uuid> is the UUID of the server group you created. This will result in the server getting added to the group. When the server gets scheduled, anti-affinity will be enforced among all servers in that group.

The following resource pool and job configuration manifest example instructs BOSH to:

* Assume that the server group was created and its UUID is `af09abf2-2283-47d6-f2bd-2932a9ae949c`
* Assume that the server group specifies 'anti-affinity' policy
* Create seven hadoop-datanode VMs and add them to the server group `af09abf2-2283-47d6-f2bd-2932a9ae949c`

```yaml
# Assuming that a Hadoop release is used...

resource_pools:
- name: hadoop-datanodes
  cloud_properties:
    instance_type: m3.xlarge
    scheduler_hints:
      group: af09abf2-2283-47d6-f2bd-2932a9ae949c

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

---
[Back to Table of Contents](index.html#deployment-config)
