---
title: Using Auto-anti-affinity
---

!!! note
    This feature is available with bosh-openstack-cpi v36+.

!!! note
    This feature is available with OpenStack Mitaka and higher.

In OpenStack, you can use server groups with different policies to influence how VMs are placed on the available hypervisors. In OpenStack Mitaka the policy `soft-anti-affinity` was added, allowing for a best-effort approach to place VMs within a server group on different hypervisors. This means the VM creation does not fail, even when the VM needs to be placed on a hypervisor that does already contain a VM from the same server group.

The OpenStack CPI can automatically create a server group for each instance group in your deployment manifest. Therefore, all instances within an instance group will be placed on different hypervisors in your OpenStack, if hypervisor capacity allows. The server groups are created with the following naming schema `<Director UUID>-<Deployment name>-<Instance group name>`.

With bosh-deployment, you can enable auto-anti-affinity with a [separate ops-file](https://github.com/cloudfoundry/bosh-deployment/blob/master/openstack/auto-anti-affinity.yml). Alternatively, you can set the necessary property manually:

1. Enable auto-anti-affinity in your Director manifest

    ```yaml
    properties:
      (...)
      openstack: &openstack
        enable_auto_anti_affinity: true
    ```
1. Deploy the Director
