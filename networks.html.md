---
title: Networks
---

A BOSH network is an IaaS-agnostic representation of the networking layer. The Director is responsible for configuring each deployment job's networks with the help of the BOSH Agent and the IaaS. Networking configuration is usually assigned at the boot of the VM and/or when network configuration changes in the deployment manifest for already-running deployment jobs.

There are three types of networks that BOSH supports:

* **static**: the Director decides how to assign IPs to each job instance based on the specified network subnets in the deployment manifest
* **dynamic**: the Director defers IP selection to the IaaS
* **vip**: the Director allows one-off IP assignments to specific jobs to enable flexible IP routing (e.g. elastic IP)

Each type of network supports one or both IP reservation types:

* **manual**: IP is explicitly requested by the user in the deployment manifest
* **automatic**: IP is selected automatically based on the network type

|                         | static network     | dynamic network | vip network   |
|-------------------------|--------------------|-----------------|---------------|
| manual IP assignment    | Supported          | Not supported   | Supported     |
| automatic IP assignment | Supported, default | Supported       | Not supported |

---
## <a id='general'></a> General Structure

Networking configuration is usually done in three steps:

- Configuring the IaaS: outside of BOSH's responsibility
  - Example on AWS: User creates a VPC and subnets with routing tables.
- Adding networks section to the deployment manifest to define networks used in this deployment
  - Example: User adds a static network with a subnet and adds AWS subnet ID into the subnet's cloud properties.
- Adding network associations for one or more networks to each deployment job

All deployment manifests have a similar structure in terms of network definitions and associations:

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

- name: my-multi-homed-job
  networks:
  - name: my-network
  - name: my-other-network
  ...

- name: my-manual-job
  networks:
  - name: my-network
    # Manual IP reservations for `my-job`
    manual_ips: [IP1]
  ...
```

See how to define each network type below.

---
## <a id='static'></a> Static Networks

Static networking allows you to specify one or more subnets and let the Director choose available IPs from one of the subnet ranges. A subnet definition specifies the CIDR range and, optionally, the gateway and DNS servers. In addition, certain IPs can be blacklisted (the Director will not use these IPs) via the `reserved` property.

Each static network attached to a job instance is typically represented as its own NIC in the IaaS layer.

Schema for static network definition:

* **name** [String, required]: Name used to reference this network configuration
* **type** [String, required]: Value should be `static`
* **subnets** [Array, required]: Lists subnets in this network
  * **range** [String, required]: Subnet IP range that includes all IPs from this subnet
  * **gateway** [String, optional]: Subnet gateway IP
  * **dns** [Array, optional]: DNS IP addresses for this subnet
  * **reserved** [Array, optional]: Array of reserved IPs and/or IP ranges. BOSH does not assign IPs from this range to any VM
  * **manual** [Array, optional]: Array of manual IPs and/or IP ranges. BOSH assigns IPs from this range to jobs requesting manual IPs. Only IPs specified here can be used for manual IP reservations.
  * **cloud_properties** [Hash, required]: Describes any IaaS-specific properties for the subnet. May be empty.

Example:

```yaml
networks:
- name: my-network
  type: static

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

    # IPs that can only be used for manual IP reservations within this subnet
    manual: [10.10.1.11-10.10.1.20]

    cloud_properties: {subnet: subnet-9be6c6gh}
```

Static networks use automatic IP reservation by default. They also support manual IP reservation. To assign specific IPs to instances of the deployment job, they must be specified in deployment job's `networks` section, in the `manual_ips` property for the associated network. That network's subnet definition must also specify them in its `manual` property:

```yaml
jobs:
- name: my-job-with-manual-ip
  instances: 2
  ...
  networks:
  - name: my-network

    # IPs associated with 2 instances of `my-job-with-manual-ip` job
    manual_ips: [10.10.1.11, 10.10.1.12]
```

<p class="note"><strong>Note</strong>: If a deployment job uses manual IP reservation, all instances must be given manual IPs.</p>

A common problem that you may run into is configuring multiple deployments to use overlapping IP ranges. The Director does not consider an IP to be "used" even if the Director used that IP in a different deployment. There are two possible solutions for this problem: reconfigure one of the deployments to use a different IP range, or use the same IP range but configure each deployment such that reserved IPs exclude the deployment from each other.

<p class="note">Note: While the Director usually selects the next available IP address, this behavior is not guaranteed.</p>

---
## <a id='dynamic'></a> Dynamic Networks

Dynamic networking defers IP selection to the IaaS. For example, AWS assigns a private IP to each instance in the VPC by default. By associating a deployment job to a dynamic network, BOSH will pick up AWS-assigned private IP addresses.

Each dynamic network attached to a job instance is typically represented as its own NIC in the IaaS layer.

Dynamic networking only supports automatic IP reservations.

Schema for dynamic network definition:

* **name** [String, required]: Name used to reference this network configuration
* **type** [String, required]: Value should be `dynamic`
* **dns** [Array, optional]: DNS IP addresses for this network
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

VIP networking enables the association of an IP address that is not backed by any particular NIC. This flexibility enables users to remap a virtual IP to a different instance in cases of a failure.

VIP network attachment is not represented as a NIC in the IaaS layer. In the AWS CPI, it is implemented with [elastic IPs](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html). In OpenStack CPI, it is implemented with [floating IPs](http://docs.openstack.org/user-guide/content/floating_ip_allocate.html).

VIP networking only supports manual IP reservations.

Schema for VIP network definition:

* **name** [String, required]: Name used to reference this network configuration
* **type** [String, required]: Value should be `vip`
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
    manual_ips: [54.47.189.8]
```

Unlike the static networking setup, manual IPs for VIP networks are only specified on the deployment job.

---
## <a id='multi-homed'></a> Multi-homed VMs

A deployment job can be configured to have multiple IP addresses (multiple NICs) by being on multiple networks. Given that there are multiple network settings available for a deployment job, the Agent needs to decide which network's DNS settings to use and which network's gateway should be the default gateway on the VM. Agent performs such selection based on the network's `default` property specified in the deployment job.

Schema for `default` property:

* **default** [Array, optional]: Configures this network to provide its settings for specific category as a default. Possible values are: `dns` and `gateway`. Both values can be specified together.

Example:

```yaml
networks:
- name: my-network-1
  type: dynamic
  dns: [8.8.8.8]
  cloud_properties: {}

- name: my-network-2
  type: dynamic
  dns: [4.4.4.4]
  cloud_properties: {}

jobs:
- name: my-multi-homed-job
  ...
  networks:
  - name: my-network-1
    default: [dns, gateway]
  - name: my-network-2

- name: my-other-multi-homed-job
  ...
  networks:
  - name: my-network-1
    default: [dns]
  - name: my-network-2
    default: [gateway]
```

In the above example, VM allocated to `my-multi-homed-job` deployment job will have `8.8.8.8` as its primary DNS server and the default gateway will be set to `my-network-1`'s gateway. VM allocated to `my-other-multi-homed-job` deployment job will also have `8.8.8.8` as its primary DNS server but the default gateway will be set to `my-network-2`'s gateway.

<p class="note">Note: See <a href="#cpi-limitations">CPI limitations</a> to find which CPIs support this feature.</p>

<p class="note">Note: See <a href="https://github.com/rakutentech/bosh-routing-release">rakutentech/bosh-routing-release</a> if you are looking for even more specific routing configuration.</p>

---
## <a id='cpi-limitations'></a> CPI Limitations

The Director does not enforce how many networks can be assigned to each job instance; however, each CPI might impose custom requirements either due to the IaaS limitations or simply because support was not yet implemented.

|                | static                    | dynamic                 | vip                                  |
|----------------|---------------------------|-------------------------|--------------------------------------|
| AWS            | Single per job instance   | Single per job instance | Single, corresponds to an elastic IP |
| OpenStack      | Multiple per job instance | Single per job instance | Single, corresponds to a floating IP |
| vSphere/vCloud | Multiple per job instance | Not supported           |                                      |

---
## <a id='cloud-properties'></a> CPI Specific `cloud_properties`

- [See AWS CPI network cloud properties](aws-cpi.html#networks)
- [See OpenStack CPI network cloud properties](openstack-cpi.html#networks)
- [See vSphere CPI network cloud properties](vsphere-cpi.html#networks)
- [See vCloud CPI network cloud properties](vcloud-cpi.html#networks)
