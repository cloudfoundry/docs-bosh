---
title: Using Keystone API v2
---

Default configuration typically uses Keystone v3 API. This document describes how to use Keystone v2 if your OpenStack installation enforces this.

1. Configure OpenStack CPI

    In `properties.openstack`:
    - switch property `auth_url` to use v2 endpoint.
        <div class="note">Note: path is `v2.0` including the minor revision!</div>
    - add property `tenant`
    - remove properties `domain` and `project`

    ```yaml
    properties:
      openstack: &openstack
        auth_url: https://keystone.my-openstack.com:5000/v2.0 # <--- Replace with Keystone URL
        tenant: OPENSTACK-TENANT # <--- Replace with OpenStack tenant name
        username: OPENSTACK-USERNAME # <--- Replace with OpenStack username
        api_key: OPENSTACK-PASSWORD # <--- Replace with OpenStack password
        default_key_name: bosh
        default_security_groups: [bosh]
    ```

1. Deploy the Director
