---
title: Basic BOSH Workflow
---

While the distributed software you use BOSH to deploy can be complex, the basic patterns for working with BOSH are straightforward.

You begin by verifying that your IaaS is set up correctly to support BOSH, and then deploying a single-VM BOSH.
How you proceed from there depends on two questions:

1. Whether you want to deploy a Cloud Foundry PaaS, deploy other distributed software, or do both.
1. Whether the single-VM BOSH suits your needs, or a multi-VM BOSH is preferable.

The illustrations below show the two basic choices for building your environment.

<%= image_tag("bosh-arch.png") %>

## <a id="single-vm"></a> Deploying Single-VM BOSH  ##

Before you use BOSH to deploy software, you must first deploy BOSH itself.
You can choose either of the two supported single-VM BOSHes described below, or experimental, community-based methods not documented here.

### <a id="micro"></a> MicroBOSH  ###

MicroBOSH runs within a single VM on any cloud infrastructure that is supported for deploying software with BOSH.
To deploy MicroBOSH you need a stemcell and a manifest, but you do not need a release.
MicroBOSH is suited to deploying software (as an alternative to multi-VM BOSH), and is the only supported way to deploy BOSH for production.
MicroBOSH is included within the stemcell.

### <a id="lite"></a> BOSH Lite  ###

[BOSH Lite] (https://github.com/cloudfoundry/bosh-lite) runs within a single VM created with [Vagrant] (http://www.vagrantup.com/).
Scripts packaged with BOSH Lite make it simple to deploy on a laptop or other local environment.
BOSH Lite is essentially a low-cost, low-risk development environment to test and experiment with BOSH.
To deploy BOSH Lite, you do not need a release, a stemcell, or a manifest, only Vagrant and related files.

## <a id="multi-vm"></a> Deploying Multi-VM BOSH  ##

Once you have MicroBOSH running, you can use it to deploy multi-VM BOSH or any other software that BOSH can deploy.

Some benefits of using multi-VM BOSH over MicroBosh:

 * Easier maintenance of the BOSH parameters: updates to BOSH properties are applied in seconds
 * Easy access to BOSH VMs using `bosh ssh` and BOSH logs
 * Easy monitoring of CPU, disk, and RAM on BOSH VMs using `bosh vms --vitals`

<p class="note"><strong>Note</strong>: As shown in the illustration, deploying Multi-VM BOSH is optional.</p>

To deploy BOSH using MicroBOSH you must:

* [Download](http://bosh-artifacts.cfapps.io) a **release** of BOSH, and a **stemcell** appropriate to the cloud infrastructure and OS where you plan to deploy.

* Create a **manifest** that accounts for environmental constraints and specifies how you want to orchestrate your deployment. See [BOSH Deployment Manifest](./deployment-manifest.html) for more information.

## <a id="deploying"></a> Deploying Software with BOSH  ##

The material in this section applies to either of two scenarios:

* Using MicroBOSH to deploy multi-VM BOSH, Cloud Foundry, or any other software available in a BOSH release.

* Using multi-VM BOSH to deploy Cloud Foundry or any other software available in a BOSH release.

### <a id="before"></a> Before you Deploy  ###

Before you deploy, you must have:

* A **release** that has the software products and services you want.
You can obtain a release from a software provider, or create one yourself.

* A **stemcell** appropriate to the cloud infrastructure and OS where you plan to deploy.
You obtain a stemcell from the [public download site](http://bosh-artifacts.cfapps.io).

* A **manifest** that accounts for environmental constraints and specifies how you want to orchestrate your deployment.
You can modify an example manifest to suit your purposes, or use a tool like 
[spiff](https://github.com/cloudfoundry-incubator/spiff) to create a manifest.

<p class="note"><strong>Note</strong>: This topic speaks of "a release" and "a stemcell" for the sake of simplicity,
but BOSH also supports deploying with multiple releases and multiple stemcells.</p>

### <a id="deploy"></a> The Pattern for Deploying Software with BOSH  ###

To deploy software with BOSH, you perform four steps:

1. Upload stemcell.
1. Upload release.
1. Set deployment with a manifest.
1. Deploy.

This pattern is at the heart of the BOSH workflow, and its power is in simplicity.
Without it, you would likely need to perform a larger number of tasks, many of them difficult to replicate from deployment to deployment.
Because deploying software is an iterative process, the amount of labor that this pattern saves is significant.
