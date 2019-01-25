# Blobstore

A blobstore is used to serve and store data objects (blobs) across components.

The 


## Implemented By

### Amazon S3

 * Transport -- HTTPS
 * Authentication -- Access Key ID, Secret Access Key; IAM Role
 * Authorization -- Bucket Policy; IAM Policy

### S3-compatible Service

 * Transport -- HTTPS; HTTP
 * Authentication -- Access Key, Secret Key
 * Authorization -- *service-dependent*

### Google Cloud Storage

 * Transport -- HTTPS
 * Authentication -- Service Account File; Application Default Credentials
 * Authorization -- Bucket Policy; IAM Policy

### WebDAV

 * Transport -- HTTPS; HTTP
 * Authentication -- Username, Password
 * Authorization -- *service-dependent*

## Security
