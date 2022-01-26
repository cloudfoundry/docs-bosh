Cloud Foundry's upcoming stemcells will be based on Ubuntu's [Jammy Jellyfish](https://wiki.ubuntu.com/Releases) release, which may cause compilation errors in packages built for earlier stemcells.This document provides guidance on how to address the most common errors that BOSH release authors may encounter. The following updated packages in particular may impact compilation:

- GCC 11 — see [below](#gcc-11)
- OpenSSL 3— see [release notes](https://www.openssl.org/blog/blog/2021/09/07/OpenSSL3.Final/)

Discussion Slack channel is [here](https://app.slack.com/client/T02FL4A1X/C02M2R39Y8Z).

### GCC 11

Here's a typical error (`multiple definition of ...`):

```text
/bin/ld: src/protocol.o:/var/vcap/data/compile/haproxy/haproxy-1.8.13/include/common/chunk.h:39: multiple definition of `pool_head_trash'; src/ev_poll.o:/var/vcap/data/compile/haproxy/haproxy-1.8.13/include/common/chunk.h:39: first defined here
collect2: error: ld returned 1 exit status
```

This is caused by a change in GCC 10: it switched the default compilation to `-fno-common`, which means that if the header is included by several files it results in multiple definitions of the same variable and results in a linker error. The easiest way to fix this is to pass the `-fcommon` flag, which reverts to the earlier behavior (warning but no error). Read more about it in the _[Porting to GCC 10](https://gcc.gnu.org/gcc-10/porting_to.html)_ guide.

Here's a proposed change for the garden-runc-release's xfs-progs job's packaging script:

```bash
# gcc 10+ changed the default to "-fno-common"; we change it back to build properly
export CFLAGS="${CFLAGS} -fcommon"
```

Here's another fix from the routing-release's haproxy job's packaging script:

```bash
# gcc 10+ changed the default to "-fno-common"; we change it back to build properly
make TARGET=linux2628 USE_OPENSSL=1 TARGET_CFLAGS=-fcommon
```

### Addons (Runtime Configurations)

If you restrict your addons to certain stemcells, be sure to include Jammy in your list of stemcells (if you intend your addon to run on Jammy). The following is the updated stemcell list for [cf-deployment](https://github.com/cloudfoundry/cf-deployment)'s manifest:

```yaml
addons:
- name: loggregator_agent
  include:
    stemcell:
    - os: ubuntu-xenial
    - os: ubuntu-bionic
    - os: ubuntu-jammy
```
