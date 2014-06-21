---
title: Understanding BOSH
---

BOSH is an open source tool chain for release engineering, deployment, and
lifecycle management of large-scale distributed services.

## <a id="stemcell-release-manifest"></a>Parts of a BOSH Deployment ##

Every BOSH deployment consists of three parts: a stemcell, a release, and a
manifest.

### <a id="stemcell"></a>Stemcell ###

A stemcell is a VM template.
BOSH clones new VMs from the stemcell to create the VMs needed for a deployment.
A stemcell contains an OS and an embedded BOSH Agent that allows BOSH to control
VMs cloned from the stemcell.

VMs cloned from a single stemcell can be configured with different CPU, memory,
storage, and network settings, and can have different software packages
installed.
Stemcell are tied to specific cloud infrastructures.

### <a id="release"></a>Release ###

A BOSH release is a collection of source code, configuration files, and startup
scripts, with a version number that identifies these components.
A BOSH release consists of the software packages to be installed and the
processes, or jobs, to run on the VMs in a deployment.

* A package contains source code and a script for compiling and installing the
package, with optional dependencies on other packages.
* A job is a set of configuration files and scripts to run the binaries from a
package.

### <a id="manifest"></a>Manifest ###

The BOSH deployment manifest is a YAML file defining the layout and properties
of the deployment.
When a BOSH operator initiates a new deployment using the BOSH CLI, the BOSH
Director receives a version of the deployment manifest and creates a new
deployment using this manifest.
The manifest describes the configuration of the cloud infrastructure, network
architecture, and VM types, including which operating system each VM runs.

## <a id="stemcell-release-manifest"></a>Deploying with BOSH ##

A BOSH deployment creates runnable software on VMs from a static release.

To deploy with BOSH:

1. Upload a stemcell
1. Upload a release
1. Set deployment with a manifest
1. Deploy

The [stemcell](#stemcell) acts as a template for the new VMs created for the
deployment.
The [manifest](#manifest) defines the values of the parameters needed by the
deployment.
BOSH substitutes the parameters from the manifest into the [release](#release)
and configures the software to run as described in the manifest.

The separation of a BOSH deployment into a stemcell, release, and manifest lets
you make changes to one aspect of a deployment without having to change the
rest.

For example:

* To switch a deployment between clouds:
    * Keep the same release
    * Use a stemcell specific to the new cloud
    * Tweak the manifest
* To scale up an application:
    * Keep the same release
    * Use the same stemcell
    * Change one line in the manifest
* To update or roll back an application:
    * Use a newer or older release version
    * Use the same stemcell
    * Use the same manifest