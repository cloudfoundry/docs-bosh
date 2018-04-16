---
title: vSphere HA
---

vSphere High Availability (HA) is a VMware product that detects ESXi host failure, for example host power off or network partition, and automatically restarts virtual machines on other hosts in the cluster.
It can interoperate effectively with the [BOSH Resurrector](resurrector.md), which recreates VMs if the Director loses contact with a VM's BOSH Agent.

<p class="note">Note: This feature is available with bosh-vsphere-cpi v30+.</p>

### vCenter Configuration

Configure vSphere HA as follows:

* Check ***Cluster* &rarr; Manage &rarr; Settings &rarr; vSphere HA &rarr;
Edit... &rarr; Turn on vSphere HA**

* Check **Host Monitoring**

* Ensure the Response for **Failure conditions and VM response &rarr; Host Isolation** is set to **Shut down and restart VMs**

### BOSH Director Configuration

Increase the timeout values of the [BOSH Health Monitor](monitoring.md#vm) on the BOSH Director to allow for smooth interoperation between BOSH and vCenter.
We recommend increasing the `agent_timeout` from the default 60s to 180s in the BOSH Director's manifest to allow vCenter time to detect the failed host:

```yaml
jobs:
- name: bosh
  properties:
    ...
    hm:
      resurrector_enabled: true
      intervals:
        agent_timeout: 180
```

<p class="note"> Warning: If vSphere HA is not enabled on the cluster and a host failure occurs, the BOSH Resurrector will be unable to recreate the VMs without manual intervention.
Follow the manual procedure as appropriate: <a href="vsphere-esxi-host-failure.html">Host Failure</a> or <a href="vsphere-network-partition.html">Network Partition</a>.</p>
