# Managing Stemcells

(See [What is a Stemcell?](stemcell.md) and [Uploading stemcells](uploading-stemcells.md) for an introduction.)

The Director keeps its own list of uploaded stemcells. Use the commands below to see what is uploaded, add new versions, and remove old ones.

---

## Listing stemcells {: #list }

[`bosh stemcells`](cli-v2.md#stemcells) lists all stemcells on the Director:

```shell
bosh stemcells
```

```text
Using environment '10.245.0.10' as client 'admin'

Name                                          Version  OS               CPI  CID
bosh-warden-boshlite-ubuntu-noble             1.585    ubuntu-noble     -    bosh.io/stemcells:img-5539c166-9b33-43f8-7b20-9d7feb990996
bosh-warden-boshlite-ubuntu-resolute-rosetta  0.149*   ubuntu-resolute  -    bosh.io/stemcells:img-6534556a-b52e-4bf0-6fc4-f6acb9f5d77f

(*) Currently deployed

2 stemcells

Succeeded
```

- A `*` after the version marks a stemcell that at least one deployment is using.
- `CID` is the stemcell's identifier in the IaaS (an AMI, a vSphere template, a Docker image, etc.).
- `CPI` names the CPI that holds the stemcell when the Director uses a [CPI config](cpi-config.md).

---

## Uploading stemcells {: #upload }

[`bosh upload-stemcell`](cli-v2.md#upload-stemcell) uploads a stemcell from a URL or a local file. When uploading from a URL, pass the SHA1 from [bosh.io/stemcells](/stemcells/) so the Director can verify the download:

```shell
bosh upload-stemcell \
  --sha1 b65b7e3a322848714c35a7709cb62436a3ee5dd9 \
  "https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-noble?v=1.585"
```

```text
Using environment '10.245.0.10' as client 'admin'

Task 429

Task 429 | 19:01:31 | Update stemcell: Downloading remote stemcell (00:00:35)
Task 429 | 19:02:06 | Update stemcell: Verifying remote stemcell (00:00:01)
Task 429 | 19:02:07 | Update stemcell: Extracting stemcell archive (00:00:02)
Task 429 | 19:02:09 | Update stemcell: Verifying stemcell manifest (00:00:00)
Task 429 | 19:02:10 | Update stemcell: Checking if this stemcell already exists (00:00:00)
Task 429 | 19:02:10 | Update stemcell: Uploading stemcell bosh-warden-boshlite-ubuntu-noble/1.585 to the cloud (00:00:42)
Task 429 | 19:02:52 | Update stemcell: Save stemcell bosh-warden-boshlite-ubuntu-noble/1.585 (bosh.io/stemcells:img-5539c166-9b33-43f8-7b20-9d7feb990996) (00:00:00)

Task 429 Started  Thu Oct  1 19:01:31 UTC 2026
Task 429 Finished Thu Oct  1 19:02:52 UTC 2026
Task 429 Duration 00:01:21
Task 429 done

Succeeded
```

With a URL, the Director downloads the stemcell itself, so the tarball never passes through your machine. Uploading a stemcell that already exists succeeds without doing anything. When uploading from a URL, pass `--name` and `--version` as well so the CLI can skip the upload entirely.

See [Uploading Stemcells](uploading-stemcells.md) for how deployments reference uploaded stemcells.

---

## Fixing corrupted stemcells {: #fix }

Occasionally stemcells are deleted from the IaaS outside of the Director. For example your vSphere administrator decided to clean up your vSphere VMs folder. The Director of course will continue to reference deleted IaaS asset and CPI will eventually raise an error when trying to create new VM. [`bosh upload-stemcell` command](cli-v2.md#upload-stemcell) provides a `--fix` flag which allows to reupload stemcell with the same name and version into the Director fixing this problem.

---

## Deleting stemcells {: #delete }

Over time the Director accumulates stemcells. [`bosh delete-stemcell`](cli-v2.md#delete-stemcell) removes one by `NAME/VERSION`, deleting it from both the Director and the IaaS:

```shell
bosh delete-stemcell bosh-warden-boshlite-ubuntu-noble/1.585
```

```text
Using environment '10.245.0.10' as client 'admin'

Task 430. Done

Succeeded
```

To remove old stemcells that no deployment is using, run [`bosh clean-up`](cli-v2.md#clean-up) instead. Add `--dry-run` to see what it would delete.

---

## Customizing stemcells {: #repack }

To change a stemcell's name, version, or cloud properties without rebuilding it, use [`bosh repack-stemcell`](repack-stemcell.md).

---

## Automating stemcell updates {: #automation }

New stemcell versions are published regularly with security fixes (see [Stemcell Lines & Support](stemcell-lines.md)). To pick them up automatically in [Concourse](https://concourse-ci.org/), use the [bosh-io-stemcell-resource](https://github.com/concourse/bosh-io-stemcell-resource). It tracks a stemcell's versions on bosh.io and downloads new ones as they're published:

```yaml
resources:
- name: noble-stemcell
  type: bosh-io-stemcell
  source:
    name: bosh-aws-xen-hvm-ubuntu-noble
```

By default the resource fetches light stemcells for IaaS providers that have them. Set `force_regular: true` to always fetch full stemcells, or `version_family` to stay on one major version. See the resource's README for all options.

---

## Identifying a stemcell from inside a VM {: #overview }

You can identify stemcell version from inside the VM via following files:

- `/var/vcap/bosh/etc/stemcell_version`: Example: `0.149`
- `/var/vcap/bosh/etc/stemcell_git_sha1`: Example: `5b8d54c26ae8faf24d6492d22b4600692e94e226`

!!! note
    Release authors should not use the contents of these files in their releases.

See [Stemcell Building](build-stemcell.md#tarball-structure) to find stemcell archive structure, and [Stemcell Lines & Support](stemcell-lines.md#versions) for how stemcell versions are numbered.
