---
title: Blobs
---

To create final releases, configure your release repository with a blobstore. BOSH uploads final releases to the blobstore, so that the release can later be retrieved from another computer.

To prevent the release repository from becoming bloated with large binary files (e.g. source tarballs), large files can be placed in the `blobs` directory, and then uploaded to the blobstore.

A `config/private.yml` stores write-access credentials permitting you to upload source files for public consumption, while the `config/final.yml` helps BOSH users in the wild download these files. These users may be public consumers of your release, or your internal colleagues.

For production releases, use either the Atmos or S3 blobstore and configure them as described below.

## <a id='atmos'></a> Atmos ##

Atmos is a shared storage solution from EMC. To use Atmos, edit `config/final.yml` and `config/private.yml`, and add the following. Replace the `url`, `uid` and `secret` values with your account information.

File `config/final.yml`

    ---
    blobstore:
      provider: atmos
      options:
        tag: BOSH
        url: https://blob.cfblob.com
        uid: 1876876dba98981cxd081981731deab2/user1

File `config/private.yml`

    ---
    blobstore_secret: acye7dAS93yjWOIpqla9as8GBu1=

## <a id='s3'></a>S3 ##

To use S3 — a shared storage solution from Amazon — edit `config/final.yml` and `config/private.yml` to include your credentials and bucket name.

File `config/final.yml`

    ---
    blobstore:
      provider: s3
      options:
        bucket_name: my-release-blobs

File `config/private.yml`

    ---
    blobstore:
      s3:
        access_key_id: 9ZIAITIR2WCAA5G4OPMQ
        bucket_name: my-release-blobs
        secret_access_key: acye7dAS93kj/WOIpqla9as8GBu1WOIpqla=


## <a id="local"></a>Local Blobstore Provider ##

If you are trying out BOSH and don't have an Atmos or S3 account, you can use the local blobstore provider. The local provider stores the files on disk instead of on a remote server.

File `config/final.yml`

    ---
    blobstore:
      provider: local
      options:
        blobstore_path: /path/to/blobstore/directory

**Note**: We recommend that you use the local blobstore for testing purposes only.
