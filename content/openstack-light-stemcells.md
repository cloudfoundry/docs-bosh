---
title: Using Light Stemcells
---

<p class="note">Note: This feature is available with bosh-openstack-cpi v28+.</p>
<p class="note">Note: This feature is available with bosh-cli v2.0.40+.</p>

You can create your own OpenStack light stemcells to re-use stemcell images already uploaded to your OpenStack image store. **Note:** Future deployments will fail if the stemcell image referenced by a light stemcell is removed from your OpenStack image store.

1. Download the heavy stemcell for which you want to create a light stemcell
1. Upload the stemcell to your OpenStack with `bosh upload-stemcell`
1. Retrieve the UUID and version of the uploaded stemcell image with `bosh stemcells`
1. Use `bosh repack-stemcell` to create a light stemcell archive from a heavy stemcell

    ```
    $ bosh repack-stemcell --version "<Stemcell version>" \
   --empty-image \
   --format openstack-light \
   --cloud-properties="{\"image_id\": \"<Stemcell UUID>\"}" \
   heavy-stemcell.tgz ./light-bosh-stemcell-<Stemcell version>-openstack-kvm-ubuntu-trusty-go_agent.tgz
    ```

You can use the light stemcell archive like a regular stemcell archive in BOSH deployment manifests and with `bosh create-env` command.
