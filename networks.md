---
title: Networks
---

A BOSH network is an IaaS agnostic representation of the networking layer. The Director is responsible for configuring each deployment jobs' networks with the help of the BOSH Agent and the IaaS. Networking configuration is usually assigned at the boot of the VM and/or when network configuration changes in the deployment manifest for already running deployment jobs.

There are three types of networks that BOSH supports:

* **manual**: the Director decides how to assign IPs to each job instance based on the specified network subnets in the deployment manifest
* **dynamic**: the Director defers IP selection to the IaaS
* **vip**: the Director allows to assign one-off IPs to specific jobs to enable flexible IP routing (e.g. elastic IP)

Each type of network supports one or both IP reservation types:

* **static**: IP is explicitly requested by the user in the deployment manifest
* **dynamic**: IP is selected automatically based on the network type

---
## <a id='general'></a> General Structure

Networking configuration is usually done in 3 steps:

- configuring the IaaS; outside of BOSH's responsiblity
  - Example on AWS: user creates a VPC and subnets with routing tables.
- adding networks section to the deployment manifest to define networks used in this deployment
  - Example: user adds a manual network with a subnet and adds AWS subnet id into the subnet's cloud properties.
- adding network associations for one or more networks to each deployment job

All deployment manifests have a similar structure in terms of network defintions and associations:

```yaml
# Network definitions
networks:
- name: my-network
  ...

- name: my-other-network
  type: ...

  # IaaS specific attributes
  cloud_properties: { ... }

jobs:
- name: my-job

  # Network associations for `my-job`
  networks:
  - name: my-network
  ...

- name: my-other-job
  networks:
  - name: my-network
  - name: my-other-network
  ...

- name: my-static-job
  networks:
  - name: my-network
    # Static IP reservations for `my-job`
    static_ips: [IP1]
  ...
```

See how to define each network type below.

---
## <a id='manual'></a> Manual Networks

Manual networking allows to specify one or more subnets and let the Director choose available IP from one of the subnet ranges. Subnet definition specifies CIDR range, and optionally gateway, and DNS servers. In addition certain IPs can be blacklisted (the Director will not use these IPs) via `reserved` property.

Each manual network attached to a job instance is typically represented as its own NIC in the IaaS layer.

Schema for manual network definition:

* **name** [String, required]: Name used to reference this network configuration.
* **type** [String, required]: Value should be `manual`.
* **subnets** [Array, required]: Lists subnets in this network.
  * **range** [String, required]: Subnet IP range that includes all IPs from this subnet.
  * **gateway** [String, optional]: Subnet gateway IP.
  * **dns** [Array, optional]: DNS IP addresses for this subnet.
  * **reserved** [Array, optional]: Array of reserved IPs and/or IP ranges. BOSH does not assign IPs from this range to any VM.
  * **static** [Array, optional]: Array of static IPs and/or IP ranges. BOSH assigns IPs from this range to jobs requesting static IPs.
  * **cloud_properties** [Hash, required]: Describes any IaaS-specific properties for the subnet. May be empty.

Example:

```yaml
networks:
- name: my-network
  type: manual

  subnets:
  - range:    10.10.0.0/24
    gateway:  10.10.0.1
    dns:      [10.10.0.2]

    # IPs that will not be used for anything
    reserved: [10.10.0.2-10.10.0.10]

    cloud_properties: {subnet: subnet-9be6c3f7}

  - range:   10.10.1.0/24
    gateway: 10.10.1.1
    dns:     [10.10.1.2]

    # IPs that can only be used for static IP reservations within this subnet
    static: [10.10.1.11-10.10.1.20]

    cloud_properties: {subnet: subnet-9be6c6gh}
```

Manual networks use dynamic IP reservation by default. They also support static IP reservation. To assign instances of the deployment job specific IPs, deployment job must specify them in the `static_ips` property for the associated network. Associated network's subnet defintion must also specify them in its `static` property:

```yaml
jobs:
- name: my-job-with-static-ip
  instances: 2
  ...
  networks:
  - name: my-network

    # IPs associated with 2 instances of `my-job-with-static-ip` job
    static_ips: [10.10.1.11, 10.10.1.12]
```

<p class="note">Note: If deployment job uses static IP reservation, all instances must be given static IPs.</p>

A common problem that you may run into is configuring multiple deployments to use overlapping IP range. The Director does _not_ consider an IP as used even if that same Director used that IP in a different deployment. There are two possible solutions for this problem: reconfigure one of the deployments to use a different IP range or use the same IP range but configure each deployment such that reserved IPs exclude each deployment from each other.

<p class="note">Note: It is not guranteed which available IP is picked but you might notice that the Director usually picks next available IP.</p>

---
## <a id='dynamic'></a> Dynamic Networks

Dynamic networking defers IP selection to the IaaS. For example, AWS by default assigns a private IP to each instance in the VPC. By associating a deployment job to a dynamic network, BOSH will pick up AWS assigned private IP.

Each dynamic network attached to a job instance is typically represented as its own NIC in the IaaS layer.

Dynamic networking only supports dynamic IP reservations.

Schema for dynamic network definition:

* **name** [String, required]: Name used to reference this network configuration.
* **type** [String, required]: Value should be `dynamic`.
* **dns** [Array, optional]: DNS IP addresses for this network.
* **cloud_properties** [Hash, required]: Describes any IaaS-specific properties for the network. May be empty.

Example:

```yaml
networks:
- name: my-network
  type: dynamic
  dns:  [10.10.0.2]
  cloud_properties: {subnet: subnet-9be6c3f7}
```

---
## <a id='vip'></a> VIP (Virtual IP) Networks

VIP networking enables association of an IP address that is not backed by any particular NIC. This flexibility enables users to remap virtual IP to a different instance in cases of a failure.

VIP network attachment is not represented as a NIC in the IaaS layer. It is implemented by AWS CPI with [elastic IPs](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html), and on OpenStack CPI with [floating IPs](http://docs.openstack.org/user-guide/content/floating_ip_allocate.html).

VIP networking only supports static IP reservations.

Schema for VIP network definition:

* **name** [String, required]: Name used to reference this network configuration.
* **type** [String, required]: Value should be `vip`.
* **cloud_properties** [Hash, required]: Describes any IaaS-specific properties for the network. May be empty.

Example:

```yaml
networks:
- name: my-network
  type: vip
  cloud_properties: {}

jobs:
- name: my-job
  ...
  networks:
  - name: my-network
    static_ips: [54.47.189.8]
```

Unlike the manual networking setup, static IPs for VIP networks are only specified on the deployment job.

---
## <a id='cpi-limitations'></a> CPI Limitations

The Director does not enforce how many networks could be assigned to each job instance; however, each CPI might impose custom requirements either due to the IaaS limitations or simply because support was not yet implemented.

vSphere CPI supports:

- multiple manual networks for each job instance
- NO dynamic networks since vSphere does not manage IP assignments
- NO vip networks since vSphere does not have a elastic/floating IP concept

AWS CPI supports:

- single manual network for each job instance
- single dynamic network for each job instance
- single vip network which corresponds to an elastic IP

OpenStack CPI supports:

- multiple manual networks for each job instance
- single dynamic network for each job instance
- single vip network which corresponds to a floating IP

---
## <a id='cloud-properties'></a> CPI Specific `cloud_properties`

- [See AWS CPI network cloud properties](aws-cpi.html#networks)
- [See OpenStack CPI network cloud properties](openstack-cpi.html#networks)
- [See vSphere CPI network cloud properties](vsphere-cpi.html#networks)
