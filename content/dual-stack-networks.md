# Dual Stack Networks with BOSH

Dual stack networking enables BOSH deployments to operate with both IPv4 and IPv6 addresses simultaneously on the same VMs.

## How It Works

BOSH supports dual stack by allowing you to define separate IPv4 and IPv6 networks that attach to the same VM. Each network provides its own IP address, gateway, and DNS configuration.

**Network Configuration:**

- The BOSH Agent configures the operating system to handle both protocols
- Networks can be bound to the same or separate network interfaces

---

## Cloud Config

The cloud config defines how BOSH allocates network resources. For dual stack, create separate [manual networks](networks.md#manual) for IPv4 and IPv6.

**Configuration Points:**

- **Network Type**: Use `type: manual` for static IP assignment
- **Same Subnet**: Both IPv4 and IPv6 networks should reference the same IaaS subnet ID in `cloud_properties`
- **Reserved Ranges**: Reserve gateway and infrastructure addresses to prevent conflicts

!!! tip
    For IaaS-specific network configuration details, see [Network cloud properties](aws-cpi.md#networks).

**Basic Dual Stack Example:**

```yaml
# cloud-config.yml
networks:
- name: default
  type: manual
  subnets:
  - az: z1
    range: 10.0.1.0/24
    reserved:
    - 10.0.1.1 - 10.0.1.10
    gateway: 10.0.1.1
    dns:
    - 10.0.0.2
    cloud_properties:
      subnet: subnet-12345abc
      security_groups: [sg-abcd1234]

- name: default-ipv6
  type: manual
  subnets:
  - az: z1
    range: 2001:db8:1000::/64
    reserved:
    - 2001:db8:1000::1 - 2001:db8:1000::3
    gateway: 2001:db8:1000::1
    dns:
    - fd00:ec2::253
    cloud_properties:
      subnet: subnet-12345abc             # Same subnet supports both protocols
      security_groups: [sg-abcd1234]
```

Apply the cloud config:

```bash
bosh -e <environment> update-cloud-config cloud-config.yml
```

## Deployment Manifest

The deployment manifest specifies which networks each instance group uses. For dual stack, list both the IPv4 and IPv6 networks.

!!! Info
    Check if your CPI supports `nic_group` (see [CPI Network Limitations](networks#cpi-limitations)).

**Key Configuration:**

- **default property**: Use `default: [dns, gateway]` on the network that should provide routing (see [Multi-homed VMs](networks.md#multi-homed))
- **Static IPs**: Specify addresses from the `static` ranges defined in cloud config
- **nic_group (optional)**: Assign the same `nic_group` value to bind networks to the same interface

```yaml
# deployment.yml
---
name: dual-stack-deployment

instance_groups:
- name: web-servers
  instances: 1
  azs: [z1]
  networks:
  - name: default
    default: [dns, gateway]
    static_ips:
    - 10.0.1.15
    nic_group: 1                # Bind to same interface
  - name: default-ipv6
    static_ips:
    - 2001:db8:1000::15
    nic_group: 1                # Bind to same interface
  jobs:
  - name: web-server
    release: my-release
```

Deploy:

```bash
bosh -e <environment> -d dual-stack-deployment deploy deployment.yml
```

## Verify Dual Stack Configuration

Check that the VMs have both IPv4 and IPv6 addresses:

```bash
# Check instance details
bosh -e <environment> -d dual-stack-deployment instances --details

# Example output:
# Instance                    Process State  AZ  IPs
# web-servers/abc123...      running        z1  10.0.1.15
#                                               2001:db8:1000::15

# SSH to a VM and check network configuration
bosh -e <environment> -d dual-stack-deployment ssh web-servers/0

# On the VM, check network interfaces
ip addr show

# Should see both IPv4 and IPv6 on the same interface (when using nic_group):
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001
#     inet 10.0.1.15/24 brd 10.0.1.255 scope global eth0
#     inet6 2001:db8:1000::15/64 scope global

# Test connectivity
ping -c 3 10.0.1.1       # IPv4 gateway
ping6 -c 3 2001:db8:1000::1  # IPv6 gateway
```
