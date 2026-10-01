# Stemcell Lines & Support

Stemcells are versioned base operating system images built and maintained for BOSH deployments. Each **stemcell line** represents a specific base operating system release (such as an Ubuntu LTS release or a Windows Server release) and is maintained on its own branch in the stemcell builder repositories.

Ubuntu stemcells are built from the [cloudfoundry/bosh-linux-stemcell-builder](https://github.com/cloudfoundry/bosh-linux-stemcell-builder) repository, and Windows stemcells are built from the [cloudfoundry/bosh-windows-stemcell-builder](https://github.com/cloudfoundry/bosh-windows-stemcell-builder) repository.

Supported lines are rebuilt regularly to pick up the latest upstream patches. High and Critical CVEs result in new stemcells, regardless of the regular build interval. Official builds are published on [bosh.io/stemcells](/stemcells/) as new versions.

## Stemcell Lines and Versioning {: #versions }

A **stemcell line** represents the base operating system release from which the stemcell is constructed (for example, `ubuntu-noble`, `ubuntu-resolute`, or `windows2019`). Each line is maintained in its own builder branch and receives continuous updates for the duration of its supported lifecycle.

### Version Formats

Stemcell version numbers identify the build iteration and stability of a release:

- **Ubuntu Stemcells (`MAJOR.PATCH`):**
  - **`PATCH`** increases with every automated build, incorporating upstream security patches (Ubuntu Security Notices / CVEs) and BOSH Agent improvements.
  - **`MAJOR`** changes rarely, signalling significant architectural or configuration changes within the line.
  - **Alpha and GA releases:** When a new Ubuntu line is introduced (such as `ubuntu-resolute`), builds start with major version `0.x` during alpha development and testing. Once the line reaches General Availability (GA), versions transition to `1.x`. Do not deploy `0.x` alpha stemcells in production.
- **Windows Stemcells (`YEAR.PATCH`):**
  - Windows stemcell versions reflect the Windows Server release year followed by an incrementing build number (for example, `2019.95`).

## Support Lifecycle {: #lifecycle }

<a id="ubuntu-resolute"></a><a id="ubuntu-noble"></a><a id="ubuntu-jammy"></a><a id="windows-server-2019"></a><a id="distributions"></a>

| Stemcell line | Operating system / version | Upstream release date | Standard support ends | Stemcell status |
|---|---|---|---|---|
| [`ubuntu-resolute`](/stemcells/#ubuntu-resolute) | Ubuntu 26.04 LTS (Resolute Raccoon) | April 2026 | May 2031 | Alpha (`0.x`) |
| [`ubuntu-noble`](/stemcells/#ubuntu-noble) | Ubuntu 24.04 LTS (Noble Numbat) | April 2024 | May 2029 | Generally available |
| [`ubuntu-jammy`](/stemcells/#ubuntu-jammy) | Ubuntu 22.04 LTS (Jammy Jellyfish) | April 2022 | May 2027 | Generally available |
| [`windows2019`](/stemcells/#windows2019) | Windows Server 2019 | October 2018 | January 2029[^windows-support] | Generally available |

- **Alpha**: Published for testing and early adoption. Versions start at `0.x`. Don't use in production.
- **Generally available**: Supported and receives security updates. Plan to migrate to a newer line before upstream standard support ends.

[^windows-support]: For Windows Server 2019 this is the end of Microsoft's extended support. Mainstream support ended in January 2024.

## Upgrading Across Lines

Upgrading from one stemcell line to another (such as moving from `ubuntu-jammy` to `ubuntu-noble` or `ubuntu-resolute`, or upgrading Windows Server releases) represents a major platform milestone. Moving to a newer line can introduce updated Linux kernels or Windows OS builds, newer compiler toolchains (such as GCC upgrades), updated system libraries, and changes to default system utilities.

Migration guides are provided to help platform engineers and release authors navigate these transitions:

- [Migrating to Resolute Raccoon (Platform Engineers)](resolute-migration.md)
- [Migrating Releases to Resolute Raccoon (Release Authors)](resolute-release-migration.md)
- [Migrating to Noble Numbat](noble-migration.md)
- [Migrating Packages to Jammy Jellyfish](jammy-migration.md)

## Windows Licensing {: #licensing }

Windows stemcells will have additional costs associated with Microsoft
licensing; they do not include actual Windows OS. When using light stemcells
on public clouds, additional costs will be associated with your virtual
machine. For more information on building Windows stemcells and running in
on-premise environments, please see this [Creating a Windows Stemcell for
vSphere Using stembuild](./windows-stemcell-create.md) and [Getting
Started](https://github.com/cloudfoundry-incubator/bosh-windows-stemcell-builder/wiki/BOSH-Windows-Getting-Started-Guide)
(deprecated) guide.

## Kernel Livepatch Support

Ubuntu's [Kernel Livepatch](https://ubuntu.com/security/livepatch)
functionality is not supported in these distributions.

One of the priorities of BOSH is to ensure that software can be deployed in a
highly reproducible, intentional manner. To ensure consistency across IaaSes
(on-premise, public, private, internet-less) and across VMs within a cluster
or deployment, we do not enable Livepatch. Typically, deployments and their
releases are configured to support updates (such as stemcells) to be
continuously deployed in a stable, reliable way without the need for Livepatch.
