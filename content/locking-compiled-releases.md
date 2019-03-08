!!! note
    Available as of BOSH Director version TBD <-- Morgan please fill in

# Motivation

When deploying instance groups that use compiled releases,
if the release is not compiled against the exact stemcell used by the instance group,
Bosh will use the release compiled against the most recent compatible stemcell.

This leads to situations where a simple operator action such as "scale up by 1 VM"
will detect a newer compiled release and update many VMs.

Consider a manifest without `exported_from`

```yml
- name: bpm
  url: https://s3.amazonaws.com/bosh-compiled-release-tarballs/bpm-0.12.3-ubuntu-xenial-250.4.tgz
  version: 0.12.3
```

If this `bpm` release was compiled against `ubuntu-xenial/250.4`
and it is used by an instance group running on `ubuntu-xenial/250.17`,
a deploy will use the `bpm` packages compiled against `ubuntu-xenial/250.4`.

If later, an operator uploads a new bpm release with the same `0.12.3` version,
but compiled against a newer stemcell, `ubuntu-xenial/250.9`,
Bosh will use the new packages compiled against the newer stemcell.

To lock a compiled release and reduce unexpected VM updates,
use `exported_from` in the [releases](deployment-manifest.md#releases) block of your manifest.

# Usage

To specify which compiled packages to use in a deployment, add `exported_from` to the release:

```yml
releases:
- name: bpm
  url: https://s3.amazonaws.com/bosh-compiled-release-tarballs/bpm-0.12.3-ubuntu-xenial-250.4.tgz
  version: 0.12.3
  exported_from:
  - os: ubuntu-xenial
    version: 250.4
```

A deployment with this release specified will always use the packages from this release
compiled against `250.4` and will not update the packages
when newer releases are uploaded.

## Why an array?

`exported_from` is an array to support future use cases, such as matching multiple stemcells.
Currently, only the first entry in `exported_from` is used.

# Caveats

- The `exported_from` field is designed for compiled releases.
If using a source release with `exported_from`,
bosh will not compile the release packages during deployment.

- The stemcell specified in `exported_from` must be compatible
with the stemcell used by the instance group.
This means they have the same `os` and the same major `version`.

- `exported_from` is distinct from the `stemcell` block in a release.
`stemcell` is used when downloading a release from a `url`.
It does not tell bosh which compiled packages to use in a deployment.
