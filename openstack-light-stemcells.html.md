---
title: Using Light Stemcells
---

<p class="note">Note: This feature is available with bosh-openstack-cpi v28+.</p>

You can create your own OpenStack light stemcells to re-use stemcell images already uploaded to your OpenStack image store. **Note:** Future deployments will fail if the stemcell image referenced by a light stemcell is removed from your OpenStack image store.

1. Retrieve the UUID of an already uploaded stemcell image e.g. with `openstack image list`
1. Retrieve the operating system and version of the stemcell from the image metadata to  e.g. with `openstack image show <image UUID>`
1. Use the [`create_light_stemcell`](https://github.com/cloudfoundry-incubator/bosh-openstack-cpi-release/blob/master/scripts/create_light_stemcell)  script to create a light stemcell archive

    ```
    $ ./create_light_stemcell --os ubuntu-trusty --version 3312 --image-id 1234-567-890
    ```

You can use the light stemcell archive like a regular stemcell archive in BOSH deployment manifests and with bosh-init.

---
[Back to Table of Contents](index.html#cpi-config)

Previous: [Multi-homed VMs](openstack-multiple-networks.html)
