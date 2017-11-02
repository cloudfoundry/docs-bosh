---
title: Migrating to bosh-init from the micro CLI plugin
---

The micro CLI plugin is deprecated and will be discontinued in a few months. `bosh-init` replaces its functionality and improves on its features. If you do not maintain a MicroBOSH VM, there is no need to do anything; however, if you do please follow these steps:

1. [Install bosh-init](install-bosh-init.html).

1. Review [Using bosh-init](using-bosh-init.html).

1. Familiarize yourself with how to write a deployment manifest for the Director VM (previously referred to as MicroBOSH) following examples mentioned on one of these pages depending on your IaaS:
  - [Initializing on AWS](init-aws.html)
  - [Initializing on OpenStack](init-openstack.html)
  - [Initializing on vSphere](init-vsphere.html)
  - [Initializing on vCloud](init-vcloud.html)

1. Create a deployment manifest (for example `bosh.yml`) based on one of the above examples.

    <p class="note">Note: Make sure NATS, blobstore, and database settings used by the Director, registry, and DNS server match your previous configuration.</p>

1. Copy `bosh-deployments.yml` to the deployment directory that contains your new deployment manifest. `bosh-deployments.yml` is a state file produced and updated by the micro CLI. It contains VM and persistent disk IDs of your current MicroBOSH VM.

1. Run `bosh-init deploy ./bosh.yml`. `bosh-init` will find `bosh-deployments.yml` in your deployment directory, convert it to a new deployment state file (in our example `bosh-state.json`) and update the Director VM as specified by deployment manifest.

1. Save the deployment state file left in your deployment directory so you can later update/delete your Director. See [Deployment state](using-bosh-init.html#deployment-state) section of 'Using bosh-init' for more details.

1. Target your Director with the BOSH CLI and run `bosh deployments` command to confirm your existing deployments were migrated.
