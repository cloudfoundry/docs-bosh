---
title: Managing stemcells
---

(See [What is a Stemcell?](stemcell.md) and [Uploading stemcells](uploading-stemcells.md) for an introduction.)

---
## <a id="versioning"></a> Stemcell versioning

Each stemcell is uniquely identified by its name and version. Currently stemcell versions are in MAJOR.MINOR format. Major version is incremented when new features are added to stemcells (or any components that stemcells typically include such as BOSH Agent). Minor versions are incremented if certain security fixes and/or features are backported on top of existing stemcell line. We recommend to continiously bump to the latest major stemcell version to receive latest updates.

---
## <a id="overview"></a> Overview

You can identify stemcell version from inside the VM via following files:

- `/var/vcap/bosh/etc/stemcell_version`: Example: `3232.1`
- `/var/vcap/bosh/etc/stemcell_git_sha1`: Example: `8c8a6bd2ac5cacb11c421a97e90b888be9612ecb+`

<p class="note">Note: Release authors should not use the contents of these files in their releases.</p>

See [Stemcell Building](build-stemcell.md#tarball-structure) to find stemcell archive structure.

---
## <a id="fix"></a> Fixing corrupted stemcells

Occasionally stemcells are deleted from the IaaS outside of the Director. For example your vSphere administrator decided to clean up your vSphere VMs folder. The Director of course will continue to reference deleted IaaS asset and CPI will eventually raise an error when trying to create new VM. [`bosh upload-stemcell` command](cli-v2.md#upload-stemcell) provides a `--fix` flag which allows to reupload stemcell with the same name and version into the Director fixing this problem.

---
## <a id="clean-up"></a> Cleaning up uploaded stemcells

Over time the Director accumulates stemcells. Stemcells could be deleted manually via [`bosh delete-stemcell` command](cli-v2.md#delete-stemcell) or be cleaned up via [`bosh cleanup` command](cli-v2.md#clean-up).
