---
title: Migrating from one datastore to another
---

<p class="note">Note: This feature is available with bosh-vsphere-cpi v9+.</p>

This topic describes how to migrate VMs and persistent disks from one datastore to another without downtime.

1. Attach new datastore(s) to the hosts where the VMs are running while keeping the old datastore(s) attached to the same hosts.

1. Change deployment manifest for the Director to configure vSphere CPI to reference new datastore(s).

    ```json
    properties:
      vsphere:
        host: 172.16.68.3
        user: root
        password: vmware
        datacenters:
        - name: BOSH_DC
          vm_folder: prod-vms
          template_folder: prod-templates
          disk_path: prod-disks
          datastore_pattern: '\Anew-prod-ds\z' # <---
          persistent_datastore_pattern: '\Anew-prod-ds\z' # <---
          clusters: [BOSH_CL]
    ```

1. Redeploy the Director

1. Verify that the Director VM's root, ephemeral and persistent disks are now on the new datastore(s).

1. For each one of the deployments managed by the Director (visible via [`bosh deployments`](sysadmin-commands.html#deployment)), run [`bosh deploy --recreate`](sysadmin-commands.html#deployment) so that VMs are recreated and persistent disks are reattached.

1. Verify that the persistent disks and VMs were moved to new datastore(s) and there are no remaining disks in the old datastore(s).

---
[Back to Table of Contents](index.html#cpi-config)

Next: [Storage DRS and vMotion Support](vsphere-vmotion-support.html)

Previous: [vSphere HA](vsphere-ha.html)
