# Prefix Delegation

Prefix delegation is a network address allocation technique where BOSH assigns an entire subnet (prefix) to a VM instead of a single IP address. The VM can then subdivide this prefix to allocate individual addresses to internal components, such as application containers or services.

This approach is particularly valuable for container platforms, where a single VM (Diego cell) may host dozens or hundreds of containers, each requiring its own unique, routable IP address.

!!! Note
    BOSH prefix delegation support requires BOSH Director `v282.1.0+` and Ubuntu Jammy stemcell `v1.943+`.

## Infrastructure Support

| IaaS Provider | CPI Version            | Status    |
| ------------- | ---------------------- | --------- |
| AWS           | bosh-aws-cpi v107.0.0+ | Supported |

---

## Prefix Delegation Concepts

### How Prefix Delegation Works

!!! Important
    BOSH cannot use prefix delegation networks for its own communication. Therefore, VMs using prefix delegation must also have a primary network (IPv4 or IPv6) for BOSH management traffic.

When you configure prefix delegation, the BOSH Director automatically subdivides your network range into smaller prefixes and assigns one to each VM. The delegated prefix becomes available to release jobs running on that VM through the job specification object, allowing them to allocate individual addresses from the prefix internally.

#### Example: IPv4

Given a cloud config with `range: 10.10.0.0/24` and `prefix: 28`:

```text
Network: 10.10.0.0/24 (256 addresses)
├─ 10.10.0.0/28   → Reserved (contains gateway, DNS, etc.)
├─ 10.10.0.16/28  → VM #1 (16 addresses: .16-.31)
├─ 10.10.0.32/28  → VM #2 (16 addresses: .32-.47)
├─ 10.10.0.48/28  → VM #3 (16 addresses: .48-.63)
└─ ... (up to 16 VMs total)
```

Each `/28` prefix provides 16 IP addresses (14 usable after network and broadcast addresses).

#### Example: IPv6

Given a cloud config with `range: 2001:db8::/64` and `prefix: 80`:

```text
Network: 2001:db8::/64 (2^64 addresses)
├─ 2001:db8::0/80         → Reserved
├─ 2001:db8:0:0:1::/80    → VM #1 (281 trillion addresses)
├─ 2001:db8:0:0:2::/80    → VM #2 (281 trillion addresses)
├─ 2001:db8:0:0:3::/80    → VM #3 (281 trillion addresses)
└─ ... (up to 65,536 VMs possible)
```

Each `/80` prefix provides 2^48 addresses—more than enough for any container workload.

!!! warning "AWS IPv6 Prefix Limitation"
    AWS only allows IPv6 prefix delegation of `/80` prefixes.

#### Full Address Flow Example

This shows how addresses flow from infrastructure to containers:

**IPv4 Flow:**

```text
AWS VPC: 10.0.0.0/16
  └─> BOSH Subnet: 10.0.1.0/24 (prefix: 28)
      └─> VM receives: 10.0.1.16/28
          └─> Container 1: 10.0.1.17
          └─> Container 2: 10.0.1.18
          └─> Container 3: 10.0.1.19
```

**IPv6 Flow:**

```text
AWS VPC: 2001:db8::/56
  └─> BOSH Subnet: 2001:db8:1000::/64 (prefix: 80)
      └─> VM receives: 2001:db8:1000:1::/80
          └─> Container 1: 2001:db8:1000:1::1
          └─> Container 2: 2001:db8:1000:1::2
          └─> Container 3: 2001:db8:1000:1::3
```

### Network Interface Groups

The `nic_group` feature allows multiple networks to be bound to the same physical or virtual network interface card (NIC).

More details on `nic_group` can be found in the [Network Interface Groups](network-interface-groups.md) documentation.

---

## Configuration in BOSH

### Cloud Config

Define prefix delegation in the network subnet configuration using the `prefix` parameter in the manual network's subnet definition.

!!! note "IaaS Reserved Addresses"
    Infrastructure providers reserve certain IP addresses in each subnet. For example, AWS reserves the first 4 IPv6 addresses (::0 through ::3) for network address, VPC router, DNS, and future use. Always include these in your `reserved` range. See your IaaS provider's documentation for specific reserved address requirements.

**IPv6 Example:**

```yaml
networks:
- name: default
  type: manual
  subnets:
  - az: z1
    range: 2001:db8:2000::/64
    gateway: 2001:db8:2000::1
    reserved:
    - '2001:db8:2000:: - 2001:db8:2000::3'
    cloud_properties:
      subnet: subnet-abc123
      security_groups: [sg-xyz789]
- name: diego-cells-prefix
  type: manual
  subnets:
  - az: z1
    range: 2001:db8:1000::/64         # Overall range
    prefix: 80                        # Delegate /80 to each VM
    gateway: 2001:db8:1000::1
    reserved:
    - '2001:db8:1000:: - 2001:db8:1000::3'
    cloud_properties:
      subnet: subnet-abc123
      security_groups: [sg-xyz789]
```

**IPv4 Example:**

```yaml
networks:
- name: default
  type: manual
  subnets:
  - az: z1
    range: 10.0.0.0/24               # Primary network subnet
    gateway: 10.0.0.1
    reserved:
    - 10.0.0.1 - 10.0.0.3
    cloud_properties:
      subnet: subnet-abc123
      security_groups: [sg-xyz789]
- name: diego-cells-prefix
  type: manual
  subnets:
  - az: z1
    range: 10.0.1.0/24               # Prefix delegation subnet
    prefix: 28                       # Delegate /28 to each VM
    gateway: 10.0.1.1
    reserved:
    - 10.0.1.0 - 10.0.1.3
    cloud_properties:
      subnet: subnet-abc123
      security_groups: [sg-xyz789]
```

### Deployment Manifest

In your deployment manifest, reference both networks as usual. BOSH uses the network marked with `default: [dns, gateway]` (see [Multi-homed VMs](networks.md#multi-homed)) for management communication. The prefix delegation network provides the delegated prefix for container workloads.

While it's recommended to use `nic_group` to bind both networks to the same NIC for efficiency, it's optional. Without `nic_group`, each network will be attached to a separate NIC.

**IPv6 Example:**

```yaml
instance_groups:
- name: diego-cell
  instances: 10
  networks:
  - name: default          # Primary network for BOSH management
    default: [dns, gateway]
    nic_group: 1
  - name: diego-cells-prefix        # Prefix delegation network
    nic_group: 1                    # Same nic_group binds to same NIC
```

**IPv4 Example:**

```yaml
instance_groups:
- name: diego-cell
  instances: 10
  networks:
  - name: default                   # Primary network for BOSH management
    default: [dns, gateway]
    nic_group: 1
  - name: diego-cells-prefix        # Prefix delegation network
    nic_group: 1                    # Same nic_group binds to same NIC
```

Both networks are configured on the same NIC because they share `nic_group: 1`.

### Verification

Check that BOSH assigned prefixes correctly:

```bash
bosh -e <env> -d <deployment> instances --details
```

Expected output shows each VM with its delegated prefix:

**IPv6-only scenario:**

```text
Instance                    IPs
diego-cell/0                2001:db8:2000::10           # Primary management IP
                            2001:db8:1000:1::/80        # Delegated IPv6 prefix

diego-cell/1                2001:db8:2000::11
                            2001:db8:1000:2::/80

diego-cell/2                2001:db8:2000::12
                            2001:db8:1000:3::/80
```

**IPv4-only scenario:**

```text
Instance                    IPs
diego-cell/0                10.0.0.10         # Primary management IP (IPv4)
                            10.0.1.16/28      # Delegated IPv4 prefix

diego-cell/1                10.0.0.11
                            10.0.1.32/28

diego-cell/2                10.0.0.12
                            10.0.1.48/28
```

---

## Limitations and Considerations

- **Management Network Required**: BOSH cannot use prefix delegation networks for its own communication, so VMs must have a separate primary network for BOSH management traffic.

- **Dual Stack Support**: Prefix delegation can be used in dual stack scenarios when subnets are configured correctly. For example, a VM can have a single IPv4 address, a single IPv6 address, and an IPv6 prefix delegation network.

- **IaaS-Specific Limitations**: Different cloud providers may have specific constraints on prefix sizes and delegation capabilities.

---

## Troubleshooting

### Prefix Not Assigned

If VMs don't receive delegated prefixes:

```bash
# Check cloud config for prefix configuration
bosh -e <env> cloud-config | grep "prefix:"

# Verify stemcell supports prefix delegation
bosh -e <env> stemcells

# Review deployment task for errors
bosh -e <env> task <task-id> --debug
```
