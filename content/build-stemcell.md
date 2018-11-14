(See [What is a Stemcell?](stemcell.md) for an introduction to stemcells.)

To build a stemcell tarball for a supported IaaS-OS combination follow instructions in the [bosh-linux-stemcell-builder's README](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/blob/master/README.md).

Stemcell tarballs are currently specific to an IaaS-OS/CPI because they may:

- include custom Agent configuration (e.g. [OpenStack's Agent configuration](https://github.com/cloudfoundry/bosh/blob/ede389a2e112e1b4f2dbc4495c08977da4439483/stemcell_builder/stages/bosh_openstack_agent_settings/apply.sh#L12-L41))
- include custom OS packages/configuration (e.g. [OpenStack's OS customizations](https://github.com/cloudfoundry/bosh/blob/cdd7c7b333d076aa96c648825b1e9ba4ba7a22ba/bosh-stemcell/lib/bosh/stemcell/stage_collection.rb#L93-L94))
- be packaged into a custom image format (qcow, vmdk, etc.)

In the future, BOSH team will investigate how to best consolidate stemcells into a single OS image. In the meantime, if you're developing a CPI for a new IaaS, you may consider reusing one of the officially generated stemcells, or making changes to the following projects:

- [bosh-linux-stemcell-builder](https://github.com/cloudfoundry/bosh-linux-stemcell-builder)
- [bosh-agent](https://github.com/cloudfoundry/bosh-agent)

---
## Tarball Structure {: #tarball-structure }

!!! info
    This is an implementation detail. The tarball structure is subject to change without notice.

```shell
$ tar tvf light-bosh-stemcell-3033-aws-xen-hvm-ubuntu-trusty-go_agent.tgz

-rw-rw-r--  0 ubuntu ubuntu      0 Aug  4 09:45 image
-rw-rw-r--  0 ubuntu ubuntu    710 Aug  4 10:06 stemcell.MF
-rw-r--r--  0 ubuntu ubuntu  50594 Aug  4 09:23 packages.txt
-rw-r--r--  0 ubuntu ubuntu  12543 Aug  4 09:22 dev_tools_file_list.txt
```

* `image`: OS image in a format (raw, qcow, ova, etc.) understood by the CPI/IaaS.
* `stemcell.MF`: YAML file with stemcell metadata.
* `packages.txt`: Text file that includes list of packages installed. (Used to be included as `stemcell_dpkg_l.txt`)
* `dev_tools_file_list.txt`: Text file that includes list of files removed by the agent if Agent's `remove_dev_tools` feature is enabled.

### Metadata {: #metadata }

!!! info
    This is an implementation detail. The content of `stemcell.MF` is subject to change without notice.

* **name** [String, required]: A unique name used to identify stemcell series.
* **operating_system** [String, required]: Operating system in the stemcell. Example: `ubuntu-trusty`.
* **version** [String, required]: Version of the stemcell. Example: `3033`.
* **sha1** [String, required]: The SHA1 of the image file included in the stemcell tarball.
* **bosh_protocol** [String, optional]: Deprecated.
* **cloud_properties** [Hash, required]: Describes any IaaS-specific properties needed to import OS image. These properties will be passed in to the [`create_stemcell` CPI call](cpi-api-v1.md#create-stemcell).
* **stemcell_formats** [Array of Strings, optional]: The list of stemcell formats that a [CPI must support](cpi-api-v2-method/info.md#result). The director will attempt to upload the stemcell to all CPIs that support any specified formats.

Name, operating system and version values will be visible via `bosh stemcells` command once a stemcell is imported into the Director.

Example:

```shell
$ tar -Oxzf light-bosh-stemcell-97.19-aws-xen-hvm-ubuntu-xenial-go_agent.tgz stemcell.MF
```

```yaml
---
name: bosh-aws-xen-hvm-ubuntu-xenial-go_agent
version: '97.19'
bosh_protocol: '1'
sha1: da39a3ee5e6b4b0d3255bfef95601890afd80709
operating_system: ubuntu-xenial
stemcell_formats:
- aws-light
cloud_properties:
  ami:
    us-gov-west-1: ami-1431a975
    ap-northeast-1: ami-0ddb32f9e2cb016f3
    ap-northeast-2: ami-04f416b078c7eb965
    ap-south-1: ami-0f04da873c8883a56
    ap-southeast-1: ami-0628f639a2c1abd77
    ap-southeast-2: ami-06f24628e83df3ca7
    ca-central-1: ami-0b8196ea9d0c10b00
    eu-central-1: ami-07ebdd782c27da598
    eu-west-1: ami-0f7e184ff7b50cd36
    eu-west-2: ami-01713a432b5494aa6
    eu-west-3: ami-059850a6db5f0f1f0
    sa-east-1: ami-0559933d31a7cbdf3
    us-east-1: ami-0cdc0ee47ff314116
    us-east-2: ami-05e20eb5a19355a32
    us-west-1: ami-0eb351fd3b5bb07e0
    us-west-2: ami-0147f5edb0c3600ab
    cn-northwest-1: ami-0855153be65a20e35
    cn-north-1: ami-01db1b9ef2de116fb
```

---
## Light Stemcells {: #light-stemcells }

Some IaaSes (or how they are configured) limit how OS images can be imported. Here are couple of examples:

- AWS only allows creation of AMIs from running VMs on AWS
- OpenStack can be configured to disallow Glance image upload
- an IaaS may take long time to import an image making it beneficial to reuse existing images

In such cases CPI must use already imported OS image and that's where light stemcells come in. Light stemcell tarballs include additional details about already imported OS images in the `cloud_properties` section. For example light stemcells for AWS have `ami` key in the `cloud_properties` section (as shown above), that contains region-to-AMI-ID mappings. When AWS CPI's [`create_stemcell` call](cpi-api-v1.md#create-stemcell) is made, it will return matching AMI ID without doing any IaaS API calls.

---
## Testing {: #testing }

There are two test suites each stemcell is expected to pass before it's considered to be production-ready:

- shared [Stemcell Tests](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/tree/master/bosh-stemcell/spec) which verify that proper packages and configurations are installed
- shared [BOSH Acceptance Tests (BATS)](https://github.com/cloudfoundry/bosh/blob/master/docs/running_tests.md#bosh-acceptance-tests-bats) (provided by the BOSH team) which verify high level Director behavior with the stemcell being used
