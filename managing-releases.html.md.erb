---
title: Managing releases
---

(See [What is a Release?](release.html) and [Uploading releases](uploading-releases.html) for an introduction.)

---
## <a id="jobs-and-packages"></a> Jobs and Packages

Each job and package is uniquely identified by its name and fingerprint. A fingerprint is calculated based on the contents of all associated files, their permissions. A release captures set of job and package versions that depend on each other and gives it a name and a version. The CLI also records additional metadata when creating releases such as Git SHA.

For example here is a release description (e.g. `releases/zookeeper/zookeeper-0.0.1.yml`) in an example Zookeeper release:

```yaml
---
name: zookeeper
version: 0.0.1
commit_hash: 13eb79b
uncommitted_changes: false

jobs:
- name: zookeeper
  fingerprint: 57efe078d0d82624907dc481846ebb54d75bd7a9
  sha1: 9f3e46c3bab87c720a34ae1dc6890cd26e5021b6

packages:
- name: java
  fingerprint: c524e46e61b37894935ae28016973e0e8644fcde
  sha1: a1f0001e124f33ad6c9258e6113a3e730c7e82b9
  dependencies: []
- name: zookeeper
  fingerprint: ca455273c83e828eb50a21d21811684eceda2603
  sha1: d42e0023eb3d493e165ed0e36ae8643c8bfe535d
  dependencies: []

license:
  fingerprint: a3e6d245553160dad1d273d363550134abc94578
  sha1: 341989cdb5144f800873517429874ef1224116af
```

Job and package names and fingerprints are used throughout the system to identify if certain actions need to be taken. Two primary uses are:

- to determine if packages need to be uploaded to the Director when uploading a release
- to determine if instances need to be updated during a [deployment procedure](deploying-step-by-step.html)

---
## <a id="uniqueness"></a> Version uniqueness

There exists an implicit trust between a release author and an operator that different release (a different set of jobs and packages) will not be published under the same version. The Director will reject new set of jobs and packages during the upload if it does not match with already uploaded contents.

Sometimes however two different releases (e.g. 1.0.1 and 1.0.3) may end up with exactly same set of jobs and packages. In fact running `bosh create release` command a few times in a row will produce new releases with only version being different (e.g. 1.0.1+dev.0 and 1.0.1+dev.1). Operators should be aware that even if the deployment procedure shows release version changing there is a chance that no instances will be updated. This initially may be a surprising behaviour; however, given that the Director correctly determines that there are no changes to apply to the instances, there is really nothing to do. After the deploy is finished, `bosh deployments` command will of course state that new release is used.

---
## <a id="inspect"></a> Inspecting uploaded releases

Once release is uploaded to the Director, it can be inspected via `bosh inspect release` command. It will show names and fingerprints of jobs and packages. It will also show job details such as consumed and provided links.

<pre class="terminal extra-wide">
$ bosh inspect release zookeeper/0.0.1
Acting as user 'admin' on 'bosh'

+-----------+------------------------------------------+--------------------------------------+------------------------------------------+-------------------------+--------------------------+
| Job       | Fingerprint                              | Blobstore ID                         | SHA1                                     | Links Consumed          | Links Provided           |
+-----------+------------------------------------------+--------------------------------------+------------------------------------------+-------------------------+--------------------------+
| zookeeper | 57efe078d0d82624907dc481846ebb54d75bd7a9 | af52e0aa-7df1-4859-85a3-420f13ec0644 | 9f3e46c3bab87c720a34ae1dc6890cd26e5021b6 | - name: peers           | - name: conn             |
|           |                                          |                                      |                                          |   type: zookeeper_peers |   type: zookeeper        |
|           |                                          |                                      |                                          |                         |   properties:            |
|           |                                          |                                      |                                          |                         |   - client_port          |
|           |                                          |                                      |                                          |                         | - name: peers            |
|           |                                          |                                      |                                          |                         |   type: zookeeper_peers  |
|           |                                          |                                      |                                          |                         |   properties:            |
|           |                                          |                                      |                                          |                         |   - client_port          |
|           |                                          |                                      |                                          |                         |   - quorum_port          |
|           |                                          |                                      |                                          |                         |   - leader_election_port |
+-----------+------------------------------------------+--------------------------------------+------------------------------------------+-------------------------+--------------------------+

+-----------+------------------------------------------+--------------+--------------------------------------+------------------------------------------+
| Package   | Fingerprint                              | Compiled For | Blobstore ID                         | SHA1                                     |
+-----------+------------------------------------------+--------------+--------------------------------------+------------------------------------------+
| java      | c524e46e61b37894935ae28016973e0e8644fcde | (source)     | 9187d923-a19d-4547-952c-3b7529852329 | a1f0001e124f33ad6c9258e6113a3e730c7e82b9 |
| zookeeper | ca455273c83e828eb50a21d21811684eceda2603 | (source)     | b8a0f19e-5a3e-4ba6-b36a-364b07e8245d | d42e0023eb3d493e165ed0e36ae8643c8bfe535d |
+-----------+------------------------------------------+--------------+--------------------------------------+------------------------------------------+
</pre>

For debugging command also shows blobstore information (ID and SHA1) for each job and package. The Director uses blobstore references when deploying jobs and compiling packages.

---
## <a id="fix"></a> Fixing corrupted releases (experimental)

Assuming that somehow the Director blobstore loses referenced asset (job, source or compiled package), it's possible to fix the corrupted asset. `bosh upload release` commmand provides a `--fix` flag which allows to reupload same release contents into the Director.

---
## <a id="clean-up"></a> Cleaning up uploaded releases

Over time the Director accumulates releases, hence it uses more blobstore space. Releases could be deleted manually via `bosh delete release` command or be cleaned up via `bosh cleanup` command.
