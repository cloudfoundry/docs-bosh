!!! note
    This feature is available with bosh-vsphere-cpi v53+. It is disabled by default.

With this feature enabled, when a new vm is created, it will be assigned to a name like `instance-group-name_deployment-name_a81a26b3a9a8` instead of a name like `vm-d6f0f537-18cd-4a1b-b0f5-ae03e8f590e8`.

## Enable the feature
1. Modify Global Configuration:
```yaml
- path: /instance_groups/name=bosh/properties/vcenter?
  type: replace
  value:
    address: ((vcenter_ip))
    datacenters:
    - clusters:
      - ((vcenter_cluster)): {}
      datastore_pattern: ((vcenter_ds))
      disk_path: ((vcenter_disks))
      name: ((vcenter_dc))
      persistent_datastore_pattern: ((vcenter_ds))
      template_folder: ((vcenter_templates))
      vm_folder: ((vcenter_vms))
    password: ((vcenter_password))
    user: ((vcenter_user))
    enable_human_readable_name: true
```

2. Deploy the Director


## More about human readable names
1. Currently vSphere CPI only support names in ASCII characters.

2. The total max length kept for instance group name and deployment name is 65. If original names are longer, names will be trimmed.
