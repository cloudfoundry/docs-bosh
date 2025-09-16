A BOSH network is an IaaS-agnostic representation of the networking layer. The Director is responsible for configuring each instance group's networks with the help of the BOSH Agent and the IaaS. Networking configuration is usually assigned at the boot of the VM and/or when network configuration changes in the deployment manifest for already-running instance groups.

There are three types of networks that BOSH supports:

* **manual**: The Director decides how to assign IPs to each instance based on the specified network subnets in the deployment manifest
* **dynamic**: The Director defers IP selection to the IaaS
* **vip**: The Director allows one-off IP assignments to specific instances to enable flexible IP routing (e.g. elastic IP)

Each type of network supports one or both IP reservation types:

* **static**: IP is explicitly requested by the user in the deployment manifest
* **automatic**: IP is selected automatically based on the network type

|                         | manual network     | dynamic network | vip network |
|-------------------------|--------------------|-----------------|-------------|
| Static IP assignment    | Supported          | Not supported   | Supported   |
| Automatic IP assignment | Supported, default | Supported       | Supported   |

---
## General Structure {: #general }

Networking configuration is usually done in three steps:

- Configuring the IaaS: Outside of BOSH's responsibility
  - Example on AWS: User creates a VPC and subnets with routing tables.
- Adding networks section to the deployment manifest to define networks used in this deployment
  - Example: User adds a manual network with a subnet and adds AWS subnet ID into the subnet's cloud properties.
- Adding network associations for one or more networks to each instance group

All deployment manifests have a similar structure in terms of network definitions and associations:

```yaml
# cloud-config.yml
---
networks:
- name: my-network
  ...

- name: my-other-network
  type: ...

  # IaaS specific attributes
  cloud_properties: { ... }

# deployment.yml
---
instance_groups:
- name: my-instance-group

  # Network associations for `my-instance-group`
  networks:
  - name: my-network
  ...

- name: my-multi-homed-instance-group
  networks:
  - name: my-network
  - name: my-other-network
  ...

- name: my-static-instance-group
  networks:
  - name: my-network
    # Static IP reservations for `my-instance-group`
    static_ips: [IP1]
  ...
```

See how to define each network type below.

---
## Manual Networks {: #manual }

Manual networking allows you to specify one or more subnets and let the Director choose available IPs from one of the subnet ranges. A subnet definition specifies the CIDR range and, optionally, the gateway and DNS servers. In addition, certain IPs can be blacklisted (the Director will not use these IPs) via the `reserved` property.

Each manual network attached to an instance is typically represented as its own NIC in the IaaS layer. This behavior can be changed by configuring NIC groups, as explained in the networks section of the instance groups manifest definition [here](manifest-v2.md#instance-groups-block--instance-groups-).

Schema for manual network definition:

* **name** [String, required]: Name used to reference this network configuration
* **type** [String, required]: Value should be `manual`
* **subnets** [Array, required]: Lists subnets in this network
    * **range** [String, required]: Subnet IP range that includes all IPs from this subnet
    * **gateway** [String, required]: Subnet gateway IP
    * **dns** [Array, optional]: DNS IP addresses for this subnet
    * **reserved** [Array, optional]: Array of reserved IPs and/or IP ranges. BOSH does not assign IPs from this range to any VM
    * **static** [Array, optional]: Array of static IPs and/or IP ranges. BOSH assigns IPs from this range to instances requesting static IPs. Only IPs specified here can be used for static IP reservations.
    * **prefix** [String, optional]: Size of the prefix BOSH will assign to VMs. Networks that have this property set cannot be used by BOSH itself; therefore, if this is set, a secondary network needs to be attached. Supported from director version `<director_version>` and stemcell `<stemcell_version>`. Find more information in the [Prefix Delegation](#prefix-delegation) section.
    * **az** [String, optional]: AZ associated with this subnet (should only be used when using [first class AZs](azs.md)). Example: `z1`. Available in v241+.
    * **azs** [Array, optional]: List of AZs associated with this subnet (should only be used when using [first class AZs](azs.md)). Example: `[z1, z2]`. Available in v241+.
    * **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties for the subnet. Default is `{}` (empty Hash).

Example cloud config:

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

Manual networks use automatic IP reservation by default. They also support static IP reservation. To assign specific IPs to instances of the instance group, they must be specified in instance group's `networks` section, in the `static_ips` property for the associated network. That network's subnet definition must also specify them in its `static` property:

```yaml
instance_groups:
- name: my-instance-group-with-static-ip
  instances: 2
  ...
  networks:
  - name: my-network

    # IPs associated with 2 instances of `my-instance-group-with-static-ip`
    static_ips: [10.10.1.11, 10.10.1.12]
```

!!! note
    If an instance group uses static IP reservation, all instances must be given static IPs.


### Prefix Delegation {: #prefix-delegation }

Starting with Director release `<director_version>` and stemcell `<stemcell_version>`, BOSH supports prefix delegation. The concepts of static IP addresses and reserved addresses remain as described above.
When the `prefix` property is set, the Director assigns prefix delegations of the specified size to VMs, rather than individual IP addresses.

**Example cloud config:**

```yaml
networks:
- name: my-network-with-prefix
  type: manual

  subnets:
  - range:    10.10.0.0/24
    gateway:  10.10.0.1
    dns:      [10.10.0.2]
    prefix:   28

    cloud_properties: {subnet: subnet-9be6c3f7}
```

In this example, the Director divides the `/24` subnet into `/28` subnets to assign to VMs. The next available base address of the prefix within the subnet range is calculated for each assignment. For example, the first three base addresses would be:

* `10.10.0.0/28`
* `10.10.0.16/28`
* `10.10.0.32/28`

The IP and prefix information will get send to the CPI via the `create_vm` RPC interface.

#### Static IP Clarifications

* If single static IPs are defined in the cloud config, the Director verifies that these IPs are base addresses of the specified prefix. If not, an error is raised.
* If a range of static IP addresses is defined, only the base addresses of the specified prefix are considered as static IPs.

**Considering the following instance group configuration:**

```yaml
instance_groups:
- name: my-instance-group-with-static-ip
  instances: 2
  ...
  networks:
  - name: my-network
    default: 
    - dns
    - gateway
  - name: my-network-with-prefix
```

The Director will send two IP addresses to the CPI:

* The next available single address from the `my-network` network configuration.
* The next available prefix delegation from the `my-network-with-prefix` network configuration.

#### Limitations

* Networks with a `prefix` defined can only be attached as a secondary network.
* Dynamic and VIP networks are not supported.
* Managed networks are not supported.
* Single static IPs must be a base address of the prefix.
* Currently, static IP ranges or CIDRs defined on a network where BOSH will assign the next available IP address
  are currently extended into an array. Large ranges or CIDRs may lead to performance degradation of
  the Director. This is particularly relevant for IPv6 addressing, where CIDR ranges easily contain 
  hundreds of millions of addresses. Size `/112` static ranges for networks without prefix delegation 
  seem manageable, at ca. 65k addresses, but at the moment it is recommended to stay below such sizes.

See supported CPIs in the [CPI Limitations](#cpi-limitations--cpi-limitations-) section.

---
## Dynamic Networks {: #dynamic }

Dynamic networking defers IP selection to the IaaS. For example, AWS assigns a private IP to each instance in the VPC by default. By associating an instance group to a dynamic network, BOSH will pick up AWS-assigned private IP addresses.

Each dynamic network attached to an instance group is typically represented as its own NIC in the IaaS layer.

Dynamic networking only supports automatic IP reservations.

Schema for dynamic network definition:

* **name** [String, required]: Name used to reference this network configuration
* **type** [String, required]: Value should be `dynamic`
* **dns** [Array, optional]: DNS IP addresses for this network
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties for the network. Default is `{}` (empty Hash).

Example cloud config:

```yaml
networks:
- name: my-network
  type: dynamic
  dns:  [10.10.0.2]
  cloud_properties: {subnet: subnet-9be6c3f7}
```

Schema for dynamic network definition with multiple subnets (available in v241+):

* **name** [String, required]: Name used to reference this network configuration
* **type** [String, required]: Value should be `dynamic`
* **subnets** [Array, required]: Lists subnets in this network.
    * **dns** [Array, optional]: DNS IP addresses for this subnet
    * **az** [String, optional]: AZ associated with this subnet (should only be used when using [first class AZs](azs.md)). Example: `z1`.
    * **azs** [Array, optional]: List of AZs associated with this subnet (should only be used when using [first class AZs](azs.md)). Example: `[z1, z2]`.
    * **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties for the subnet. Default is `{}` (empty Hash).

Example cloud config:

```yaml
networks:
- name: my-network
  type: dynamic
  subnets:
  - {az: z1, cloud_properties: {subnet: subnet-9be6c3f7}}
  - {az: z2, cloud_properties: {subnet: subnet-9be6c384}}
```

---
## Virtual IP (VIP) Networks {: #vip }

Virtual IP networking enables the association of an IP address that is not backed by any particular NIC. This flexibility enables users to remap a virtual IP to a different instance in cases of a failure. For IaaS specific implementation details, see the respective cloud provider docs.

VIP network static IPs can either be defined in the deployment manifest (static IP assignment) or in the cloud config (automatic IP assignment). The two assignment types cannot be combined for a given network.

### Static IP Assignment

Schema for VIP network where static IPs are configured in the deployment manifest:

* **name** [String, required]: Name used to reference this network configuration
* **type** [String, required]: Value should be `vip`
* **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties for the network. Default is `{}` (empty Hash).

Sample cloud config and deployment manifest:

```yaml
# cloud-config.yml
---
networks:
- name: my-vip-network
  type: vip

# deployment.yml
---
instance_groups:
- name: my-instance-group
  ...
  networks:
  - name: my-vip-network
    static_ips: [54.47.189.8]
```


### Automatic IP Assignment

!!! note
    Available as of BOSH Director version 269.0.0

Schema for VIP network where static IPs are configured in the cloud config for use across deployments:

* **name** [String, required]: Name used to reference this network configuration
* **type** [String, required]: Value should be `vip`
* **subnets** [Array, optional]: Lists subnets in this network
    * **az** [String, optional]: AZ associated with this subnet (should only be used when using [first class AZs](azs.md)). Example: `z1`.
    * **azs** [Array, optional]: List of AZs associated with this subnet (should only be used when using [first class AZs](azs.md)). Example: `[z1, z2]`.
    * **static** [Array, optional]: Array of static IPs and/or IP ranges. BOSH assigns IPs from this range to instances requesting static IPs. Only IPs specified here can be used for static IP reservations.
    * **cloud_properties** [Hash, optional]: Describes any IaaS-specific properties for the subnet. Default is `{}` (empty Hash).

Sample cloud config and deployment manifest:

```yaml
# cloud-config.yml
---
networks:
- name: my-vip-network
  type: vip
  subnets:
  - azs: [z1, z2]
    static:
    - 203.0.113.10
    - 203.0.113.12

# deployment.yml
---
instance_groups:
- name: my-instance-group
  ...
  networks:
  - name: my-vip-network
```

#### Migrating from Static IP Assignment

To migrate from static IP assignment to automatic IP assignment:

1. Add subnet definitions to the network definition in the cloud config. These will be used to associate sets of IPs to availability zones.
1. Find all IPs currently listed in the `static_ips` property of each instance group's use of that network.
1. Move those IPs into the `static` property of their respective subnet.
1. Delete the `static_ips` property from the network configuration of the instance groups.
1. Update the cloud config and redeploy with the new manifests.

!!! warning
    You will need to perform these steps for each deployment using the VIP network. After enabling the VIP network for automatic IP assignment, deployments relying on it for static IP assignment will error on next deploy.

Sample manifests before migration:

```yaml
# cloud-config.yml
---
networks:
- name: my-vip-network
  type: vip

# deployment.yml
---
instance_groups:
- name: my-instance-group
  azs: [z1, z2]
  ...
  networks:
  - name: my-vip-network
    static_ips:
    - 203.0.113.10
    - 203.0.113.12
```

Sample manifests after migration:

```yaml
# cloud-config.yml
---
networks:
- name: my-vip-network
  type: vip
  subnets:
  - azs: [z1, z2]
    static:
    - 203.0.113.10
    - 203.0.113.12

# deployment.yml
---
instance_groups:
- name: my-instance-group
  ...
  networks:
  - name: my-vip-network
```


---
## Multi-homed VMs {: #multi-homed }

An instance group can be configured to have multiple IP addresses (multiple NICs) by being on multiple networks. Given that there are multiple network settings available for an instance group, the Agent needs to decide which network's DNS settings to use and which network's gateway should be the default gateway on the VM. Agent performs such selection based on the network's `default` property specified in the instance group.

Schema for `default` property:

* **default** [Array, optional]: Configures this network to provide its settings for specific category as a default. Possible values are: `dns`, `gateway` and since bosh-release v258 `addressable`. All values can be specified together. `addressable` can be used to specify which IP address other instances see.

Example:

```yaml
# cloud-config.yml
---
networks:
- name: my-network-1
  type: dynamic
  dns: [8.8.8.8]

- name: my-network-2
  type: dynamic
  dns: [4.4.4.4]

# deployment.yml
---
instance_groups:
- name: my-multi-homed-instance-group
  ...
  networks:
  - name: my-network-1
    default: [dns, gateway]
  - name: my-network-2

- name: my-other-multi-homed-instance-group
  ...
  networks:
  - name: my-network-1
    default: [dns]
  - name: my-network-2
    default: [gateway]
```

In the above example, VM allocated to `my-multi-homed-instance-group` instance group will have `8.8.8.8` as its primary DNS server and the default gateway will be set to `my-network-1`'s gateway. VM allocated to `my-other-multi-homed-instance-group` instance group will also have `8.8.8.8` as its primary DNS server but the default gateway will be set to `my-network-2`'s gateway.

!!! note
    See [CPI limitations](#cpi-limitations) to find which CPIs support this feature.

!!! note
    See [rakutentech/bosh-routing-release](https://github.com/rakutentech/bosh-routing-release) if you are looking for even more specific routing configuration.

---
## CPI Limitations {: #cpi-limitations }

The Director does not enforce how many networks can be assigned to each instance; however, each CPI might impose custom requirements either due to the IaaS limitations or simply because support was not yet implemented.

|           | manual network                                                  | dynamic network             | vip network                          | nic grouping supported for network type | prefix delegation supported for network type |
|-----------|-----------------------------------------------------------------|-----------------------------|--------------------------------------|-----------------------------------------|----------------------------------------------|
| AWS       | Multiple per instance group<sup>1</sup> (from <aws_cpi_version>)| Single per instance group   | Single, corresponds to an elastic IP |manual<sup>2</sup>                       | manual<sup>3</sup>                           |
| Azure     | Multiple per instance group                                     | Multiple per instance group | Single, corresponds to a reserved IP |                                         |                                              |
| OpenStack | [Multiple per instance group](openstack-multiple-networks.md)   | Single per instance group   | Single, corresponds to a floating IP |                                         |                                              |
| vSphere   | Multiple per instance group                                     | Not supported               | Not supported                        |                                         |                                              |

1 = The maximum number of network interfaces attached to a VM is [limited per instance type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AvailableIpPerENI.html). If you want to attach more IP addresses to your VMs check out the nic_group configuration [here](manifest-v2.md#instance-groups-block--instance-groups-).

2 = The maximum number of IP addresses assigned to one NIC (limited by the AWS CPI as of now): one IPv4 address, one IPv6 address, one IPv4 prefix delegation and one IPv6 prefix delegation

3 = Find the currently supported prefix sizes [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-prefix-eni.html)

---
## CPI Specific `cloud_properties` {: #cloud-properties }

- [See AWS CPI network cloud properties](aws-cpi.md#networks)
- [See Azure CPI network cloud properties](azure-cpi.md#networks)
- [See OpenStack CPI network cloud properties](openstack-cpi.md#networks)
- [See Google Cloud Platform CPI network cloud properties](google-cpi.md#networks)
- [See vSphere CPI network cloud properties](vsphere-cpi.md#networks)
