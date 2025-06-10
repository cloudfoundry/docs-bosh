!!! note "Version compatibility"
    This `blobstore.enable_signed_urls` config property was first introduced in bosh v270.8, the ubuntu-xenial 621.x stemcell, and the windows 2019.17 stemcell.

## Overview

Opting into this feature changes the agent to manage artifacts on the blobstore
using signed URLs. The goal is to remove blobstore credentials from all bosh
deployed vms and replace access with signed URLs granting scoped actions.

## Usage

For the purpose of this feature, "supported stemcells" are ubuntu-xenial 621.x and
later, and windows 2019.17 and later.

### Enabling the feature flag

This feature can be enabled by updating the Bosh director manifest with the
following properties:

* `blobstore.enable_signed_urls`: set this to `true` to have the director
  begin sending signed urls to the agent.

Enabling signed URLs should work alongside blobstore provider specific
encryption options such as `blobstore.encryption_key` (GCS) and
`blobstore.sse_kms_key_id` (AWS S3).

You must continue configuring `blobstore.*` properties. For
`blobstore.agent.user` and `blobstore.agent.password` you can configure dummy
values because they are no more used but still required in the configuration
templates of some CPIs.

An ops-file in bosh-deployment can be used to enable signed URLs and manage
the unnecessary properties.
See the [bosh-deployment › misc/blobstore-signed-urls.yml](https://github.com/cloudfoundry/bosh-deployment/blob/master/misc/blobstore-signed-urls.yml)
ops file.

### Removing blobstore credentials from agent VM

After turning on this feature flag, credentials may still be required on VM
disks. This is because we cannot guarantee that all VMs are deployed with
supported stemcells. The bosh-agent on past stemcells still requires blobstore
credentials.

As an operator, you can remove credentials from deployment VMs by making the following changes:

* If all deployments are using supported stemcells, override
  the `blobstores` to an empty array in the director manifest.

  ```
  instance_groups:
  - name: bosh
    ...
    properties:
      agent:
        env:
          bosh:
            blobstores: []
  ```

* For deployments on supported stemcells, override individual deployment manifests with the following
  property:

  ```
  instance_groups:
  - name: zookeeper
    ...
    properties:
      env:
        bosh:
          blobstores: []
  ```

* For deployments on unsupported stemcells, please do not make any blobstore
  modifications as blobstore config may be coming from `blobstores` or your CPI.

**DAV ONLY**

For DAV blobstores, please also configure:

* `blobstore.secret`: The secret used to calculate the signed urls' signature

## Notes

Additionally, when updating `blobstore.enable_signed_urls` from true to false,
the director will stop generating and sending signed urls to the agents. If you
update the property to false, you **must** also recreate all VMs managed by bosh
in order to propagate blobstore credentials to the VMs. If you do not recreate 
the VMs, none of the agents will have blobstore credentials to correctly
process requests.

