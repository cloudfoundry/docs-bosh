---
title: Repacking Stemcells
---

<p class="note">Note: Applies to CLI v2 v2.0.12+.</p>

The [CLI v2](cli-v2.html) includes a command to repack stemcells; this enables limited customization of a stemcell including the following:

- name
- version
- cloud properties

---
## <a id="syntax"></a> Syntax

<pre class="terminal extra-wide">
$ bosh repack-stemcell src.tgz dst.tgz [--name=new_name] [--version=new_version] [--cloud-properties=json-string]
</pre>

## <a id="examples"></a> Examples

In this example, we first download the stemcell we plan to modify, and then we create a new stemcell that's identical to the one we downloaded with the exception of a new name (`acme-corporation-stemcell`):

<pre class="terminal extra-wide">
$ curl -OL https://s3.amazonaws.com/bosh-gce-light-stemcells/light-bosh-stemcell-3363.9-google-kvm-ubuntu-trusty-go_agent.tgz
$ bosh repack-stemcell --name=acme-corporation-stemcell light-bosh-stemcell-3363.9-google-kvm-ubuntu-trusty-go_agent.tgz acme-corporation-stemcell.tgz
</pre>

We decide to change the stemcell version number to `100` as well as the name (note: this does not change the stemcell version in the `/var/vcap/bosh/etc/stemcell_version` file in the root filesystem of the stemcell):

<pre class="terminal extra-wide">
$ bosh repack-stemcell --name=acme-corporation-stemcell --version=100 light-bosh-stemcell-3363.9-google-kvm-ubuntu-trusty-go_agent.tgz acme-corporation-stemcell.tgz
</pre>

When we've uploaded the stemcell and we run `bosh stemcells`, we will see our stemcell listed with the new name and new version.

## <a id="cpi_specific"></a> CPI-Specific Options

### <a id="aws_cpi_specific"></a> AWS CPI-Specific Options

The `repack-stemcell` command can be used to enable the encryption of the root filesystem of VMs deployed with the repacked stemcell..

Two arguments enable the encryption of the root filesystem:

* **encrypted** [Boolean, optional]: Must be set to `true` if encryption of the root filesystem
* **kms\_key\_arn** [String, optional]: Created in the [Encryption Keys](https://console.aws.amazon.com/iam/home#encryptionKeys) section of the Identity and Access Management (IAM) console. If not specified _and_ `encrypted` is true, the root filesystem will be encrypted with the default key.

We modify the cloud-properties of an AWS stemcell to encrypt the root filesystem of instances deployed with our repacked stemcell. The cloud-properties must be specified as valid JSON. This only works with heavy stemcells:

We take this opportunity to rename our stemcell so that we don't accidently confuse the unencrypted stemcells with the encrypted stemcells.

<pre class="terminal extra-wide">
$ bosh repack-stemcell --name=acme-ubuntu-encrypted --cloud-properties='{"encrypted": true, "kms_key_arn": "arn:aws:kms:us-east-1:088444384256:key/4ffbe966-d138-4f4d-a077-4c234d05b3b1"}' bosh-stemcell-3363.9-aws-xen-hvm-ubuntu-trusty-go_agent.tgz acme-encrypted-stemcell.tgz
</pre>

<p class="note">Note: Available in BOSH AWS CPI v63+.</p>

The cloud properties will be merged with the existing cloud properties. It won't delete any properties, but it will overwrite the ones specified. For example, the above command will not delete the stemcell's cloud-property `infrastructure: aws`.

## <a id="technical_details"></a> Technical Details

The `repack-stemcell` works by modifying the stemcell manifest file (`stemcell.MF`) located within the stemcell tarball. It does not modify any other aspect of the stemcell. For example, it will not make any change to the root partition (it won't add new users or new packages). It does not modify the filesystem image.

The stemcell's manifest may be examined by extracting the `stemcell.MF` file from the stemcell tarball:

<pre class="terminal extra-wide">
$ curl -L https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent | tar -Oxvf - -- stemcell.MF
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   137  100   137    0     0    268      0 --:--:-- --:--:-- --:--:--   268
100 19230  100 19230    0     0  18442      0  0:00:01  0:00:01 --:--:-- 18442
x stemcell.MF---
name: bosh-google-kvm-ubuntu-trusty-go_agent
version: '3363.9'
bosh_protocol: 1
sha1: da39a3ee5e6b4b0d3255bfef95601890afd80709
operating_system: ubuntu-trusty
cloud_properties:
  name: bosh-google-kvm-ubuntu-trusty-go_agent
  version: '3363.9'
  infrastructure: google
  hypervisor: kvm
  disk: 3072
  disk_format: rawdisk
  container_format: bare
  os_type: linux
  os_distro: ubuntu
  architecture: x86_64
  root_device_name: "/dev/sda1"
  source_url: https://storage.googleapis.com/bosh-gce-raw-stemcells/bosh-stemcell-3363.9-google-kvm-ubuntu-trusty-go_agent-raw.tar.gz
  raw_disk_sha1: fd8ef3f59b01e5e923c0ff1f70fcfcfdbbd49aeb
</pre>
