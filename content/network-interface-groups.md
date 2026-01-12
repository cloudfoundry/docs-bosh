# Network Interface Groups

The `nic_group` feature allows multiple BOSH networks to be bound to the same physical or virtual network interface card (NIC) on a VM.

## Common Use Cases

- **Dual Stack Networking**: Binding IPv4 and IPv6 networks to the same interface (see [Dual Stack Networks](dual-stack-networks.md))
- **Prefix Delegation**: Attaching a prefix delegation network alongside a primary management network (see [Prefix Delegation](prefix-delegation-networks.md))

## Infrastructure

- The `nic_group` feature requires BOSH Director `v282.1.0+` and Ubuntu Jammy stemcell `v1.943+`.
- CPI that supports network interface grouping. Check [CPI-specific limitations](networks.md#cpi-limitations) for your infrastructure provider

## How It Works

When the BOSH Director creates a VM with multiple networks:

1. The Director sends network configuration for all networks to the CPI via the `create_vm` RPC call
2. The CPI groups networks with the same `nic_group` value and attaches them to a single network interface. Each interface can support up to:
    - 1 IPv4 single address
    - 1 IPv6 single address
    - 1 IPv4 prefix
    - 1 IPv6 prefix
3. Networks without a `nic_group` or with different values are attached to separate network interfaces (subject to VM type limitations)
4. The BOSH Agent configures the operating system to recognize all networks
5. Traffic routing is handled by the VM's network stack based on destination addresses and routing tables

!!! note "Network Interface Groups and Subnets"
    Network interface groups are unique within the assigned subnet. When BOSH deploys a VM to a specific availability zone, it uses only the subnet configuration for that AZ from each network definition in the group.

## Basic Configuration

In your deployment manifest, assign the same `nic_group` value to networks that should share a NIC.

```yaml
instance_groups:
- name: instance-group-name
  networks:
  - name: default
    nic_group: 1
  - name: secondary-network
    nic_group: 1
```

## Verification

Check that networks are properly configured on the same interface:

```bash
# Check network interfaces
ip addr show

# Example output showing both networks on eth0:
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP>
#     inet 10.0.1.10/24 brd 10.0.1.255 scope global eth0
#     inet6 2001:db8:1000::10/64 scope global
```
