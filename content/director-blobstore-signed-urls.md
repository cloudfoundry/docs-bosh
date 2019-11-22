!!! note "Version compatibility"
    This `blobstore.enable_signed_urls` config property was first introduced in bosh v270.8 and the ubuntu-xenial 621.x stemcell.

## Overview

Opting into this features changes the agent to manage artifacts on the blobstore
using signed URLs. The goal is to remove blobstore credentials from all bosh
deployed vms and replace access with signed URLs granting scoped actions

## Usage

For the purpose of this feature, supported stemcells are ubuntu-xenial 621.x and
later. Supported windows stemcells are coming soon.

### Enabling the feature flag

This feature can be enabled by updating the bosh director manifest with the
following properties:

* `blobstore.enable_signed_urls`: Set this to true to have the director begin
  sending signed urls to the agent.

You must continue configuring `blobstore.*` properties. Enabling signed URLs
should work alongside blobstore provider specific encryption options such as
`blobstore.encryption_key` (GCS) and `blobstore.sse_kms_key_id` (AWS).

An ops-file in bosh-deployment can be used to enable signed urls. See: https://github.com/cloudfoundry/bosh-deployment/blob/master/enable-signed-urls.yml
This ops-file assumes a DAV blobstore.

### Removing blobstore credentials from agent VM

After turning on this feature flag, credentials may still be required on VM
disks. This is because we cannot guarantee that all VMs are deployed with
supported stemcells. The bosh-agent on past stemcells still requires blobstore
credentials.

As an operator, you can achieve having credentials not be on disk by:

* If all deployments are using supported stemcells, you may override
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

* For deployments on supported stemcells, you may override a deployment manifest
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
the director will stop generating and sending signed urls to the agents.
Unfortunately, all of the agents do not have blobstore credentials to correctly
process those requests. As an operator updating that property to false, you
**must** recreate all VMs managed by bosh in order to propagate blobstore
credentials to the VMs.
