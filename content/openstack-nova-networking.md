---
title: Using nova-networking
---

<p class="note">Note: This feature is available with bosh-openstack-cpi v28+.</p>

The OpenStack CPI v28+ uses neutron networking by default. This document describes how to enable nova-networking instead if your OpenStack installation doesn't provide neutron. **Note:** nova-networking is deprecated as of the OpenStack Newton release and will be removed in the future.

1. Configure OpenStack CPI

    In `properties.openstack`:
    - add property `use_nova_networking: true`

    ```yaml
    properties:
      openstack: &openstack
        (...)
        use_nova_networking: true
    ```

1. Deploy the Director
