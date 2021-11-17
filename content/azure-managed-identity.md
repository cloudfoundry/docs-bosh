You can configure BOSH to use [Azure Managed Identities](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/qs-configure-cli-windows-vm) to avoid hard coding specific Azure credentials.
Azure Managed Identities are similar to AWS instance profiles.  
You first have to create an Azure Managed Identity, and give the proper roles/permissions required by BOSH (i.e. create/delete VM, create/delete/attach disks).

Theres is an [azure/use-managed-identity.yml operator file](https://github.com/cloudfoundry/bosh-deployment/blob/master/azure/use-managed-identity.yml) that you can use.

Once deployed and your BOSH director VM has been recreated, it should have a "User Managed" identity with the name you specified on the ``azure/default_managed_identity?/user_assigned_identity_name`` property.  
You can check this by going to Azure Portal _=> Virtual Machines => select BOSH director VM => Identities_

