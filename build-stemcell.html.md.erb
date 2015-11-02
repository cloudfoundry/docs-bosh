---
title: Stemcell Building
---

(See [What is a Stemcell?](stemcell.html) for an introduction to stemcells.)

To build a stemcell tarball for a supported IaaS-OS combination follow instructions in the [bosh-stemcell's README](https://github.com/cloudfoundry/bosh/tree/master/bosh-stemcell).

Stemcell tarballs are currently specific to an IaaS-OS/CPI because they may:

- include custom Agent configuration (e.g. [OpenStack's Agent configuration](https://github.com/cloudfoundry/bosh/blob/ede389a2e112e1b4f2dbc4495c08977da4439483/stemcell_builder/stages/bosh_openstack_agent_settings/apply.sh#L12-L41))
- include custom OS packages/configuration (e.g. [OpenStack's OS customizations](https://github.com/cloudfoundry/bosh/blob/cdd7c7b333d076aa96c648825b1e9ba4ba7a22ba/bosh-stemcell/lib/bosh/stemcell/stage_collection.rb#L93-L94))
- be packaged into a custom image format (qcow, vmdk, etc.)

In the future, BOSH team will investigate how to best consolidate stemcells into a single OS image. In the meantime, if you're developing a CPI for a new IaaS, you may consider reusing one of the officially generated stemcells, or making changes to the following projects:

- [bosh-stemcell](https://github.com/cloudfoundry/bosh/tree/master/bosh-stemcell)
- [stemcell_builder](https://github.com/cloudfoundry/bosh/tree/master/stemcell_builder)
- [bosh-agent](https://github.com/cloudfoundry/bosh-agent)

---
## <a id="tarball-structure"></a> Tarball Structure

<pre class="terminal">
$ tar tvf light-bosh-stemcell-3033-aws-xen-hvm-ubuntu-trusty-go_agent.tgz

-rw-rw-r--  0 ubuntu ubuntu  13549 Aug  4 10:06 ami.log
-rw-r--r--  0 ubuntu ubuntu   8134 Aug  4 09:23 apply_spec.yml
-rw-rw-r--  0 ubuntu ubuntu      0 Aug  4 09:45 image
-rw-rw-r--  0 ubuntu ubuntu    710 Aug  4 10:06 stemcell.MF
-rw-r--r--  0 ubuntu ubuntu  50594 Aug  4 09:23 stemcell_dpkg_l.txt
</pre>

* `ami.log`: Log file produced when making light stemcells for AWS.
* `apply_spec.yml`: YAML file used by the micro CLI plugin.
* `image`: OS image in a format (raw, qcow, ova, etc.) understood by the CPI/IaaS.
* `stemcell.MF`: YAML file with stemcell metadata.
* `stemcell_dpkg_l.txt`: Text file that includes list of packages installed on Ubuntu Trusty stemcells.

### <a id="metadata"></a> Metadata

* **name** [String, required]: A unique name used to identify stemcell series.
* **operating_system** [String, required]: Operating system in the stemcell. Example: `ubuntu-trusty`.
* **version** [String, required]: Version of the stemcell. Example: `3033`.
* **sha1** [String, required]: The SHA1 of the image file included in the stemcell tarball.
* **bosh_protocol** [Integer, optional]: Deprecated.
* **cloud_properties** [Hash, required]: Describes any IaaS-specific properties needed to import OS image. These properties will be passed in to the [`create_stemcell` CPI call](cpi-api-v1.html#create-stemcell).

Name, operating system and version values will be visible via `bosh stemcells` command once a stemcell is imported into the Director.

Example:

<pre class="terminal">
$ tar -Oxzf light-bosh-stemcell-3033-aws-xen-hvm-ubuntu-trusty-go_agent.tgz stemcell.MF
</pre>

```yaml
---
name: bosh-aws-xen-hvm-ubuntu-trusty-go_agent
operating_system: ubuntu-trusty
version: '3033'
sha1: c13273b00b762c5aa29240ea62e1b9b5a03ae02c
bosh_protocol: 1
cloud_properties:
  name: bosh-aws-xen-hvm-ubuntu-trusty-go_agent
  version: '3033'
  infrastructure: aws
  hypervisor: xen
  root_device_name: /dev/sda1
  ami:
    us-east-1: ami-3dc56656
    us-west-1: ami-db9a659f
    us-west-2: ami-dd5850ed
```

---
## <a id="light-stemcells"></a> Light Stemcells

Some IaaSes (or how they are configured) limit how OS images can be imported. Here are couple of examples:

- AWS only allows creation of AMIs from running VMs on AWS
- OpenStack can be configured to disallow Glance image upload
- an IaaS may take long time to import an image making it beneficial to reuse existing images

In such cases CPI must use already imported OS image and that's where light stemcells come in. Light stemcell tarballs include additional details about already imported OS images in the `cloud_properties` section. For example light stemcells for AWS have `ami` key in the `cloud_properties` section (as shown above), that contains region-to-AMI-ID mappings. When AWS CPI's [`create_stemcell` call](cpi-api-v1.html#create-stemcell) is made, it will return matching AMI ID without doing any IaaS API calls.

---
## <a id="testing"></a> Testing

There are two test suites each stemcell is expected to pass before it's considered to be production-ready:

- shared [Stemcell Tests](https://github.com/cloudfoundry/bosh/tree/master/bosh-stemcell/spec) which verify that proper packages and configurations are installed
- shared [BOSH Acceptance Tests (BATS)](https://github.com/cloudfoundry/bosh/blob/master/docs/running_tests.md#bosh-acceptance-tests-bats) (provided by the BOSH team) which verify high level Director behavior with the stemcell being used

---
[Back to Table of Contents](index.html#extend)

Previous: [Agent-CPI interactions](agent-cpi-interactions.html)
