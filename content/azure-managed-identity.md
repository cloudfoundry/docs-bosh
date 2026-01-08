You can configure BOSH to use [Azure Managed Identities](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/qs-configure-cli-windows-vm) to avoid hard coding specific Azure credentials.
Azure Managed Identities are similar to [AWS instance profiles](aws-iam-instance-profiles.md).  
You first have to create an Azure Managed Identity, and give the proper roles/permissions required by BOSH (i.e. create/delete VM, create/delete/attach disks).  

Next is updating your bosh manifest and add the property _default_managed_identity_ and also no longer using the client_id, client_secret and tenant_id, like in this example:

```yaml
      azure:
      credentials_source: managed_identity
      default_managed_identity:
        type: UserAssigned
        user_assigned_identity_name: my-managed-identity
      default_security_group: ((default_security_group))
      environment: AzureCloud
      resource_group_name: ((resource_group_name))
      ssh_public_key: ((ssh.public_key))
      ssh_user: vcap
      storage_account_name: ((storage_account_name))
      subscription_id: ((subscription_id))
      use_managed_disks: true
```

There is also an [azure/use-managed-identity.yml operator file](https://github.com/cloudfoundry/bosh-deployment/blob/master/azure/use-managed-identity.yml) that you can use to make these changes.

Once deployed and your BOSH director VM has been recreated, it should have a "User Managed" identity with the name you specified on the ``user_assigned_identity_name`` property (see example above).  
You can check this by going to Azure Portal _=> Virtual Machines => select BOSH director VM => Identities_

