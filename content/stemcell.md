A stemcell is a versioned Operating System image wrapped with IaaS specific
packaging.

A typical stemcell contains a bare minimum OS skeleton with a few common
utilities pre-installed, a BOSH Agent, and a few configuration files to securely
configure the OS by default. For example: with vSphere, the official stemcell
for Ubuntu Trusty is an approximately 500MB VMDK file. With AWS, official
stemcells are published as AMIs that can be used in your AWS account.

Stemcells do not contain any specific information about any software that will
be installed once that stemcell becomes a specialized machine in the cluster;
nor do they contain any sensitive information which would make them unable to be
shared with other BOSH users. This clear separation between base Operating
System and later-installed software is what makes stemcells a powerful concept.

In addition to being generic, stemcells for one OS (e.g. all Ubuntu Trusty
stemcells) are exactly the same for all infrastructures. This property of
stemcells allows BOSH users to quickly and reliably switch between different
infrastructures without worrying about the differences between OS images.

The Cloud Foundry BOSH team is responsible for producing and maintaining an
official set of stemcells. See the [stemcells section of
bosh.io](https://bosh.io/stemcells) to see the infrastructures and operating
systems that are currently supported.

Stemcells are distributed as tarballs.

By introducing the concept of a stemcell, the following problems have been
solved:

- Capturing a base Operating System image
- Versioning changes to the Operating System image
- Reusing base Operating System images across VMs of different types
- Reusing base Operating System images across different IaaS

## Common Questions For Linux Stemcells {: #faq }

**Is there a way I can tell what version of a package is used in a BOSH stemcell
without actually installing it?**

Download the stemcell and run `tar -xvf stemcell.tgz packages.txt`. The
`packages.txt` contains a list of all packages installed on the stemcell and
their respective versions.

**What does the stemcell version number mean?**

We have a versioning system that resembles semver. Using an example stemcell
version, `621.45`:

* `621` is the major version number.
* `45` is the patch version number.

The minor version is absent.

Another component to the stemcell version is the Ubuntu distribution that is
the base for the stemcell. There can be major breaking changes in adopting the
next distro, and this can be treated like the "major" component of a semver
version.

**When are stemcells published?**

The schedule for stemcells roughly looks like:

* New LTS distributions from Canonical are consumed around every 2-3 years. This
  is usually an overhaul on how the bosh-agent interacts with the base operating
  system.
* New patches are cut every 3 weeks to pick up any low & medium CVEs published
  by https://usn.ubuntu.com. A patch will also be cut within a week of a high or
  critical CVE being fixed.

**What are the differences between stemcell lines?**

There's not much of a difference between stemcell lines under the hood. They're
all built with the same base image from Canonical and receive the same security
updates. The most important difference is the BOSH agent placed inside the
stemcell, which has compatibility considerations with the BOSH director.

**How is a stemcell is built and how one would go about building their own
stemcell?**

The code lives on GitHub at
https://github.com/cloudfoundry/bosh-linux-stemcell-builder. Building a stemcell
occurs in stages. Each stage is represented as a BASH script and can be found in
`stemcell_builder/stages/<stage_name>/apply.sh`.Each IaaS has its own list of
stages defined here:
https://github.com/cloudfoundry/bosh-linux-stemcell-builder/blob/master/bosh-stemcell/lib/bosh/stemcell/stage_collection.rb.

### Links

* [CI Source Repo](https://github.com/cloudfoundry/bosh-stemcells-ci)
* [Stemcell Builder](https://github.com/cloudfoundry/bosh-linux-stemcell-builder)
* [Stemcell Hardening](https://techdocs.broadcom.com/us/en/vmware-tanzu/platform/tanzu-operations-manager/3-0/tanzu-ops-manager/security-pcf-infrastructure-stemcell-index.html)
