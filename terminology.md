---
title: Terminology
---

## <a id="az"></a> AZ or Availability Zone

An availability zone represents a separated set of cloud resources (typically compute, networking and storage) such that failures in one AZ cause minimal impact in a different AZ. [See usage details](azs.md).

---
## <a id="addon"></a> Addon

A release job that is colocated on all VMs managed by the Director. Addons are configured in the runtime config. [See usage details](runtime-config.md).

---
## <a id="agent"></a> Agent

A process that runs continuously on each VM that BOSH deploys (one Agent process per VM). The Agent executes tasks in response to messages it receives from the Director.

---
## <a id="bosh-init"></a> bosh-init

Tool that was replace by CLI v2's `create-env` command used for creating and updating.

---
## <a id="bosh-lite"></a> BOSH Lite

BOSH Lite is a Director VM that is configured to use Warden CPI, which emulates VMs with containers. It's typically installed locally with VirtualBox; however, it could also be installed onto any cloud BOSH supports. [See usage details](bosh-lite.md)

---
## <a id="canary"></a> Canary (Instance)

Canary instances are first instances updated within an instance group. Any update error in a canary instance causes the deployment to stop. Since only canaries are affected before an update stops, problem jobs and packages are prevented from taking over all instances.

---
## <a id="cli"></a> CLI (v1)

The BOSH Command Line Interface (CLI) is what you use to run BOSH commands. You must [install](bosh-cli.md) the CLI to use BOSH. Run `bosh help --all` to view the help. It is superseded by CLI v2.

---
## <a id="cli-v2"></a> CLI v2

The BOSH Command Line Interface (CLI) is what you use to run BOSH commands. CLI v2 is a new major version of CLI. It also replaces bosh-init CLI to manage Director VM. It's the recommended way to interact with the Director. [See usage details](cli-v2.md).

---
## <a id="cloud"></a> Cloud

Same as Infrastructure as a Service.

---
## <a id="cid"></a> Cloud ID (CID)

ID returned from the Cloud identifying particular resource such as VM or disk.

---
## <a id="cloud-config"></a> Cloud Config

The cloud config is a YAML file that defines IaaS specific configuration used by the Director and all deployments. It allows to separate IaaS specific configuration into its own file and keep deployment manifests IaaS agnostic. [See usage details](cloud-config.md).

---
## <a id="compiled-release"></a> Compiled Release

A compiled release contains jobs and compiled packages. A non-compiled release (or just release) contains jobs and source packages. [See usage details](compiled-releases.md).

---
## <a id="cpi"></a> CPI

A Cloud Provider Interface is an abstraction layer between the Director and an IaaS (cloud). CPIs have to implement a small number of methods to perform VM, disk and network operations. CPIs could be written in different languages.

---
## <a id="deploy"></a> Deploy

BOSH deploys software to the cloud using a deployment manifest, one or more stemcells, and one or more releases.

---
## <a id="deployment"></a> Deployment

An encapsulation of software and configuration that BOSH can deploy to the cloud. You can think of a deployment as the state of a collection of VMs: what software is on them, what resources they use, and how these are orchestrated. Even though BOSH creates the deployment using ephemeral resources, the deployment is stable in that BOSH re-creates VMs that fail and otherwise works to keep your software running. BOSH also manages persistent disks so that state (for example, database data files) can survive when VMs are re-created. Combination of a deployment manifest, stemcells, and releases is portable across different clouds with minimal changes to the deployment manifest. See [What is a Deployment?](deployment.md).

---
## <a id="director"></a> Director

The main BOSH component that coordinates the Agents and responds to user requests and system events. The Director is the orchestrator of deployments.

---
## <a id="director-blobstore"></a> Director Blobstore

A repository where BOSH stores release artifacts, logs, stemcells, and other content, at various times during the lifecycle of a BOSH release.

---
## <a id="director-task"></a> Director Task

The basic unit of work performed by the Director. You can get the status and logs for any task. You can monitor the task throughout its lifecycle, which progresses through states like queued, processing, done, and error.

---
## <a id="director-vm"></a> <a id="microbosh"></a> Director VM (previously known as MicroBOSH)

A single VM with the Director and other necessary components.

---
## <a id="disk-type"></a> <a id="disk-pool"></a> Disk Type (previously known as Disk Pool)

Disk type is a named disk configuration specified in the cloud config. [See usage details](cloud-config.md#disk-types) and [read more about persistent disks](persistent-disks.md).

---
## <a id="environment"></a> Environment

An environment consists of a Director and deployments that it orchestrates. A good example of two separate environments are staging and production environments.

---
## <a id="errand"></a> Errand

An errand is a short-lived job that can be triggered by an operator any time after the deploy. Examples:

- smoke tests
- comprehensive test suites
- CF service broker binding and unbinding

[See details](errands.md).

---
## <a id="event"></a> Event

Actions taken by the Director (via user or system control) are recorded as events to the Director database. Examples:

- VM create/delete
- cloud config update

[See details](events.md).

---
## <a id="iaas"></a> IaaS

Short for Infrastructure as a Service. BOSH enables the Cloud Foundry PaaS and other software deployed with BOSH to support multiple IaaS providers.

---
## <a id="instance"></a> Instance

An instance corresponds to a single VM that performs specific jobs. Each instance is a part of an instance group.

---
## <a id="instance-group"></a> Instance Group (previously known as Deployment Job)

An instance group is a collection of instances tasked to perform same jobs. Each instance group has an associated VM type, persistent disk type, a stemcell and a set of jobs. Instance groups are configured in the deployment manifest.

---
## <a id="instance-lifecycle"></a> Instance Lifecycle

Stages that all jobs (and their associated processes) go through during a deployment process on one instance. For example: pre-start, start, drain, etc. [See details](job-lifecycle.md).

---
## <a id="job"></a> Job (aka Release Job)

A job is part of a release. It contains startup, shutdown scripts, and configuration files that tell the Agent how to start, run and monitor software on a VM. Jobs can depend on packages for necessary software. [See details](jobs.md).

---
## <a id="job-lifecycle"></a> Job Lifecycle

Stages that all jobs (and their associated processes) go through during a deployment process on one instance. For example: pre-start, start, drain, etc. [See details](job-lifecycle.md).

---
## <a id="jumpbox"></a> Jumpbox

A VM that acts as a single access point for the Director and deployed VMs. For resilience, there should be more than one jump box. Allowing access through jump boxes and disabling direct access to the other VMs is a common security measure.

---
## <a id="manifest"></a> Deployment manifest (or just manifest)

A YAML file that identifies one or more releases, stemcells and specifies how to configure them for a given deployment.

---
## <a id="operator"></a> Operator

A user that sets up and/or uses the Director (via BOSH CLI or Director API) to manage cloud resources.

---
## <a id="operations-file"></a> Operations file (ops file)

A YAML file that includes multiple operations to be applied to a different YAML file. Several CLI commands such as `create-env` and `interpolate` allow to provide multiple operations files via `--ops-file` flag. [See details](cli-ops-files.md).

---
## <a id="operation"></a> Operation

A single directive in an operations file. An operation describes one change to make to a YAML structure. Currently there are two types of operations: replace and remove. [See details](cli-ops-files.md).

---
## <a id="orphaned-disk"></a> Orphaned (Persistent) Disk

An orphaned disk is a persistent disk that will be garbage collected after a few days unless it's reattached to an instance.

---
## <a id="package"></a> Package

A package is part of a release. It contains vendored in software source and scripts to compile it. Packages can depend on other packages.

---
## <a id="persistent-disk"></a> Persistent Disk

A persistent disk is a disk created in the cloud and associated with a specific [instance](terminology.md#instance). While instance's associated VM is recreated, same persistent disk will be reattached. [See usage details](persistent-disks.md).

---
## <a id="release"></a> Release

A collection of configuration files, source code, jobs, packages and accompanying information needed to make a software component deployable by BOSH. A self-contained release should have no dependencies that need to be fetched from the internet. See [What is a Release?](release.md).

---
## <a id="resource-pool"></a> Resource Pool

Resource pool is collections of VMs created from the same stemcell, with the same configuration, in a deployment.

---
## <a id="runtime-config"></a> Runtime Config

The runtime config is a YAML file that defines global configuration used by the Director and all deployments. It allows to specify addons. [See usage details](runtime-config.md).

---
## <a id="stemcell"></a> Stemcell

A generic VM image that BOSH clones and configures during deployment. A stemcell is a template from which BOSH creates whatever VMs are needed for a wide variety of components and products. See [What is a Stemcell?](stemcell.md).

---
## <a id="team"></a> Team

Each deployment can be managed by specific teams. A logged in UAA user can belong to one or more teams. [See details](director-users-uaa-perms.md#team-admin).

---
## <a id="variable"></a> Variable (var)

Variable points to a saved value in some store. Variables are typically used in configuration files (manifests) to decouple sensitive (passwords, certificates) or volatile (bucket name, number of instances) data from more static content (general configuration). Variables are denoted with double parens -- `((namespace/var-name))`.

---
## <a id="vm-extension"></a> VM Extension

VM extension is a named Virtual Machine configuration in the cloud config that allows to specify arbitrary IaaS specific configuration such as associated security groups and load balancers. [See usage details](cloud-config.md#vm-extensions).

---
## <a id="vm-type"></a> VM Type

VM type is a named Virtual Machine size configuration in the cloud config. [See usage details](cloud-config.md#vm-types).
