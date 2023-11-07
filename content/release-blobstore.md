!!! note
    Examples require CLI v2.

A release blobstore contains [release blob](release-blobs.md) and created final releases.

Access to release blobstore is configured via two files:

- `config/final.yml` (checked into Git repository): contains blobstore location
- `config/private.yml` (is NOT checked into Git repository): contains blobstore credentials

CLI supports three different blobstore providers: `s3`, `gcs` , `azure-storage` and `local`.

## S3 Configuration {: #s3-config }

S3 provider is used for most production releases. It's can be used with any S3-compatible blobstore (in compatibility mode) like Google Cloud Storage and Swift.

**config/final.yml**

```yaml
---
blobstore:
  provider: s3
  options:
    bucket_name: <bucket_name>
```

**config/private.yml**

```yaml
---
blobstore:
  options:
    access_key_id: <access_key_id>
    secret_access_key: <secret_access_key>
```

See [Configuring S3 release blobstore](s3-release-blobstore.md) for details and [S3 CLI Usage](https://github.com/pivotal-golang/s3cli#usage) for additional configuration options.

## GCS Configuration {: #gcs-config }

Google Cloud Storage can be used without S3 compatibility mode.

**config/final.yml**

```yaml
---
blobstore:
  provider: gcs
  options:
    bucket_name: <bucket_name>
```

**config/private.yml**

By default, your [Application Default Credentials](https://cloud.google.com/docs/authentication/production#providing_credentials_to_your_application) will be used. Alternatively, create a `config/private.yml` file to use a separate JSON key. When using a separate JSON key, ensure that the service account has the privilege "Storage Legacy Bucket Owner" for the GCS bucket:

```yaml
---
blobstore:
  options:
    credentials_source: static
    json_key: |
      <json-key>
```

---
## Local Configuration {: #local-config }

Local provider is useful for testing.

**config/final.yml**

```yaml
---
blobstore:
  provider: local
  options:
    blobstore_path: /tmp/test-blobs
```

Nothing in `config/private.yml`.

---

## Azure Storage Account Configuration {: #azure-storage-config }

Azure Storage Account is supported from bosh version `278.0.0`.

**config/final.yml**

```yaml
---
blobstore:
  provider: azure-storage
  options:
    container_name: <container_name>
    account_name: <account_name>
```

**config/private.yml**

```yaml
---
blobstore:
  options:
    account_key: <account_key>
```

---
## Migrating blobs {: #migration }

CLI does not currently provide a builtin way to migrate blobs to a different blobstore. Suggested way to migrate blobs is to use third party tool like `s3cmd` to list and copy all blobs from current blobstore to another. Once copying of all blobs is complete, update `config` directory to with new blobstore location.
