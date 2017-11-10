---
title: Release Blobstore
---

<p class="note">Note: Examples require CLI v2.</p>

A release blobstore contains [release blob](release-blobs.html) and created final releases.

Access to release blobstore is configured via two files:

- `config/final.yml` (checked into Git repository): contains blobstore location
- `config/private.yml` (is NOT checked into Git repository): contains blobstore credentials

CLI supports three different blobstore providers: `s3`, `gcs` and `local`.

## <a id="s3-config"></a> S3 Configuration

S3 provider is used for most production releases. It's can be used with any S3-compatible blobstore (in compatibility mode) like Google Cloud Storage and Swift.

`config/final.yml`:

```yaml
---
blobstore:
  provider: s3
  options:
    bucket_name: <bucket_name>
```

`config/private.yml`:

```yaml
---
blobstore:
  options:
    access_key_id: <access_key_id>
    secret_access_key: <secret_access_key>
```

See [Configuring S3 release blobstore](s3-release-blobstore.html) for details and [S3 CLI Usage](https://github.com/pivotal-golang/s3cli#usage) for additional configuration options.

## <a id="gcs-config"></a> GCS Configuration

Google Cloud Storage can be used without S3 compatibility mode.

`config/final.yml`:

```yaml
---
blobstore:
  provider: gcs
  options:
    bucket_name: <bucket_name>
```

`config/private.yml`:

```yaml
---
blobstore:
  options:
    credentials_source: static
    json_key: |
      <json-key>
```

---
## <a id="local-config"></a> Local Configuration

Local provider is useful for testing.

`config/final.yml`:

```yaml
---
blobstore:
  provider: local
  options:
    blobstore_path: /tmp/test-blobs
```

Nothing in `config/private.yml`.

---
## <a id="migration"></a> Migrating blobs

CLI does not currently provide a builtin way to migrate blobs to a different blobstore. Suggested way to migrate blobs is to use third party tool like `s3cmd` to list and copy all blobs from current blobstore to another. Once copying of all blobs is complete, update `config` directory to with new blobstore location.
