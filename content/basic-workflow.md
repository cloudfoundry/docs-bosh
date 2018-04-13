---
title: Deploy Workflow
---

(Follow [Create an environment?](init.md) to create the Director.)

The Director can manage multiple [deployments](terminology.md#deployment).

Creation of a deployment consists of the following steps:

- Create a [cloud config](terminology.md#cloud-config)
- Create a [deployment manifest](terminology.md#manifest)
- Upload stemcells and releases from the deployment manifest
- Kick off the deploy to make a deployment on the Director

Updating an existing deployment is the same procedure:

- Update cloud config if anything changed
- Update deployment manifest if anything changed
- Upload new stemcells and/or releases if necessary
- Kick off the deploy to apply changes to the deployment

In the next several steps we are going to deploy simple [Zookeeper](https://en.wikipedia.org/wiki/Apache_ZooKeeper) deployment to the Director.
