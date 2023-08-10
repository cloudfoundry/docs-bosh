The Director stores uploaded releases, configuration files, logs and other data
in a blobstore. A default DAV blobstore is sufficient for most BOSH
environments; however, a highly-available external blobstore may be desired.



## Included DAV (default) {: #included }

By default the Director is configured to use included DAV blobstore job (see [Installing BOSH section](index.md#install) for example manifests). Here is how to configure it:

1. Add blobstore release job and make sure that persistent disk is enabled:

    ```yaml
    jobs:
    - name: bosh
      templates:
      - {name: blobstore, release: bosh}
      # ...
      persistent_disk: 25_000
      # ...
      networks:
      - name: default
        static_ips: [10.0.0.6]
    ```

1. Configure blobstore job. The blobstore's address must be reachable by the Agents:

    ```yaml
    properties:
      blobstore:
        provider: dav
        address: 10.0.0.6
        port: 25250
        director:
          user: director
          password: DIRECTOR-PASSWORD
        agent:
          user: agent
          password: AGENT-PASSWORD
    ```

Above configuration is used by the Director and the Agents.

---
## S3 {: #default }

The Director and the Agents can use an S3 compatible blobstore. Here is how to configure it:

1. Create a *private* S3 bucket

1. Ensure that access to the bucket is protected, as the Director may store sensitive information.

1. Modify deployment manifest for the Director and specify S3 credentials and bucket name:

    ```yaml
    properties:
      blobstore:
        provider: s3
        access_key_id: ACCESS-KEY-ID
        secret_access_key: SECRET-ACCESS-KEY
        bucket_name: test-bosh-bucket
    ```

1. For an S3 compatible blobstore you need to additionally specify the host:

    ```yaml
    properties:
      blobstore:
        provider: s3
        access_key_id: ACCESS-KEY-ID
        secret_access_key: SECRET-ACCESS-KEY
        bucket_name: test-bosh-bucket
        host: objects.dreamhost.com
    ```

---
## Google Cloud Storage (GCS) {: #gcs }

!!! note
    Available in bosh release v263+ and Linux stemcells 3450+.

The Director and the Agents can use GCS as a blobstore. Here is how to configure it:

1. [Create a GCS bucket](https://cloud.google.com/storage/docs/creating-buckets).

1. Follow the steps on how to create service accounts and configure them with the [minimum set of permissions](google-required-permissions.md#director-with-gcs-blobstore).

1. Ensure that access to the bucket is protected, as the Director may store sensitive information.

1. Modify deployment manifest for the Director and specify GCS credentials and bucket name:

    ```yaml
    properties:
      blobstore:
        provider: gcs
        credentials_source: static
        json_key: |
          DIRECTOR-BLOBSTORE-SERVICE-ACCOUNT-FILE
        bucket_name: test-bosh-bucket
      agent:
        blobstore:
          json_key: |
            AGENT-SERVICE-ACCOUNT-BLOBSTORE-FILE
    ```

1. To use [Customer Supplied Encryption Keys](https://cloud.google.com/storage/docs/encryption#customer-supplied)
to encrypt blobstore contents instead of server-side encryption keys, specify `encryption_key`:

    ```yaml
    properties:
      blobstore:
        provider: gcs
        credentials_source: static
        json_key: |
          DIRECTOR-BLOBSTORE-SERVICE-ACCOUNT-FILE
        bucket_name: test-bosh-bucket
        encryption_key: BASE64-ENCODED-32-BYTES
      agent:
        blobstore:
          credentials_source: static
          json_key: |
            AGENT-SERVICE-ACCOUNT-BLOBSTORE-FILE
    ```

1. To use an explicit [Storage Class](https://cloud.google.com/storage/docs/storage-classes)
to store blobstore contents instead of the bucket default, specify `storage_class`:

    ```yaml
    properties:
      blobstore:
        provider: gcs
        credentials_source: static
        json_key: |
          DIRECTOR-BLOBSTORE-SERVICE-ACCOUNT-FILE
        bucket_name: test-bosh-bucket
        storage_class: REGIONAL
      agent:
        blobstore:
          credentials_source: static
          json_key: |
            AGENT-SERVICE-ACCOUNT-BLOBSTORE-FILE
    ```
---
## Azure Storage Account {: #azure-storage }

Azure Storage Account is supported from bosh version `278.0.0`.

The Director and the Agents can use an Azure Storage Account compatible blobstore. Here is how to configure it:

1. Create a *private* Azure Storage Account and a container

1. Ensure that access to the Account is protected, as the Director may store sensitive information.

1. Modify deployment manifest for the Director and specify Azure Storage Account credentials and container name:

    ```yaml
    properties:
      blobstore:
        provider: azure-storage
        account_key: ACCOUNT-KEY
        account_name: ACCOUNT-NAME
        container_name: CONTAINER
      agent:  
        env:
          bosh:
            blobstores:
            - options: 
                account_key: ACCOUNT-KEY
                account_name: ACCOUNT-NAME
                container_name: CONTAINER
              provider: azure-storage
        
    ```

