---
title: Release Blobs
---

<p class="note">Note: Examples use CLI v2.</p>

A package may need to reference blobs (binary large objects) in addition to referencing other source files. For example when building a package for PostgreSQL server you may want to include `postgresql-9.6.1.tar.gz` from `https://www.postgresql.org/ftp/source/`. Typically it's not recommended to check in blobs directly into a Git repository because Git cannot efficiently track changes to such files. CLI provides a way to manage blobs in a reasonable manner with several commands:

```shell
$ bosh -h|grep blob
  add-blob               Add blob
  blobs                  List blobs
  remove-blob            Remove blob
  sync-blobs             Sync blobs
  upload-blobs           Upload blobs
```

## <a id="adding-blob"></a> Adding a blob

Package can reference blobs via `files` directive in a package spec just like as other source files.

```yaml
---
name: cockroachdb
files:
- cockroach-latest.linux-amd64.tgz
```

Creating a release with above configuration causes following error:

```shell
$ bosh create-release --force
Building a release from directory '/Users/user/workspace/cockroachdb-release':
  - Constructing packages from directory:
      - Reading package from '/Users/user/workspace/cockroachdb-release/packages/cockroachdb':
          Collecting package files:
            Missing files for pattern 'cockroach-latest.linux-amd64.tgz'
```

CLI expects to find `cockroach-latest.linux-amd64.tgz` in either `blobs` or `src` directory. Since it's a blob it should not be in `src` directory but rather added with the following command:

```shell
$ bosh add-blob ~/Downloads/cockroach-latest.linux-amd64.tgz cockroach-latest.linux-amd64.tgz
```

`add-blob` command:

- copies file into `blobs` directory (which should be in `.gitignore`)
- updates `config/blobs.yml` to start tracking blobs

---
## <a id="listing-blobs"></a> Listing blobs

To list currently tracked blobs use `bosh blobs` command:

```shell
$ bosh blobs
Path                              Size    Blobstore ID                          SHA1
cockroach-latest.linux-amd64.tgz  15 MiB  (local)                               469004231a9ed1d87de798f12fe2f49cc6ff1d2f
go1.7.4.linux-amd64.tar.gz        80 MiB  7e6431ba-f2c6-4e80-6a16-cd5cd8722b57  2e5baf03d1590e048c84d1d5b4b6f2540efaaea1

2 blobs

Succeeded
```

Blobs that have not been uploaded to release blobstore will be marked as `local` until they are uploaded.

---
## <a id="saving-blobs"></a> Uploading blobs

Blobs should be saved into release blobstore before cutting a new final release so that others can rebuild a release at a future time.

`bosh upload-blobs` command:

- uploads all local blobs to release blobstore
- updates `config/blobs.yml` with blobstore IDs

`config/blobs.yml` should be checked into a Git repository.

---
## <a id="removing-blobs"></a> Removing blobs

Once a blob is no longer needed by a package it can be stopped being tracked.

`bosh remove-blob` command:

- removes blob from `config/blobs.yml`
- does NOT remove blob from release blobstore so that new releases can be created from older revisions
