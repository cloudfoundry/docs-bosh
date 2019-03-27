# Rotating Credentials

## Generic Credential Rotation

In order to rotate a credential (e.g. password, certificate) remove the
credential from credential store (vars-store or CredHub).
The BOSH CLI (when using a vars-store) or CredHub will create a new credential
when re-deploying BOSH.

This applies for the following credentials:

* `hm_password`
* `blobstore_director_password` when using local blobstore
* `postgres_password` when using local postgres
* `uaa_clients_director_to_credhub` assuming UAA and CredHub are co-located on
* `mbus_bootstrap_password` results in hard shut down of director VM
  without running drain scripts (in future, this will be prevented by using
  mutual TLS). Therefore, it is important that no deployments are in progress
  before re-deploying the director.
  the director VM

### Credentials with additional steps:

* `admin_password`: for admin clients continue to authenticate after
the director gets re-deployed and before the new admin password is passed to the clients,
it is recommended to add a new admin user and password to `director.user_management.local.users` before removing the old password
* `nats_password` is deprecated and applies only if property
`nats.allow_legacy_agents` is set. Use mutual TLS instead. If `nats_password` needs to be rotated, all VMs deployed by the
director must be recreated. After re-deploying the director and before
re-deploying the VMs, the resurrector plugin of the health monitor may attempt
to resurrect the VMs or may consider the deployments in meltdown mode.
* `credhub_admin_client_secret`: for CredHub admin clients continue to authenticate after
CredHub gets re-deployed and before the new CredHub admin secret is passed to the clients,
it is recommended to add a new CredHub admin user and secret to `uaa.clients` before removing the old secret
* `credhub_cli_user_password`: for the CredHub CLI user continue to authenticate after
CredHub gets re-deployed and before the new CredHub CLI user password is passed to the clients,
it is recommended to add a new CredHub CLI user and password to `uaa.scim.users` before removing the old password
* `default_ca` including its signed certificates `director_ssl` and `mbus_bootstrap_ssl`:
If there are VMs deployed by the director which access the director HTTP API (e.g. the [service-fabrik-broker](https://github.com/cloudfoundry-incubator/service-fabrik-broker)), the concatenated old and new default
CA must be provided to the VMs before re-deploying the director. This is necessary for the VMs to communicate with the director HTTP API
after the director gets re-deployed with the new default CA and
before the VMs get re-deployed with the new default CA.
* `credhub_ca` including its singed certificate `credhub_tls`:
If there are VMs deployed by the director which access the CredHub API, the concatenated old and new CredHub
CA must be provided to the VMs before re-deploying the director. This is necessary for the VMs to communicate with the CredHub API
after the director gets re-deployed with the new CredHub CA and
before the VMs get re-deployed with the new CredHub CA.

## Specific Credential Rotation

`external_db_password`:

1. Add new user/password to database system with access to the BOSH database
1. Update `external_db_user`/`external_db_password` with the new credentials
1. Re-deploy director
1. Remove old user/password from database system
