---
title: Multi-homed VMs
---

!!! note
    This feature is available with bosh-openstack-cpi v24+.

!!! note
    This feature requires OpenStack Neutron.

### Limitation: This feature requires DHCP to be disabled

Disabling DHCP means that the network devices on your VMs will not get configuration
such as default gateway, DNS, and MTU. If you require specific values for these settings,
you will need to set them by other means.

1. In your Director deployment manifest, set [`properties.openstack.use_dhcp: false`]
   (https://bosh.io/jobs/openstack_cpi?source=github.com/cloudfoundry-incubator/bosh-openstack-cpi-release#p=openstack.use_dhcp).
   This means the BOSH agent will configure the network devices without DHCP. This is a Director-wide setting
   and switches off DHCP for all VMs deployed with this Director.
1. In your Director deployment manifest, set [`properties.openstack.config_drive: cdrom`]
   (https://bosh.io/jobs/openstack_cpi?source=github.com/cloudfoundry-incubator/bosh-openstack-cpi-release#p=openstack.config_drive).
   This means OpenStack will mount a cdrom drive to distribute meta-data and user-data instead of using an HTTP metadata service.
1. In your [BOSH network configuration](networks.md#manual), set `gateway` and `dns` to allow outbound communication.
1. If you're not using VLAN, but a tunnel mechanism for Neutron networking, you also need to set the MTU for your network devices on *all* VMs:
    * GRE Tunnels incur an overhead of 42 bytes, therefore set your MTU to `1458`
    * VXLAN Tunnels incur an overhead of 50 bytes, therefore set your MTU to `1450`

    !!! note
        The above numbers assume that you're using an MTU of 1500 for the physical network. If your physical network is setup differently, adapt the MTU values accordingly.

Setting the MTU for network devices is currently not possible in the deployment manifest's `networks` section and thus requires manual user interaction. We recommend to co-locate the [networking-release](https://github.com/cloudfoundry/networking-release)'s `set_mtu` job using [addons](runtime-config.md#addons).
