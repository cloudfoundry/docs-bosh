# Release Blobstore

!!! note
    This describes configuring a blobstore for publishing BOSH Releases with
    **BOSH CLI v2+**, which is separate from [configuring the blobstore of a
    BOSH Director](director-configure-blobstore).

A release blobstore contains [release blob](release-blobs.md) and created final releases.

Access to release blobstore is configured via two files:

- `config/final.yml` (checked into Git repository): contains blobstore location
- `config/private.yml` (is NOT checked into Git repository): contains blobstore credentials

CLI supports three different blobstore providers: `s3`, `gcs`, and `local`.

!!! warning "Managing split-configuration between `private.yml` and `final.yml`"
    In CLI v2, the value of `/blobstore/<provider>/` in `private.yml` [is
    shallow-merged with, and takes precedence over,](https://github.com/cloudfoundry/bosh-cli/blob/27b76482223696f45c8269d233a3cdd42cdb77a3/releasedir/fs_config.go#L114-L120) the value of `/blobstore/options/`
    in `final.yml`. The CLI does not distinguish which file a blobstore
    option should be placed in. Hence, it is possible to create and publish a
    valid `final.yml` with secrets.


## S3 Configuration {: #s3-config }

S3 provider is used for most production releases. It's can be used with any S3-compatible blobstore (in compatibility mode) like Google Cloud Storage and Swift.

### config/final.yml

```yaml
---
blobstore:
  provider: s3
  options:
    bucket_name: <bucket_name>
```

### config/private.yml

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

### config/final.yml

```yaml
---
blobstore:
  provider: gcs
  options:
    bucket_name: <bucket_name>
```

### config/private.yml

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

### config/final.yml

```yaml
---
blobstore:
  provider: local
  options:
    blobstore_path: /tmp/test-blobs
```

Nothing in `config/private.yml`.

---
## Release Compression Configuration {: #no-compression }

!!! note "Version Requirements"
    The `no_compression` flag requires BOSH Director version `282.1.5` or newer and the following stemcell versions:
    - Ubuntu Noble (24.04): v1.165 or newer
    - Ubuntu Jammy (22.04): v1.990 or newer

You can control whether the outer release tarball is compressed by setting the `no_compression` flag in `config/final.yml`.

### config/final.yml

```yaml
---
name: my-release
blobstore:
  provider: s3
  options:
    bucket_name: <bucket_name>
no_compression: true
```

- **no_compression** [Boolean, optional]: When set to `true`, disables compression for the outer release tarball. Defaults to `false` (compression enabled) if not specified.

!!! note
    The `bosh export-release` command does not currently respect the `no_compression` flag due to technical limitations. When using `bosh export-release`, the outer tarball will always be compressed regardless of the `no_compression` setting in `final.yml`.

---

## Migrating blobs {: #migration }

CLI does not currently provide a builtin way to migrate blobs to a different blobstore. Suggested way to migrate blobs is to use third party tool like `s3cmd` to list and copy all blobs from current blobstore to another. Once copying of all blobs is complete, update `config` directory to with new blobstore location.
