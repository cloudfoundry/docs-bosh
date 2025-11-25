# Dual Stack Networks with BOSH

Dual stack networking enables BOSH deployments to operate with both IPv4 and IPv6 addresses simultaneously.

!!! Note
    BOSH dual stack support requires BOSH Director `v282.1.0+` and Ubuntu Jammy stemcell `v1.943+`.

---
   
## How It Works

BOSH enables dual stack networking through network interface grouping. When you define two separate networks (one IPv4, one IPv6) that:

1. Reference the same IaaS subnet (e.g., AWS subnet ID)
2. Specify the same `nic_group` value

BOSH binds both networks to a single network interface (NIC), assigning both IPv4 and IPv6 addresses. This approach ensures both protocols share the same network path and routing policies.

**Network Binding:**

- Each network definition in the cloud config specifies IP ranges, gateways, and DNS servers
- The `nic_group` parameter determines which physical/virtual interface receives the addresses
- Networks with the same `nic_group` are configured on the same NIC
- The BOSH Agent configures the operating system to handle both protocols

!!! note
    Dual stack networking uses BOSH's multi-homed VM capability to bind multiple networks to a single interface. See [Multi-homed VMs](networks.md#multi-homed) for more details on how this works.

## Infrastructure Support

| IaaS Provider | CPI Version            | Status    |
| ------------- | ---------------------- | --------- |
| AWS           | bosh-aws-cpi v107.0.0+ | Supported |

---

## AWS {: #aws }

This section covers enabling dual stack networking on AWS infrastructure.

### Cloud Config

The cloud config defines how BOSH allocates network resources. For dual stack, you create separate [manual networks](networks.md#manual) for IPv4 and IPv6, then bind them to the same physical interface using `nic_group`.

**Critical Configuration Points:**

- **Network Type**: Both networks must be `type: manual` to support static IP assignment and prefix delegation
- **Same Subnet**: Both IPv4 and IPv6 networks must reference the same IaaS subnet ID in `cloud_properties`
- **Same NIC Group**: Both networks must have `nic_group: 1` (or the same group number)
- **DNS Configuration**: Specify appropriate DNS servers for each protocol
- **Reserved Ranges**: Reserve gateway and infrastructure addresses to prevent conflicts

!!! tip
    For AWS-specific network configuration details, see [AWS CPI network cloud properties](aws-cpi.md#networks).

**With Static IPv6:**

``` yaml
# cloud-config.yml
networks:
- name: default
  type: manual
  subnets:
  - az: z1
    range: 10.0.1.0/24
    reserved:
    - 10.0.1.1-10.0.1.10
    static:
    - 10.0.1.15-10.0.1.20
    gateway: 10.0.1.1
    dns:
    - 10.0.0.2
    nic_group: 1
    cloud_properties:
      subnet: subnet-12345abc
      security_groups:
      - sg-abcd1234
  - az: z2
    range: 10.0.2.0/24
    reserved:
    - 10.0.2.1-10.0.2.10
    static:
    - 10.0.2.15-10.0.2.20
    gateway: 10.0.2.1
    dns:
    - 10.0.0.2
    nic_group: 1
    cloud_properties:
      subnet: subnet-23456bcd
      security_groups:
      - sg-abcd1234
- name: default-ipv6
  type: manual
  subnets:
  - az: z1
    range: 2001:db8:1000::/64
    reserved:
    - 2001:db8:1000::1 - 2001:db8:1000::f
    static:
    - 2001:db8:1000::10 - 2001:db8:1000::1f
    gateway: 2001:db8:1000::1
    dns:
    - fd00:ec2::253
    nic_group: 1
    cloud_properties:
      subnet: subnet-12345abc
      security_groups:
      - sg-abcd1234
  - az: z2
    range: 2001:db8:2000::/64
    reserved:
    - 2001:db8:2000::1 - 2001:db8:2000::f
    static:
    - 2001:db8:2000::10 - 2001:db8:2000::1f
    gateway: 2001:db8:2000::1
    dns:
    - fd00:ec2::253
    nic_group: 1
    cloud_properties:
      subnet: subnet-23456bcd
      security_groups:
      - sg-abcd1234
```

**With Prefix Delegation:**

Prefix delegation is used when VMs need to assign IPv6 addresses to sub-resources (like containers). Instead of a single static IPv6 address, each VM receives an entire IPv6 prefix to allocate as needed.

!!! info
    Prefix delegation is a property of [manual networks](networks.md#manual). The `prefix` parameter in the subnet definition tells BOSH what size prefix to delegate to each VM.

``` yaml
# cloud-config.yml
networks:
- name: default
  type: manual
  subnets:
  - az: z1
    range: 10.0.1.0/24
    reserved:
    - 10.0.1.1-10.0.1.10
    static:
    - 10.0.1.15-10.0.1.20
    gateway: 10.0.1.1
    dns:
    - 10.0.0.2
    nic_group: 1
    cloud_properties:
      subnet: subnet-12345abc
      security_groups:
      - sg-abcd1234
- name: default-ipv6
  type: manual
  subnets:
  - az: z1
    range: 2001:db8:1000::/64
    reserved:
    - 2001:db8:1000::1 - 2001:db8:1000::f
    static:
    - 2001:db8:1000::10 - 2001:db8:1000::1f
    gateway: 2001:db8:1000::1
    dns:
    - fd00:ec2::253
    nic_group: 1
    cloud_properties:
      subnet: subnet-12345abc
      security_groups:
      - sg-abcd1234
- name: prefix_delegation
  type: manual
  subnets:
  - az: z1
    range: 2001:db8:1000::/64
    reserved:
    - 2001:db8:1000::1 - 2001:db8:1000::f
    prefix: 80
    gateway: 2001:db8:1000::1
    dns:
    - fd00:ec2::253  # AWS Route 53 Resolver IPv6 address
    nic_group: 1
    cloud_properties:
      subnet: subnet-12345abc
      security_groups:
      - sg-abcd1234
```

Apply the cloud config:

```bash
bosh -e <environment> update-cloud-config cloud-config.yml
```

### Deployment Manifest Examples

The deployment manifest specifies which networks each instance group uses. For dual stack, list both the IPv4 and IPv6 networks. The order matters: the first network with `default: [dns, gateway]` provides default routing.

**Key Deployment Configuration:**

- **Network Order**: List IPv4 network first with `default` settings for DNS and gateway
- **Static IPs**: Specify addresses from the `static` ranges defined in cloud config
- **Network References**: Use network names defined in your cloud config
- **Stemcell Version**: Ensure you're using a compatible stemcell version

!!! note
    The `default: [dns, gateway]` property determines which network provides DNS and routing. See [Multi-homed VMs](networks.md#multi-homed) for details on the default property.

**With Static IPv6:**

```yaml
# deployment.yml
name: dual-stack

instance_groups:
- name: dual-stack
  instances: 1
  azs: [z1]
  vm_type: default
  stemcell: default
  networks:
  - name: default
    default: [dns, gateway]
    static_ips: ["10.0.1.15"]
  - name: default-ipv6
    static_ips: ["2001:db8:1000::15"]
  jobs:
  - name: dual-stack-job
    release: my-release

stemcells:
- alias: default
  os: ubuntu-jammy
  version: latest

tags:
  project: dual-stack-demo
```

!!! Note
    Use Ubuntu Jammy stemcell version `1.943+` for IPv6 support. Earlier versions do not support dual stack networking.

**With Prefix Delegation:**

```yaml
# deployment.yml
---
name: dual-stack

instance_groups:
- name: dual-stack
  instances: 1
  azs: [z1]
  vm_type: default
  stemcell: default
  networks:
  - name: default
    default: [dns, gateway]
    static_ips: ["10.0.1.15"]
  - name: default-ipv6
    static_ips: ["2001:db8:1000::15"]
  - name: prefix_delegation
  jobs:
  - name: dual-stack-job
    release: my-release

stemcells:
- alias: default
  os: ubuntu-jammy
  version: latest

tags:
  project: dual-stack-demo
```

Deploy:

```bash
bosh -e <environment> -d dual-stack deploy deployment.yml
```

### Verify Dual Stack Configuration

Check that the VMs have both IPv4 and IPv6 addresses:

```bash
# Check instance details
bosh -e <environment> -d dual-stack instances --details

# Example output:
# Instance                    Process State  AZ  IPs
# dual-stack/abc123...       running        z1  10.0.1.15
#                                               2001:db8:1000::15

# SSH to a VM and check network configuration
bosh -e <environment> -d dual-stack ssh dual-stack/0

# On the VM, check network interfaces
ip addr show

# Should see both IPv4 and IPv6 on the same interface, e.g.:
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001
#     inet 10.0.1.15/24 brd 10.0.1.255 scope global eth0
#     inet6 2001:db8:1000::15/64 scope global
```

---

## Example: Prefix Delegation for Diego Cells

This real-world example demonstrates IPv6 prefix delegation for Cloud Foundry Diego cells. Prefix delegation solves a critical challenge: providing unique IPv6 addresses to potentially thousands of application containers across a distributed cell infrastructure.

**The Challenge:**

- Each Diego cell hosts dozens of application containers
- Each container needs a unique, routable IPv6 address
- Static IPv6 allocation doesn't scale for large container populations

**The Solution:**

- Delegate an IPv6 prefix (e.g., /80) to each Diego cell
- The cell's networking layer (Silk) assigns individual addresses from its prefix to containers
- This approach scales to thousands of containers while maintaining address uniqueness

!!! info
    See [Container IPv6 Address Assignment](#container-ipv6-address-assignment) below for details on how Silk manages IPv6 allocation to containers.

### Understanding Prefix Delegation

Prefix delegation creates a hierarchical IPv6 address allocation system. Instead of assigning a single IPv6 address to a VM, BOSH allocates an entire subnet that the VM can subdivide.

**Address Hierarchy:**

```text
AWS VPC IPv6 CIDR:        2001:db8::/56
  ↓
Subnet Range:             2001:db8:1000::/64
  ↓
Delegated to Cell #1:     2001:db8:1000:1::/80
  ↓
Container #1:             2001:db8:1000:1::a1
Container #2:             2001:db8:1000:1::a2
```

**How It Works:**

1. **Cloud Config Definition**: Specify `prefix: 80` in your network subnet configuration
2. **BOSH Allocation**: BOSH assigns each VM an unused /80 prefix from the /64 range
3. **VM Assignment**: The VM's networking stack (e.g., Silk daemon) manages the /80 prefix
4. **Container Addressing**: Individual IPv6 addresses are allocated to containers from the /80 prefix

### Cloud Config with Prefix Delegation

Here's an example cloud config that defines three networks for Diego cells across three availability zones:

```yaml
networks:
- name: diego-cells-ipv6-prefix
  type: manual
  subnets:
  - az: z1
    cloud_properties:
      security_groups:
      - sg-12345abc
      - sg-23456bcd
      - sg-34567cde
      subnet: subnet-1a2b3c4d
    dns:
    - fd00:ec2::253
    gateway: 2001:db8:1000::1
    prefix: 80                                    # Delegate /80 prefixes
    range: 2001:db8:1000::/64                    # Overall /64 range
    reserved:
    - 2001:db8:1000:: - 2001:db8:1000::ffff
    static: []
  - az: z2
    cloud_properties:
      security_groups:
      - sg-12345abc
      - sg-23456bcd
      - sg-34567cde
      subnet: subnet-2b3c4d5e
    dns:
    - fd00:ec2::253
    gateway: 2001:db8:2000::1
    prefix: 80
    range: 2001:db8:2000::/64
    reserved:
    - 2001:db8:2000:: - 2001:db8:2000::ffff
    static: []
  - az: z3
    cloud_properties:
      security_groups:
      - sg-12345abc
      - sg-23456bcd
      - sg-34567cde
      subnet: subnet-3c4d5e6f
    dns:
    - fd00:ec2::253
    gateway: 2001:db8:3000::1
    prefix: 80
    range: 2001:db8:3000::/64
    reserved:
    - 2001:db8:3000:: - 2001:db8:3000::ffff
    static: []
```

**Key Configuration Parameters:**

- **`range`**: The overall IPv6 CIDR block for this subnet (e.g., `2001:db8:1000::/64`)
    - Must match the IPv6 CIDR assigned to your AWS subnet
    - Each availability zone typically has a separate /64

- **`prefix`**: The size of the prefix to delegate to each VM (e.g., `80`)
    - BOSH carves this prefix size out of the `range`
    - Example: From a /64, BOSH can delegate 65,536 unique /80 prefixes

- **`reserved`**: IPv6 addresses BOSH should not allocate
    - Typically reserve the gateway address and low addresses
    - Format: `2001:db8:1000:: - 2001:db8:1000::ffff`

- **`dns`**: DNS server addresses for name resolution
    - `fd00:ec2::253` is the AWS Route 53 Resolver IPv6 address
    - Always available within VPCs that have IPv6 enabled

- **`cloud_properties.security_groups`**: AWS security groups controlling network traffic
    - Multiple groups can be applied to provide layered security
    - Must allow IPv6 traffic between cells and to/from external services

- **`static`**: Empty array `[]` for prefix delegation networks (no static IP assignment needed)

### Deployment Manifest for Diego Cells

Configure your Diego cell instance group to use the IPv6 prefix delegation network:

```yaml
instance_groups:
- name: diego-cell
  azs:
  - z1
  - z2
  - z3
  instances: 124
  env:
    bosh:
      ipv6:
        enable: true
  networks:
  - name: diego-cells                             # IPv4 network
    default: [dns, gateway]
    nic_group: 1
  - name: diego-cells-ipv6-single                 # IPv6 single address
    nic_group: 1
  - name: diego-cells-ipv6-prefix                 # IPv6 with prefix delegation
    nic_group: 1
  jobs:
  - name: silk-daemon
    properties:
      ipv6:
        enable: true
        prefix_network: diego-cells-ipv6-prefix   # Reference the prefix network
  - name: silk-cni
    properties:
      ipv6:
        enable: true
  - name: vxlan-policy-agent
    properties:
      ipv6:
        enable: true
```

**Configuration Breakdown:**

- **`nic_group: 1`**: Binds all three networks to the same physical network interface
    - All networks must have the same `nic_group` value for dual stack to work
    - This ensures IPv4 and IPv6 traffic use the same network path

- **`env.bosh.ipv6.enable: true`**: Enables IPv6 support at the BOSH Agent level
    - The agent configures the OS networking stack for IPv6
    - Must be set for VMs receiving IPv6 addresses or prefixes

- **Three Network Configuration**:
    - **`diego-cells`**: IPv4 network providing default gateway and DNS
    - **`diego-cells-ipv6-single`**: Single IPv6 address for the cell itself
    - **`diego-cells-ipv6-prefix`**: Delegated IPv6 prefix for container allocation

- **Silk Configuration**: The container networking components must be configured:
    - **`silk-daemon.ipv6.prefix_network`**: Tells Silk which network provides the delegated prefix
    - **`silk-cni.ipv6.enable`**: Enables IPv6 in the CNI plugin for container interfaces
    - **`vxlan-policy-agent.ipv6.enable`**: Enables IPv6 in network policy enforcement

### Verifying Prefix Delegation

After deploying with prefix delegation, verify that BOSH correctly assigned IPv6 prefixes to each Diego cell. Each cell should show three IP-related entries.

```bash
# List instances with detailed IP information
bosh -e <env> -d <deployment> instances --details
```

**Example output showing prefix delegation:**

```text
Instance                    IPs
diego-cell/00c4f51a-...     10.0.1.10                     # IPv4
                            2001:db8:3000::4              # IPv6 single address
                            2001:db8:3000:1::/80          # Delegated /80 prefix

diego-cell/0276d7b2-...     10.0.1.11
                            2001:db8:2000::4
                            2001:db8:2000:1::/80

diego-cell/033a35f8-...     10.0.1.12
                            2001:db8:2000::5
                            2001:db8:2000:2::/80
```

**Understanding the Output:**

Each Diego cell receives four IP assignments:

1. **IPv4 Address** (`10.0.1.10`): From the `diego-cells` network, used for cell-to-cell communication
2. **IPv6 Single Address** (`2001:db8:3000::4`): From `diego-cells-ipv6-single`, used for the cell's services
3. **Delegated Prefix** (`2001:db8:3000:1::/80`): The entire /80 subnet allocated to this cell

**Sequential Prefix Allocation:**

BOSH assigns prefixes sequentially. In the example:

- Cell 1 gets `2001:db8:3000:1::/80` (prefix index 1)
- Cell 2 gets `2001:db8:2000:1::/80` (prefix index 1 in different AZ)
- Cell 3 gets `2001:db8:2000:2::/80` (prefix index 2)

Each /64 range can accommodate 65,536 different /80 prefixes.

### Container IPv6 Address Assignment

The Silk networking daemon manages IPv6 address allocation to containers. When a container starts, Silk assigns it an IPv6 address from the cell's delegated prefix.

**Address Allocation Example:**

```text
Diego Cell receives prefix: 2001:db8:3000:1::/80

Silk allocates addresses to containers:
├── App Instance 1, Container 1: 2001:db8:3000:1::a1
├── App Instance 1, Container 2: 2001:db8:3000:1::a2
├── App Instance 2, Container 1: 2001:db8:3000:1::a3
└── App Instance N, Container N: 2001:db8:3000:1::aN
```

**Container Perspective:**

Applications running inside containers can discover their IPv6 addresses through environment variables:

TODO ---------------------------
```bash
# Inside a Cloud Foundry application container
echo $CF_INSTANCE_IP        # 10.255.0.5 (overlay network IPv4)
echo $CF_INSTANCE_XXXX      # 2001:db8:3000:1::a3 (real routable IPv6)
```
TODO ---------------------------

**Networking Characteristics:**

- Each container gets a globally unique, routable IPv6 address
- Containers can communicate directly over IPv6 without NAT
- External services can potentially reach containers directly via IPv6 (subject to firewall rules)
- The IPv6 address persists for the container's lifetime

---

### Limitations {: #limitations }

**Architecture Limitations:**

- **IPv4 Still Required**: Dual stack is additive—you must have IPv4 networking configured. Pure IPv6-only deployments are not supported. See more in [Networks](networks#limitations).
  
- **Single Prefix Per VM**: Each VM can receive only one delegated IPv6 prefix. You cannot delegate multiple prefixes to the same VM.

- **Container External Access**: By default, containers are not directly addressable from the internet, even with routable IPv6 addresses. Traffic must route through the Gorouter or other ingress components.

---

## Troubleshooting {: #troubleshooting }

### IPv6 Address Not Assigned

VM has IPv4 but no IPv6 address:

```bash
# Check stemcell version supports IPv6
bosh -e <env> stemcells

# Verify cloud config has both networks with same nic_group
bosh -e <env> cloud-config

# Verify subnet has IPv6 CIDR in your IaaS
# Check that both networks reference the same subnet ID in cloud_properties

# Review deployment task logs for network configuration errors
bosh -e <env> task <task-id> --debug
```

!!! tip
    Review [BOSH Networks documentation](networks.md) to verify your network definitions follow the correct schema for manual networks.

### Network Connectivity Issues

Test IPv6 connectivity from a Diego cell:

```bash
# SSH into a Diego cell
bosh -e <env> -d <deployment> ssh diego-cell/0

# Check IPv6 configuration
ip -6 addr show

# Test IPv6 connectivity
ping6 2001:4860:4860::8888

# Check routing table
ip -6 route show
```

### Container IPv6 Not Working

If application containers don't have IPv6:

```bash
# Check Silk daemon logs
bosh -e <env> -d <deployment> ssh diego-cell/0
sudo cat /var/vcap/sys/log/silk-daemon/silk-daemon.stdout.log

# Verify prefix delegation in cloud config
bosh -e <env> cloud-config

# Check that ipv6.enable is set in the deployment manifest
bosh -e <env> -d <deployment> manifest
```
