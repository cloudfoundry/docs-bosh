# Stemcell OS: Ubuntu

The base Ubuntu operating system is built from the
[cloudfoundry/bosh-linux-stemcell-builder](https://github.com/cloudfoundry/bosh-linux-stemcell-builder)
repository.

The most recent versions of these distributions are built every few weeks to
ensure the latest upstream patches are included. Critical and High CVEs result
in new stemcells, regardless of the regular interval. These builds are
published on [bosh.io/stemcells](https://bosh.io/stemcells) as new, minor versions.

## Distributions

### Ubuntu Noble (24.04) {: #ubuntu-noble }

You can find the official stemcells from
[bosh.io/stemcells](https://bosh.io/stemcells#ubuntu-noble). Noble Numbat is
an [Ubuntu LTS Release](https://wiki.ubuntu.com/LTS), released April 2024 with
patches being supported until April 2029.

### Ubuntu Jammy (22.04) {: #ubuntu-jammy }

You can find the official stemcells from
[bosh.io/stemcells](https://bosh.io/stemcells#ubuntu-jammy). Jammy Jellyfish
is an [Ubuntu LTS Release](https://wiki.ubuntu.com/LTS), released April 2022
with patches being supported until April 2027.

### Ubuntu Bionic (18.04) {: #ubuntu-bionic }

!!! warning
    Stemcells based on Ubuntu Bionic (18.04) are no longer receiving security
    updates from Open Source Cloud Foundry due to the End of Standard
    Support. We strongly recommend switching to Ubuntu Jammy (22.04) based stemcells.

You can find the official stemcells from
[bosh.io/stemcells](https://bosh.io/stemcells#ubuntu-bionic). Bionic is an
[Ubuntu LTS Release](https://wiki.ubuntu.com/LTS), with patches being
supported by Ubuntu until April 2023.

## Kernel Livepatch Support

Ubuntu's [Kernel Livepatch](https://wiki.ubuntu.com/Kernel/Livepatch)
functionality is not supported in these distributions.

One of the priorities of BOSH is to ensure that software can be deployed in a
highly reproducible, intentional manner. To ensure consistency across IaaSes
(on-premise, public, private, internet-less) and across VMs within a cluster
or deployment, we do not enable Livepatch. Typically, deployments and their
releases are configured to support updates (such as stemcells) to be
continuously deployed in a stable, reliable way without the need forLivepatch.
