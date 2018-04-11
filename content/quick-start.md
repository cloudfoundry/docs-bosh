The easiest ways to get started with BOSH is by running on your local workstation with [VirtualBox](https://www.virtualbox.org/). If you are interested in bringing up a director in another environment, like [Google Cloud Platform](https://cloud.google.com/), choose your IaaS from the navigation for more detailed instructions.


## Prerequisites

Before trying to deploy the Director, make sure you have satisfied the following requirements:

1. For best performance, ensure you have at least 8GB RAM and 50GB of free disk space.

1. Install the [`bosh` CLI](cli-v2-install.md) and its [additional dependencies](cli-v2-install.md#additional-dependencies).

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads).


## Install

First, create a workspace for our `virtualbox` environment. This directory will keep some state and configuration files that we will need.

```shell
$ mkdir -p ~/bosh-env/virtualbox
$ cd ~/bosh-env/virtualbox
```

Next, we'll use [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment), the recommended installation method, to bootstrap our director.

```shell
$ git clone https://github.com/cloudfoundry/bosh-deployment.git
```

Now, we can run the [`virtualbox/create-env.sh`](https://github.com/cloudfoundry/bosh-deployment/blob/master/virtualbox/create-env.sh) script to create our test director and configure the environment with some defaults.

```shell
$ ./bosh-deployment/virtualbox/create-env.sh
```

During the bootstrap process, you will see a few stages:

 * Creating BOSH Director - dependencies are downloaded, the VM is created, and BOSH is installed, configured, and started.
 * Adding Network Routes - a route to the virtual network is added to ensure you will be able to connect to BOSH-managed VMs.
 * Generating `.envrc` - a settings file is generated so you can easily connect to the environment later.
 * Configuring Environment Alias - an alias is added for the `bosh` command so you can reference the environment as `vbox`.
 * Updating Cloud Config - default settings are applied to the Director so you easily deploy software later.

After a few moments, BOSH should be started. To verify, first load your connection settings, and then run your first `bosh` command where you should see similar output.

```shell
$ source .envrc
$ bosh -e vbox env
Using environment '192.168.50.6' as client 'admin'

Name      bosh-lite
UUID      7ce65259-471a-424b-88cb-9d3cee85db2c
Version   265.2.0 (00000000)
CPI       warden_cpi
User      admin
```

Congratulations - BOSH is running! Now you're ready to [deploy](#deploy)

!!! help "Troubleshooting"
    If you run into any trouble, please continue to the [VirtualBox Troubleshooting](bosh-lite.md) section.


## Deploy

Run through quick steps below or follow [deploy workflow](basic-workflow.md) that goes through the same steps but with more explanation.

1. Update cloud config

    ```shell
    $ bosh -e vbox update-cloud-config ~/workspace/bosh-deployment/warden/cloud-config.yml
    ```

1. Upload stemcell

    ```shell
    $ bosh -e vbox upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=3468.17 \
      --sha1 1dad6d85d6e132810439daba7ca05694cec208ab
    ```

1. Deploy example deployment

    ```shell
    $ bosh -e vbox -d zookeeper deploy <(wget -O- https://raw.githubusercontent.com/cppforlife/zookeeper-release/master/manifests/zookeeper.yml)
    ```

1. Run Zookeeper smoke tests

    ```shell
    $ bosh -e vbox -d zookeeper run-errand smoke-tests
    ```
