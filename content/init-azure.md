This document shows how to initialize new [environment](terminology.md#environment) on Microsoft Azure.

## Step 1: Prepare an Azure Environment {: #prepare }

If you do not have an Azure account, [create one](https://azure.microsoft.com/en-us/pricing/free-trial/).

Then follow this [guide](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/blob/master/docs/get-started/create-service-principal.md) to create your Azure service principal.

We strongly recommend you to use Azure template [bosh-setup](https://github.com/Azure/azure-quickstart-templates/tree/master/bosh-setup) to initialize the new environment on Microsoft Azure.

To prepare your Azure environment find out and/or create any missing resources in Azure. If you are not familiar with Azure take a look at [Creating Azure resources](azure-resources.md) page for more details on how to create and configure necessary resources:

---
## Step 2: Deploy {: #deploy }

1. Install [CLI v2](cli-v2.md).

1. Use `bosh create-env` command to deploy the Director.

    ```shell
    # Create directory to keep state
    mkdir bosh-1 && cd bosh-1

    # Clone Director templates
    git clone https://github.com/cloudfoundry/bosh-deployment

    # Fill below variables (replace example values) and deploy the Director
    bosh create-env bosh-deployment/bosh.yml \
        --state=state.json \
        --vars-store=creds.yml \
        -o bosh-deployment/azure/cpi.yml \
        -v director_name=bosh-1 \
        -v internal_cidr=10.0.0.0/24 \
        -v internal_gw=10.0.0.1 \
        -v internal_ip=10.0.0.6 \
        -v vnet_name=boshnet \
        -v subnet_name=bosh \
        -v subscription_id=3c39a033-c306-4615-a4cb-260418d63879 \
        -v tenant_id=0412d4fa-43d2-414b-b392-25d5ca46561da \
        -v client_id=33e56099-0bde-8z93-a005-89c0f6df7465 \
        -v client_secret=client-secret \
        -v resource_group_name=bosh-res-group \
        -v storage_account_name=boshstore \
        -v default_security_group=nsg-bosh
    ```

    If running above commands outside of a connected Azure network, refer to [Exposing environment on a public IP](init-external-ip.md) for additional CLI flags.

    See [Azure CPI errors](azure-cpi-errors.md) for list of common errors and resolutions.

1. Connect to the Director.

    ```shell
    # Configure local alias
    bosh alias-env bosh-1 -e 10.0.0.6 --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca)

    # Log in to the Director
    export BOSH_CLIENT=admin
    export BOSH_CLIENT_SECRET=`bosh int ./creds.yml --path /admin_password`

    # Query the Director for more info
    bosh -e bosh-1 env
    ```

1. Save the deployment state files left in your deployment directory `bosh-1` so you can later update/delete your Director. See [Deployment state](cli-envs.md#deployment-state) for details.
