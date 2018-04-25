!!! note
    This feature is available with bosh-openstack-cpi v23+.

You can enable human-readable VM names in your Director manifest to get VMs with names such as `runner_z1/0` instead of UUIDs such as `vm-3151dbb0-7cea-475b-9ff8-7faa94a8188e`.

1. Enable the human-readable-vm-names feature

    ```yaml
    properties:
      openstack:
        human_readable_vm_names: true
    ```

1. Set the `registry.endpoint` configuration to [include basic auth credentials](openstack-registry.md)

1. Deploy the Director
