---
title: Explicit ARP Flushing
---

<p class="note">Note: This feature is available with bosh-release v256+ and 3232+ stemcell series.</p>

Certain IaaSes may limit and/or disable gratuitous ARP for security reasons (for example AWS). Linux kernel performs periodic garbage collection of stale ARP entries; however, if there are open or stale connections these entries will not be cleared causing new connections to fail since they just use an existing *outdated* MAC address.

The Director is fully in control of when the VMs are created so it's able to communicate with the other VMs it manages and issues an explicit `delete_arp_entries` Agent RPC call to clear stale ARP entries.

To enable this feature:

1. Add [director.flush_arp](http://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh#p=director.flush_arp) deployment manifest for the Director:

    ```yaml
    properties:
      director:
        flush_arp: true
    ```

1. Redeploy the Director.

---
[Back to Table of Contents](index.html#director-config)
