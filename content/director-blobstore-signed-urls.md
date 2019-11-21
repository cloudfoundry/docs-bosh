!!! note "Version compatibility"
    This `blobstore.enable_signed_urls` config property was first introduced in bosh [v268.5.0](https://github.com/cloudfoundry/bosh/releases/tag/v268.5.0) and stemcell [Xenial 621](https://bosh.io/stemcells/#ubuntu-xenial).

## Overview

Opting into this features changes the agent to manage artifacts on the blobstore
using signed URLs. The goal is to restrict access to the blobstore by isolating
bosh actions and removing credentials from disk.

## Usage

This feature can be enabled by updating the bosh director manifest with the
following properties:

* `blobstore.enable_signed_urls`: Set this to true to have the director begin
  sending signed urls to the agent.

**DAV ONLY**

For DAV blobstores, please also configure:

* `blobstore.secret`: The secret used to calculate the signed urls' signature

An ops-file in bosh-deployment can be used to enable signed urls. See: https://github.com/cloudfoundry/bosh-deployment/blob/master/enable-signed-urls.yml
This ops-file assumes a DAV blobstore.

## Notes

Historically there have been many ways of configuring the blobstore. Examples
include through the CPI and through the agent `env` hash. We recommend moving
away from these as they are legacy and in order to gain the benefits this
feature provides.

Additionally, when updating `blobstore.enable_signed_urls` from true to false,
the director will stop generating and sending signed urls to the agents.
Unfortunately, all of the agents do not have blobstore credentials to correctly
process those requests. As an operator updating that property to false, you
**must** recreate all VMs managed by bosh in order to propagate blobstore
credentials to the VMs.
