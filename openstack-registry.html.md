---
title: Extended Registry configuration
---

<p class="note">Note: We are actively pursuing to remove the Registry to simplify BOSH architecture.</p>

Default configuration typically uses Registry and defaults it to IP source authentication. Due to certain networking configurations (NAT) IP source authentication may not work correctly, hence switching to basic authentication is necessary.

1. Configure the Registry and the OpenStack CPI to use basic authentication by setting `registry.endpoint`

    ```yaml
    properties:
      registry:
        address: PRIVATE-IP
        host: PRIVATE-IP
        db: *db
        http: {user: admin, password: admin-password, port: 25777}
        username: admin
        password: admin-password
        port: 25777
        endpoint: http://admin:admin-password@PRIVATE-IP:25777 # <---
    ```

1. Deploy the Director

---
[Back to Table of Contents](index.html#cpi-config)

Next: [Using human-readable VM names](openstack-human-readable-vm-names.html)

Previous: [Using nova-networking](openstack-nova-networking.html)
