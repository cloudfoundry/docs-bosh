This topic describes how to build a CPI.

## Distribution {: #distribution }

CPIs are distributed as regular releases, typically with a release job called `cpi` and a few packages that provide compilation/runtime environment for that job if necessary (e.g. [bosh-aws-cpi-release](https://github.com/cloudfoundry-incubator/bosh-aws-cpi-release) includes Ruby and [bosh-warden-cpi-release](https://github.com/cppforlife/bosh-warden-cpi-release) includes golang). To qualify to be a CPI release, it must include a release job that has `bin/cpi` executable.

Both `bosh create-env` command and the Director expect to be configured with a CPI release to function properly. In the case of `bosh create-env` command, specified CPI release is unpacked and installed on the machine running the command. For the Director, CPI release job is colocated on the same VM, so that the director release job can access it.


## Implementation

When building a CPI release, the primary requirement is that it provides a `bin/cpi` executable which implements a simple RPC API through `STDIN`/`STDOUT`. The [RPC API](cpi-api-v1-rpc.md) page provides an in-depth look at the protocol and required methods.

If you are getting started with a new CPI, you may be interested in using one of the following languages. These releases take advantage of some existing libraries that you may find useful in your own implementation.


### Ruby

The [`bosh_cpi`](https://rubygems.org/gems/bosh_cpi) gem provides a `Bosh::Cpi::Cli` class which handles the deserialization and serialization of the RPC calls. You can see examples of this in the following CPIs:

 * [Amazon Web Services CPI Release](https://github.com/cloudfoundry-incubator/bosh-aws-cpi-release)
 * [Microsoft Azure CPI Release](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release)
 * [OpenStack CPI Release](https://github.com/cloudfoundry-incubator/bosh-openstack-cpi-release)
 * [VMware vSphere CPI Release](https://github.com/cloudfoundry-incubator/bosh-vsphere-cpi-release)
 * [VMware vCloud CPI Release](https://github.com/cloudfoundry-incubator/bosh-vcloud-cpi-release)


### Go

There are a few CPI releases written in Go, as well:

 * [Google CPI Release](https://github.com/cloudfoundry-incubator/bosh-google-cpi-release)
 * [VirtualBox CPI Release](https://github.com/cppforlife/bosh-virtualbox-cpi-release)
 * [Warden CPI Release](https://github.com/cppforlife/bosh-warden-cpi-release)


## Testing {: #testing }

There are two test suites each CPI is expected to pass before it's considered to be production-ready:

- its own [CPI Lifecycle Tests](https://github.com/cloudfoundry/bosh/blob/master/docs/running_tests.md#cpi-lifecycle-tests) which should provide integration level coverage for each CPI method
- shared [BOSH Acceptance Tests (BATS)](https://github.com/cloudfoundry/bosh/blob/master/docs/running_tests.md#bosh-acceptance-tests-bats) (provided by the BOSH team) which verify high level Director behavior with the CPI activated


## Concurrency {: #concurrency }

The CPI is expected to handle multiple method calls concurrently (and in parallel) with a promise that arguments represent different IaaS resources. For example, multiple `create_vm` CPI method calls may be issued that all use the same stemcell cloud ID; however, `attach_disk` CPI method will never be called with the same VM cloud ID concurrently.

!!! note
    Since each CPI method call is a separate OS process, simple locking techniques (Ruby's <code>Mutex.new</code> for example) will not work.


## Rate Limiting {: #rate-limiting }

Most CPIs have to deal with IaaS APIs that rate limit (e.g. OpenStack, AWS). Currently it is the responsibility of the CPI to handle rate-limiting errors, properly catch them, wait and retry actions that were interrupted. Given that there is no timeout around how long a CPI method can run, it's all right to wait as long as necessary to resume making API calls. Though it's suggested to log such information.


## Debugging {: #debugging }

It usually useful to get a detailed log of CPI requests and responses from the callee. To get a full debug log from `bosh create-env` command set `BOSH_LOG_LEVEL=debug` environment variable.

When working with the Director you can find similar debug logs via `bosh task X --debug` command.
