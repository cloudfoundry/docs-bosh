!!! note
    This feature is available with bosh-release v208+ (1.3087.0) colocated with bosh-aws-cpi v31+.

This topic describes how to configure BOSH to use [AWS IAM instance profiles](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html) to avoid hard coding specific AWS credentials.

You may have to create one or more IAM instance profiles to limit access to AWS resources depending on how BOSH is configured and what software you are planning to deploy. Below are a few example configurations.

!!! note
    Each IAM role when created has an associated IAM instance profile with the same name. There is no need to create instance profiles explicitly.

## Example A: AWS CPI and Director configured with default blobstore {: #only-director }

1. Create `director` IAM role using the same policy as your existing user (see [Creating IAM Users](aws-iam-users.md)).

1. Change deployment manifest for the Director to configure AWS CPI to use `director` IAM profile:

    ```yaml
    resource_pools:
    - name: default
      network: default
      stemcell: { ... }
      cloud_properties:
        instance_type: m3.xlarge
        iam_instance_profile: director
    ```

1. Instead of providing `access_key_id` and `secret_access_key`, configure AWS CPI in the deployment manifest to use IAM instance profile as a credentials source:

    ```yaml
    properties:
      aws: &aws
        credentials_source: env_or_profile
        # access_key_id and secret_access_key are not provided
        # ...
    ```

    !!! note
        To use IAM instance profile as a credentials source when using `bosh create-env` command, you have to run the command from a [jumpbox](terminology.md#jumpbox), an existing AWS instance with IAM instance profile (you can reuse `director` IAM role). Alternatively if you are deploying the Director VM from outside of the AWS, you can use hard coded credentials with `bosh create-env` command and have the AWS CPI on the Director VM use IAM instance profile as a credentials source.

    !!! note
        Even though value specified is `env_or_profile`, `bosh create-env` command or the Director do not currently take advantage of the environment variables, only instance the profile, hence to take advantage of this feature you have to run on an AWS instance.

---
## Example B: AWS CPI and Director configured with an S3 blobstore {: #director-with-s3-blobstore }

This configuration is similar to the previous one except that it's used when the Director and the Agents use S3 as their [blobstore](bosh-components.md#blobstore) instead of an internal blobstore provided by the bosh release.

1. Create `deployed-vm` IAM role which allows `s3:*` actions for a chosen S3 bucket. This IAM role will be used by default for all VMs created by the Director.

    ```json
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Action": [ "s3:*" ],
        "Resource": [
          "arn:aws:s3:::<bosh_bucket_name>",
          "arn:aws:s3:::<bosh_bucket_name>/*"
        ]
      }]
    }
    ```

1. Create `director` IAM role using the same policy as your existing user (see [Creating IAM Users](aws-iam-users.md)) with the following additional policy.

    ```json
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Effect":"Allow",
        "Action":"iam:PassRole",
        "Resource":"arn:aws:iam::<account_id>:role/deployed-vm"
      },{
        "Effect": "Allow",
        "Action": [ "s3:*" ],
        "Resource": [
          "arn:aws:s3:::<bosh_bucket_name>",
          "arn:aws:s3:::<bosh_bucket_name>/*"
        ]
      }]
    }
    ```

1. In addition to configuring AWS CPI in the deployment manifest to use IAM instance profile as a credentials source, also set default IAM instance profile for all future deployed VMs:

    ```yaml
    properties:
      aws: &aws
        credentials_source: env_or_profile
        default_iam_instance_profile: deployed-vm
        # ...
    ```

    !!! note
        `iam_instance_profile` key in resource pool's cloud_properties takes precedence over the default IAM instance profile, so that specific VMs can have greater access to the AWS resources.

---
## Errors {: #errors }

```
You are not authorized to perform this operation. Encoded authorization failure message: vHU-KncL6Yo4pG5J9p...
```

Use `aws sts decode-authorization-message` command to decode message included in the error. For example:

```shell
aws sts decode-authorization-message --encoded-message vHU-KncL6Yo4pG5J9p... | jq.DecodedMessage
```

Should result in:

```json
{
  "allowed": false,
  "explicitDeny": false,
  "matchedStatements": {
    "items": []
  },
  "failures": {
    "items": []
  },
  "context": {
    "principal": {
      "id": "AROxxx:i-56a18483",
      "arn": "arn:aws:sts::xxx:assumed-role/director/i-56a18483"
    },
    "action": "iam:PassRole",
    "resource": "arn:aws:iam::xxx:role/deployed-vm",
    "conditions": {
      "items": []
    }
  }
}
```

Decoded message above indicates that `iam:PassRole` action needs to be added to the `director` IAM role so that the AWS CPI can create VMs with `deployed-vm` IAM role.
