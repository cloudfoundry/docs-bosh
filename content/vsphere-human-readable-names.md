!!! note
    This feature is enabled by default with bosh-vsphere-cpi v53+.

With this feature enabled, when a new vm is created, it will be assigned a name like `instance-group-name_deployment-name_a81a26b3a9a8` instead of a name like `vm-d6f0f537-18cd-4a1b-b0f5-ae03e8f590e8`.

# Disable/Enable the feature

1. Modify Global Configuration:
```- path: /instance_groups/name=bosh/properties/vcenter?
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
    enable_human_readable_name: false
```

2. Deploy the Director


# More about human readable names

1. Currently vSphere CPI only support names in ASCII characters ( also need to obey to existing naming policies )

2. The total length kept for instance group name and deployment name is 65. If original names are longer, names will be trimmed. A 25 digits space is  guaranteed for deployment name part if need to trim; for instance group name, the number is 40.
