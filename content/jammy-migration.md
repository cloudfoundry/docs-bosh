Cloud Foundry's upcoming stemcells will be based on Ubuntu's [Jammy Jellyfish](https://wiki.ubuntu.com/Releases) release, which may cause compilation and deployment errors in packages built for earlier stemcells. This document provides guidance on how to address the most common errors that BOSH release authors may encounter. There are three broad categories to address:

- GCC 11 — see [below](#gcc-11)
- OpenSSL 3 — see [below](#openssl-3)
- Addons - see [below](#addons-runtime-configurations)

Discussion Slack channel is [here](https://app.slack.com/client/T02FL4A1X/C02M2R39Y8Z).

### GCC 11

Here's a typical error during compilation phase (`multiple definition of ...`):

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

### OpenSSL 3

OpenSSL 3 is a "[is a major release and not fully backwards compatible with the
previous
release](https://www.openssl.org/blog/blog/2021/09/07/OpenSSL3.Final/)". Jammy includes OpenSSL 3. Although it's unlikely that your package directly uses OpenSSL 3, it's quite possible that one of your package's dependencies do. Bump to a newer version of the dependency which supports OpenSSL 3, for example Ruby 2.7 → 3.1, nginx 1.20.1 → 1.21.6, HAProxy 1.8.13 → 2.5.1. Here are typical failures:

##### When Compiling Ruby 2.7.2

```
ossl_pkey_rsa.c:877:58: error: 'RSA_SSLV23_PADDING' undeclared (first use in this function); did you mean 'RSA_NO_PADDING'?
...
make[2]: *** [Makefile:313: ossl_pkey_rsa.o] Error 1
make[1]: *** [exts.mk:250: ext/openssl/all] Error 2
make: *** [uncommon.mk:295: build-ext] Error 2
```

Bump the dependency to a version of Ruby that includes OpenSSL 3 support: Ruby 3.1. If you're using [BOSH packages](https://github.com/cloudfoundry/bosh-package-ruby-release), here's how:

```shell
pushd ~/workspace/ruby-release
git pull -r
popd
bosh vendor-package ruby-3.1.0-r0.82.0 ~/workspace/ruby-release
nvim packages/*/spec # update Ruby dependencies to include the new version
```

Note: bumping Ruby versions on any but the most trivial codebases is a significant effort.

##### When Compiling nginx 1.20.1

```
src/event/ngx_event_openssl.c:5354:5: error: 'ENGINE_free' is deprecated: Since OpenSSL 3.0 [-Werror=deprecated-declarations]
 5354 |     ENGINE_free(engine);
      |     ^~~~~~~~~~~
In file included from src/event/ngx_event_openssl.h:22,
                 from src/core/ngx_core.h:84,
                 from src/event/ngx_event_openssl.c:9:
/usr/include/openssl/engine.h:493:27: note: declared here
  493 | OSSL_DEPRECATEDIN_3_0 int ENGINE_free(ENGINE *e);
      |                           ^~~~~~~~~~~
cc1: all warnings being treated as errors
make[1]: *** [objs/Makefile:853: objs/src/event/ngx_event_openssl.o] Error 1
make: *** [Makefile:10: build] Error 2
```

Bump to nginx 1.21.6 to fix.

##### When Compiling HAProxy 1.8.13:

```
make: *** [Makefile:909: src/ssl_sock.o] Error 1
```

Bump to HAProxy 2.5.1 to fix.

##### When Using `keytool` with OpenJDK 8/11:

```
keytool error: java.io.IOException: keystore password was incorrect
```

Use `openssl pkcs12`'s `-legacy` flag when creating the Java keystore.

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
