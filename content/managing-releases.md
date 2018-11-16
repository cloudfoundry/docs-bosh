(See [What is a Release?](release.md) and [Uploading releases](uploading-releases.md) for an introduction.)

---
## Jobs and Packages {: #jobs-and-packages }

Each job and package is uniquely identified by its name and fingerprint. A fingerprint is calculated based on the contents of all associated files, their permissions. A release captures set of job and package versions that depend on each other and gives it a name and a version. The CLI also records additional metadata when creating releases such as Git SHA.

For example here is a release description (e.g. `releases/zookeeper/zookeeper-0.0.5.yml`) in an example [Zookeeper release](https://github.com/cppforlife/zookeeper-release):

```yaml
name: zookeeper
version: 0.0.5
commit_hash: 9f0bb43
uncommitted_changes: false
jobs:
- name: smoke-tests
  version: 840b14bc609483bb03cf87a938bc69e76a6e2d88
  fingerprint: 840b14bc609483bb03cf87a938bc69e76a6e2d88
  sha1: abafa9fc0c4d35fc818cc55438cbf19bd029a418
- name: zookeeper
  version: 2b29580fbc390762956826f4cb0d3517b6a01ca9
  fingerprint: 2b29580fbc390762956826f4cb0d3517b6a01ca9
  sha1: 8087993b361eee28ec779700c60ad26edaa37f0f
packages:
- name: golang-1.7
  version: 482e72c8435a11e1d1c3c25e4ee86ced53cc8739
  fingerprint: 482e72c8435a11e1d1c3c25e4ee86ced53cc8739
  sha1: 12917d086a9d92d208abfba279acd11aa627eec1
  dependencies: []
- name: java
  version: c524e46e61b37894935ae28016973e0e8644fcde
  fingerprint: c524e46e61b37894935ae28016973e0e8644fcde
  sha1: a1f0001e124f33ad6c9258e6113a3e730c7e82b9
  dependencies: []
- name: smoke-tests
  version: 2a8864e206d64ac968c19c6883b7043cb8d3b880
  fingerprint: 2a8864e206d64ac968c19c6883b7043cb8d3b880
  sha1: 40d38f6c3cfa4712bfcdca15a67c459a1672a027
  dependencies:
  - golang-1.7
- name: zookeeper
  version: ca455273c83e828eb50a21d21811684eceda2603
  fingerprint: ca455273c83e828eb50a21d21811684eceda2603
  sha1: d42e0023eb3d493e165ed0e36ae8643c8bfe535d
  dependencies: []
license:
  version: e79e93c49714f52c0a231c78d480ea1ca757c8f9
  fingerprint: e79e93c49714f52c0a231c78d480ea1ca757c8f9
  sha1: 09d28a6f4fc5b6725733add015e79928f7546a32
```

Job and package names and fingerprints are used throughout the system to identify if certain actions need to be taken. Two primary uses are:

- to determine if packages need to be uploaded to the Director when uploading a release
- to determine if instances need to be updated during a [deployment procedure](deploying-step-by-step.md)

---
## Version uniqueness {: #uniqueness }

There exists an implicit trust between a release author and an operator that different release (a different set of jobs and packages) will not be published under the same version. The Director will reject new set of jobs and packages during the upload if it does not match with already uploaded contents.

Sometimes however two different releases (e.g. 1.0.1 and 1.0.3) may end up with exactly same set of jobs and packages. In fact running [`bosh create-release` command](cli-v2.md#create-release) a few times in a row will produce new releases with only version being different (e.g. 1.0.1+dev.0 and 1.0.1+dev.1). Operators should be aware that even if the deployment procedure shows release version changing there is a chance that no instances will be updated. This initially may be a surprising behaviour; however, given that the Director correctly determines that there are no changes to apply to the instances, there is really nothing to do. After the deploy is finished, [`bosh deployments` command](cli-v2.md#deployments) will of course state that new release is used.

---
## Inspecting uploaded releases {: #inspect }

Once release is uploaded to the Director, it can be inspected via [`bosh inspect-release` command](cli-v2.md#inspect-release). It will show names and fingerprints of jobs and packages. It will also show job details such as consumed and provided links.

```shell
$ bosh -e vbox inspect-release zookeeper/0.0.5
Using environment '192.168.56.6' as '?'

Job                                                   Blobstore ID                          Digest                                    Links Consumed           Links Provided
smoke-tests/840b14bc609483bb03cf87a938bc69e76a6e2d88  98a1fb64-9851-4c28-bac5-df8a96d76449  abafa9fc0c4d35fc818cc55438cbf19bd029a418  - name: conn             -
                                                                                                                                        type: zookeeper
zookeeper/2b29580fbc390762956826f4cb0d3517b6a01ca9    97f299f8-7abf-4393-b3db-1bf33880d154  8087993b361eee28ec779700c60ad26edaa37f0f  - name: peers            - name: conn
                                                                                                                                        type: zookeeper_peers    type: zookeeper
                                                                                                                                                               - name: peers
                                                                                                                                                                 type: zookeeper_peers

2 jobs

Package                                               Compiled for          Blobstore ID                          Digest
golang-1.7/482e72c8435a11e1d1c3c25e4ee86ced53cc8739   (source)              d96c7916-d852-4e8a-ab48-404b0be1fdce  12917d086a9d92d208abfba279acd11aa627eec1
~                                                     ubuntu-trusty/3421.4  bb02fe9d-9bc6-46ab-4319-8b68262c76cb  b8b55284bc386d279dce1056249f9f511b03e26a
java/c524e46e61b37894935ae28016973e0e8644fcde         (source)              68e0a834-3da4-4e74-a34e-0452cec61574  a1f0001e124f33ad6c9258e6113a3e730c7e82b9
~                                                     ubuntu-trusty/3421.4  94c5f41b-1167-4a9e-5c25-e8e985baa5c8  e61c93539b557c7f8833dc73aa9dd84fd4a1c7b5
smoke-tests/2a8864e206d64ac968c19c6883b7043cb8d3b880  (source)              18dad544-9a4d-4160-bf5c-bcfc70b103a4  40d38f6c3cfa4712bfcdca15a67c459a1672a027
~                                                     ubuntu-trusty/3421.4  bb48ec91-af8c-4d29-6edd-fcbff4d322fe  52445ef444b0da7a14bf7bb05612c3cbc1de5e29
zookeeper/ca455273c83e828eb50a21d21811684eceda2603    (source)              99911f20-f806-41c6-bd33-8d34d7cd94e3  d42e0023eb3d493e165ed0e36ae8643c8bfe535d
~                                                     ubuntu-trusty/3421.4  7c65efb0-9d99-4fe2-6283-157bfd231b18  b9c279eb3a99cc3bc27b6dfe1d6d372d2b86854e

8 packages

Succeeded
```

For debugging command also shows blobstore information (ID and SHA1) for each job and package. The Director uses blobstore references when deploying jobs and compiling packages.

---
## Fixing corrupted releases (experimental) {: #fix }

Assuming that somehow the Director blobstore loses referenced asset (job, source or compiled package), it's possible to fix the corrupted asset. [`bosh upload-release` commmand](cli-v2.md#upload-release) provides a `--fix` flag which allows to reupload same release contents into the Director.

---
## Cleaning up uploaded releases {: #clean-up }

Over time the Director accumulates releases, hence it uses more blobstore space. Releases could be deleted manually via [`bosh delete-release`](cli-v2.md#delete-release) command or be cleaned up via [`bosh cleanup` command](cli-v2.md#clean-up).
