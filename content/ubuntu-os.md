# Stemcell OS: Ubuntu

The base Ubuntu operating system is built from the [cloudfoundry/bosh-linux-stemcell-builder](https://github.com/cloudfoundry/bosh-linux-stemcell-builder) repository.

The most recent versions of these distributions are built every few weeks to ensure the latest upstream patches are included. Critical and High CVEs result in new stemcells, regardless of the regular interval. These builds are published on [bosh.io/stemcells](https://bosh.io/stemcells) as new, minor versions.

!!! tip
    [Ubuntu Xenial](#ubuntu-xenial) is the recommended Linux distribution for deploying with BOSH.


## Distributions

### Ubuntu Bionic (18.04) {: #ubuntu-bionic }

This is a work in progress and we have yet to release stemcells.  Bionic is an [Ubuntu LTS Release](https://wiki.ubuntu.com/LTS), with patches being supported by Ubuntu until April 2023.

### Ubuntu Xenial (16.04) {: #ubuntu-xenial }

You can find the official stemcells from [bosh.io/stemcells](https://bosh.io/stemcells#ubuntu-xenial). Xenial is an [Ubuntu LTS Release](https://wiki.ubuntu.com/LTS), with patches being supported by Ubuntu from April 2018 to April 2021.

!!! warning
    The Xenial (16.04) version is being deprecated. Maintenance updates will end by April 2021. It is possible for people to continue to build patched Xenial stemcells until 2023 by purchasing [ESM support from Ubuntu](https://ubuntu.com/about/release-cycle) and building their own stemcells.

### Ubuntu Trusty (14.04) - Deprecated {: #ubuntu-trusty }

You can find the official stemcells from [bosh.io/stemcells](https://bosh.io/stemcells#ubuntu-trusty). Trusty is an [Ubuntu LTS Release](https://wiki.ubuntu.com/LTS), with patches being supported by Ubuntu from April 2014 to April 2019.



## Kernel Livepatch Support

Ubuntu's [Kernel Livepatch](https://wiki.ubuntu.com/Kernel/Livepatch) functionality is not supported in these distributions.

One of the priorities of BOSH is to ensure that software can be deployed in a highly reproducible, intentional manner. To ensure consistency across IaaSes (on-premise, public, private, internet-less) and across VMs within a cluster or deployment, we do not enable Livepatch. Typically, deployments and their releases are configured to support updates (such as stemcells) to be continuously deployed in a stable, reliable way without the need for Livepatch.
