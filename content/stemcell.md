# What is a Stemcell?

In BOSH, a stemcell is a versioned, base operating system image packaged for a specific infrastructure (IaaS) and pre-configured with the BOSH Agent.

A typical stemcell contains a bare minimum OS skeleton with a few common
utilities pre-installed, a BOSH Agent, and a few configuration files to securely
configure the OS by default. For example: with vSphere, the official stemcell
is a VMDK file inside an OVF package. With AWS, official stemcells are
published as AMIs that can be used in your AWS account.

Stemcells do not contain any specific information about any software that will
be installed once that stemcell becomes a specialized machine in the cluster;
nor do they contain any sensitive information which would make them unable to be
shared with other BOSH users. This clear separation between base Operating
System and later-installed software is what makes stemcells a powerful concept.

In addition to being generic, stemcells for one OS (e.g. all Ubuntu Resolute
stemcells) are as similar as possible across all infrastructures. This property of
stemcells allows BOSH users to quickly and reliably switch between different
infrastructures without worrying about the differences between OS images.

The Cloud Foundry BOSH team produces and maintains an
official set of stemcells. See the [stemcells section of
bosh.io](/stemcells/) to see the infrastructures and operating
systems that are currently supported.

## Supported Operating Systems

BOSH officially supports two operating system families: **Ubuntu Linux** and **Microsoft Windows Server**.

### Ubuntu Linux

Ubuntu Linux is the primary operating system used for BOSH Directors and the vast majority of BOSH-managed workloads.

- **Distributions:** Built from [Ubuntu LTS (Long-Term Support)](https://ubuntu.com/about/release-cycle) releases, including `ubuntu-jammy` (22.04 LTS), `ubuntu-noble` (24.04 LTS), and `ubuntu-resolute` (26.04 LTS).
- **Process Model:** Modern Ubuntu stemcell lines utilize `systemd` and the BOSH Process Manager ([BPM](bpm/bpm.md)) for process supervision, containerized job sandboxing, and resource limits via cgroup v2.
- **Maintenance:** Built and published continuously by the Cloud Foundry BOSH team using the [bosh-linux-stemcell-builder](https://github.com/cloudfoundry/bosh-linux-stemcell-builder).
- For support schedules, lifecycle status, and migration guides, see [Stemcell Lines & Support](stemcell-lines.md).

### Microsoft Windows Server

BOSH supports deploying workloads on Microsoft Windows Server virtual machines, such as Windows application cells for the Cloud Foundry Diego runtime.

- **Distributions:** Built from Windows Server releases, primarily Windows Server 2019 (`windows2019`).
- **Process Model:** Jobs running on Windows stemcells execute within the [Windows Service Wrapper (`winsw`)](https://github.com/kohsuke/winsw) rather than Linux init/supervisors, with lifecycle hooks implemented via PowerShell scripts (`pre-start.ps1`, `drain.ps1`, etc.).
- **Maintenance:** Built using [bosh-windows-stemcell-builder](https://github.com/cloudfoundry/bosh-windows-stemcell-builder) or generated for vSphere using the [`stembuild`](https://github.com/cloudfoundry/stembuild) CLI.
- **Licensing:** Windows stemcells require appropriate Microsoft licensing. On public cloud providers (AWS, Azure, GCP), licensing costs are included in the VM instance pricing. For on-premise environments such as vSphere, operators must provide their own volume-licensed Windows Server media.
- For details, see [Windows licensing](stemcell-lines.md#licensing) and [Windows Compatibility in BOSH](windows.md).

## Stemcell Lines and Versions {: #versions }

A **stemcell line** represents the base operating system release from which the stemcell is constructed (for example, `ubuntu-noble`, `ubuntu-resolute`, or `windows2019`). Each line is maintained in its own builder branch and receives continuous updates for the duration of its supported lifecycle.

For the complete support lifecycle matrix, detailed versioning rules, and guides for migrating across lines, see [Stemcell Lines & Support](stemcell-lines.md).

## Light and Full Stemcells {: #light-stemcells }

Stemcells are published in two formats depending on the infrastructure:

- **Full stemcells** contain the complete OS disk image. When uploaded to the Director, the Cloud Provider Interface (CPI) uploads the raw image to the IaaS and registers it as a reusable VM template or disk image. Full stemcells are published for VMware vSphere, OpenStack, Azure, and local development environments (BOSH Lite).
- **Light stemcells** contain only metadata (`stemcell.MF`) and references to a machine image that has already been published to the cloud provider's public image catalog (such as an AWS AMI or GCP compute image). Because the heavy disk image is already in place on the IaaS, light stemcell tarballs are tiny (a few megabytes) and upload very quickly.

Light stemcells are published for:

- **Amazon Web Services (AWS):** Pre-published AMIs in all standard commercial regions and AWS GovCloud.
- **Google Cloud Platform (GCP):** Pre-published public GCE images.

Full stemcells are published for every supported infrastructure. All available stemcell variants can be downloaded from [bosh.io/stemcells](/stemcells/). See [Uploading Stemcells](uploading-stemcells.md) for how to upload stemcells to your Director.

## How Stemcells are Built

### Ubuntu Linux Stemcells

The source code and pipelines for Ubuntu stemcells are located in the [bosh-linux-stemcell-builder](https://github.com/cloudfoundry/bosh-linux-stemcell-builder) repository.

Each stemcell line is built from its own branch:

- [`ubuntu-resolute`](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/tree/ubuntu-resolute)
- [`ubuntu-noble`](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/tree/ubuntu-noble)
- [`ubuntu-jammy`](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/tree/ubuntu-jammy)

Building an Ubuntu stemcell executes in modular stages. Each stage is defined as a BASH script in `stemcell_builder/stages/<stage_name>/apply.sh`. The stages required for each IaaS are assembled in `stage_collection.rb`. For comprehensive instructions, see [Building a Stemcell](build-stemcell.md).

### Windows Stemcells

Windows stemcells are constructed using the [bosh-windows-stemcell-builder](https://github.com/cloudfoundry/bosh-windows-stemcell-builder) repository or packaged for vSphere using the [`stembuild`](https://github.com/cloudfoundry/stembuild) command-line tool.

For instructions on building a Windows stemcell for vSphere, see [Creating a Windows Stemcell for vSphere Using stembuild](windows-stemcell-create.md).

## Frequently Asked Questions {: #faq }

**How can I tell what packages and versions are installed in a stemcell without booting it?**

Stemcells are distributed as `.tgz` (gzipped tarball) archives. You can extract the `packages.txt` file directly from the archive to inspect all pre-installed packages and their exact versions:

```shell
tar -zxvf stemcell.tgz packages.txt && cat packages.txt
```

**When are stemcells published?**

- **Ubuntu Security Updates:** The stemcell pipeline monitors [Ubuntu Security Notices](https://ubuntu.com/security/notices). When a High or Critical USN affects packages included in the stemcell, a new stemcell build is triggered automatically as soon as patched packages are available from Canonical.
- **Routine Updates:** Low and Medium CVEs, upstream package maintenance, and BOSH Agent improvements are picked up on regularly scheduled automated builds.
- **Windows Updates:** Windows stemcells are published on a regular cadence to incorporate Microsoft cumulative monthly quality and security updates.
- **Testing:** Every build undergoes automated CPI testing before being published to [bosh.io/stemcells](/stemcells/).

**Can a single BOSH deployment use both Ubuntu and Windows stemcells?**

Yes. BOSH manifests support referencing multiple stemcells under the top-level `stemcells` key by giving each an alias. For example, a Cloud Foundry deployment can run control-plane components on an `ubuntu-noble` stemcell and Windows Diego cell instances on a `windows2019` stemcell within the same deployment manifest.

**What are the key differences between stemcell lines?**

Each stemcell line is based on a distinct OS release. For Ubuntu, each line brings a newer Linux kernel, updated system libraries (glibc, OpenSSL), newer compiler runtimes, and evolving security standards (such as cgroup v2 and post-quantum SSH support). Windows stemcell lines provide a native Windows Server environment managed through PowerShell and the Windows Service Wrapper. Dedicated migration guides outline compatibility considerations for each line.

### Related Links

- [bosh.io Stemcell Downloads](/stemcells/)
- [Windows Compatibility in BOSH](windows.md)
- [bosh-linux-stemcell-builder](https://github.com/cloudfoundry/bosh-linux-stemcell-builder)
- [bosh-windows-stemcell-builder](https://github.com/cloudfoundry/bosh-windows-stemcell-builder)
