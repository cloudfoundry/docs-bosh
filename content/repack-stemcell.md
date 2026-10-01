# Repacking Stemcells

!!! note
    Applies to CLI v2.0.12+.

!!! warning
    Starting in version CLI v5.4.0, repacking a stemcell will preserve a new field `api_version` in the manifest. Repacking any stemcells with `api_version` in their manifest with CLI v5.3.1 and lower will omit the field.

The [CLI v2](cli-v2.md) includes a command to repack stemcells; this enables limited customization of a stemcell including the following:

- name
- version
- cloud properties

---

## Syntax {: #syntax }

```shell
bosh repack-stemcell src.tgz dst.tgz [--name=new_name] [--version=new_version] [--cloud-properties=json-string]
```

## Examples {: #examples }

In this example, we first download the stemcell we plan to modify, and then we create a new stemcell that's identical to the one we downloaded with the exception of a new name (`acme-corporation-stemcell`):

```shell
curl -OL https://storage.googleapis.com/bosh-gce-light-stemcells/1.585/light-bosh-stemcell-1.585-google-kvm-ubuntu-noble.tgz
bosh repack-stemcell --name=acme-corporation-stemcell light-bosh-stemcell-1.585-google-kvm-ubuntu-noble.tgz acme-corporation-stemcell.tgz
```

We decide to change the stemcell version number to `100` as well as the name (note: this does not change the stemcell version in the `/var/vcap/bosh/etc/stemcell_version` file in the root filesystem of the stemcell):

```shell
bosh repack-stemcell --name=acme-corporation-stemcell --version=100 light-bosh-stemcell-1.585-google-kvm-ubuntu-noble.tgz acme-corporation-stemcell.tgz
```

When we've uploaded the stemcell and we run `bosh stemcells`, we will see our stemcell listed with the new name and new version.

## CPI-Specific Options {: #cpi_specific }

### AWS CPI-Specific Options {: #aws_cpi_specific }

The `repack-stemcell` command can be used to enable the encryption of the root filesystem of VMs deployed with the repacked stemcell..

Two arguments enable the encryption of the root filesystem:

- **encrypted** [Boolean, optional]: Must be set to `true` if encryption of the root filesystem
- **kms\_key\_arn** [String, optional]: Created in the [Encryption Keys](https://console.aws.amazon.com/iam/home#encryptionKeys) section of the Identity and Access Management (IAM) console. If not specified _and_ `encrypted` is true, the root filesystem will be encrypted with the default key.

We modify the cloud-properties of an AWS stemcell to encrypt the root filesystem of instances deployed with our repacked stemcell. The cloud-properties must be specified as valid JSON. This only works with heavy stemcells:

We take this opportunity to rename our stemcell so that we don't accidentally confuse the unencrypted stemcells with the encrypted stemcells.

```shell
bosh repack-stemcell --name=acme-ubuntu-encrypted --cloud-properties='{"encrypted": true, "kms_key_arn": "arn:aws:kms:us-east-1:088444384256:key/4ffbe966-d138-4f4d-a077-4c234d05b3b1"}' bosh-stemcell-1.585-aws-xen-hvm-ubuntu-noble.tgz acme-encrypted-stemcell.tgz
```

!!! note
    Available in BOSH AWS CPI v63+.

The cloud properties will be merged with the existing cloud properties. It won't delete any properties, but it will overwrite the ones specified. For example, the above command will not delete the stemcell's cloud-property `infrastructure: aws`.

## Technical Details {: #technical_details }

The `repack-stemcell` works by modifying the stemcell manifest file (`stemcell.MF`) located within the stemcell tarball. It does not modify any other aspect of the stemcell. For example, it will not make any change to the root partition (it won't add new users or new packages). It does not modify the filesystem image.

The stemcell's manifest may be examined by extracting the `stemcell.MF` file from the stemcell tarball:

```shell
curl -sL https://storage.googleapis.com/bosh-gce-light-stemcells/1.585/light-bosh-stemcell-1.585-google-kvm-ubuntu-noble.tgz | tar -Oxzf - stemcell.MF
```

Should result in:

```yaml
api_version: 3
bosh_protocol: 1
cloud_properties:
  architecture: x86_64
  container_format: bare
  disk: 5120
  disk_format: rawdisk
  hypervisor: kvm
  image_url: https://www.googleapis.com/compute/v1/projects/cloud-foundry-310819/global/images/stemcell-1-585-google-kvm-ubuntu-noble-raw-1789266389
  infrastructure: google
  name: bosh-google-kvm-ubuntu-noble
  os_distro: ubuntu
  os_type: linux
  root_device_name: /dev/sda1
  version: "1.585"
name: bosh-google-kvm-ubuntu-noble
operating_system: ubuntu-noble
sha1: da39a3ee5e6b4b0d3255bfef95601890afd80709
stemcell_formats:
- google-light
version: "1.585"
```
