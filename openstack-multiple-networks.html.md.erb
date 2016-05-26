---
title: Multi-homed VMs
---

<p class="note">Note: This feature is available with bosh-openstack-cpi v24+.</p>
<p class="note">Note: This feature requires OpenStack Neutron.</p>

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
1. In your [BOSH network configuration](networks.html#manual), set `gateway` and `dns` to allow outbound communication.

If you use GRE Tunnels for Neutron networking, you also need to set the MTU for your network devices to `1454`. This currently cannot be achieved with BOSH and thus requires manual user interaction.

---
[Back to Table of Contents](index.html#cpi-config)

Previous: [Validating self-signed OpenStack endpoints](openstack-self-signed-endpoints.html)
