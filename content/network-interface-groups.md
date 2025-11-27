# Network Interface Groups

The `nic_group` feature allows multiple BOSH networks to be bound to the same physical or virtual network interface card (NIC) on a VM.

## Common Use Cases

- **Dual Stack Networking**: Binding IPv4 and IPv6 networks to the same interface (see [Dual Stack Networks](dual-stack-networks.md))
- **Prefix Delegation**: Attaching a prefix delegation network alongside a primary management network (see [Prefix Delegation](prefix-delegation-networks.md))

## Infrastructure

- The `nic_group` feature requires BOSH Director `v282.1.0+` and Ubuntu Jammy stemcell `v1.943+`.
- CPI that supports network interface grouping. Check [CPI-specific limitations](networks.md#cpi-limitations) for your infrastructure provider

## How It Works

When the BOSH Director creates a VM with multiple networks sharing a `nic_group`:

1. The Director sends network configuration for all networks in the group to the CPI via the `create_vm` RPC call
2. The CPI configures a single network interface with multiple IP addresses and/or prefixes
3. The BOSH Agent configures the operating system to recognize all networks on the same interface
4. Traffic routing is handled by the VM's network stack based on destination addresses and routing tables

!!! note "Availability Zones and nic_group"
    When a VM is deployed to a specific availability zone (AZ), BOSH only uses the subnet configuration for that AZ from each network definition. Even if your cloud config defines multiple subnets across different AZs for the same network, the `nic_group` will only bind networks from the single AZ where the VM is placed. This means a subnet cannot span multiple AZs, and `nic_group` always operates within a single AZ context.

## Basic Configuration

In your deployment manifest, assign the same `nic_group` value to networks that should share a NIC. You can use any string or number as an identifier:

```yaml
instance_groups:
- name: instance-group-name
  networks:
  - name: default
    nic_group: primary
  - name: secondary-network
    nic_group: primary
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
