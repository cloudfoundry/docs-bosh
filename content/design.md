---
title: BOSH Design Principles
---

BOSH is an open framework for managing the full development and deployment life cycle of large-scale distributed software applications.

BOSH:

* Leverages IaaS APIs to create VMs from base images packaged with
  operator-defined network, storage, and software configurations
* Monitors and manages VM and process health, detecting and restarting processes
  or VMs when they become unhealthy
* Updates all VMs reliably and idempotently, whether the update is to the OS, a
  package, or any other component

## BOSH Deployments are Predictable ## {: #predictable }

BOSH compiles the source code in an isolated, sterile environment.
When BOSH completes a deployment or update, the virtual machines deployed
contain only the exact software specified in the release.

BOSH versions all jobs, packages, and releases independently.
Because BOSH automatically versions releases and everything they contain in a
consistent way, the state of your deployment is known throughout its lifecycle.

## BOSH Deployments are Repeatable ## {: #repeatable }

Every time you repeat a BOSH deployment, the result is exactly the same deployed
system.

## BOSH Deployments are Self-Healing ## {: #self-healing }

BOSH monitors the health of processes running on the virtual machines it deploys
and compares the results with the ideal state of the system as described in the
deployment manifest.
If BOSH detects a failed job or non-responsive VM, BOSH can automatically
recreate the job on a new VM.
