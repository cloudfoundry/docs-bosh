!!! note
    Examples require CLI v2.

This topic is written for release maintainers and describes how to set up a S3 bucket for storing release artifacts.

## Creating S3 Bucket {: #bucket }

S3 bucket is used for storing release blobs and generated final release blobs. It's configured to be readable by everyone.

- Create S3 bucket with a descriptive name. For example choose `redis-blobs` for `redis-release` release.

- Under the bucket properties, click `Add bucket policies` and add the following entry to make blobs publicly downloadable. Be sure to change `<blobs_bucket_name>` to a name you want to call your blobstore bucket.

```json
{
  "Statement": [{
    "Action": [ "s3:GetObject" ],
    "Effect": "Allow",
    "Resource": "arn:aws:s3:::<blobs_bucket_name>/*",
    "Principal": { "AWS": ["*"] }
  }]
}
```

!!! note
    S3 buckets have a global namespace. If you create a bucket, that name has been forever consumed for everyone using S3. If you choose to delete that bucket, the name will not be added back to the global pool of names. It is gone forever.

## Creating IAM User for the Maintainer {: #iam-user }

An IAM user is used to download and upload blobs to a created S3 bucket.

- Create an AWS IAM user with a name that describes a specific purpose for this user -- uploading release blobs. For example: `redis-blobs-upload`.

- Make sure to save the credentials provided in the last step of user creation. These will need to be put in the `config/private.yml` file of your BOSH release. This file will look something like:

```yaml
---
blobstore:
  options:
    access_key_id: <access_key_id>
    secret_access_key: <secret_access_key>
```

- Remember to also create/update `config/final.yml`:

```yaml
---
blobstore:
  provider: s3
  options:
    bucket_name: <blobs_bucket_name>
```

!!! note
    The <code>.gitignore</code> file in the BOSH release should include <code>config/private.yml</code>. This file should <strong>not</strong> be committed to the release repo. It is only meant for the release maintainers. <code>config/final.yml</code>, on the other hand, should not be in the <code>.gitignore</code> file, and should be committed to the repository, as it is for users consuming and deploying the release.

- Attach a _user_ policy that would limit the user to permissions to read/write to the bucket that was just created:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [ "s3:PutObject" ],
    "Resource": [ "arn:aws:s3:::<blobs_bucket_name>/*" ]
  }]
}
```

!!! tip
    When you first create a bucket, it might take a little while for Amazon to be able to route requests correctly to the bucket and so downloads may fail with an obscure "Broken Pipe" error. The solution is to wait for some time before trying.

## Setting S3 region {: #setting-region }

By default, Amazon S3 buckets resolve to the `us-east-1` (North Virginia) region. If your blobstore bucket resides in a different region, override the region and host settings in `config/final.yml`. For example, a bucket in `eu-west-1` would be as follows:

```yaml
---
blobstore:
  provider: s3
  options:
    bucket_name: <blobs_bucket_name>
    region: eu-west-1
    host: s3-eu-west-1.amazonaws.com
```

A full list of S3 regions and endpoints is available [here](http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region).

See [S3 CLI Usage](https://github.com/pivotal-golang/s3cli#usage) for additional configuration options.

## Usage {: #usage }

Once the S3 bucket and IAM user are configured with correct access rules, `bosh upload blobs` should succeed and the S3 bucket should contain uploaded blobs. Running `bosh create release --final` will also place additional blobs into the bucket.
