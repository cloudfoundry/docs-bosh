!!! note
    Applicable for director version 268.5.0+

# Rotating Blobstore Agent Password

As of director version 268.5.0+, blobstore agent password can be rotated.

### Preconditions

* The Director is in a healthy state.
* Take note of any ignored VMs. They will be omitted from the VM recreation steps.
* All the VMs are in the `running` state in all deployments.
* These instructions must be adapted if used with bosh-lite ops files, as they overwrite the variables used in this procedure.

### Step 1: Update the director to add a new user {: #step-1}

```shell
OLD_PWD=$(bosh interpolate --path=/blobstore_agent_password creds.yml)
bosh interpolate ./creds.yml \
 -o rename-blobstore-agent-password.yml \
 -v blobstore_agent_old_password=$OLD_PWD > creds_new.yml
mv creds_new.yml creds.yml
unset OLD_PWD
```

`rename-blobstore-agent-password.yml`:

```yaml
---
- type: remove
  path: /blobstore_agent_password?

- type: replace
  path: /blobstore_agent_old_password?
  value: ((blobstore_agent_old_password))
```

```shell
bosh create-env ~/workspace/bosh-deployment/bosh.yml \
 --state state.json \
 -o ~/workspace/bosh-deployment/[IAAS]/cpi.yml \
 -o rotate-blobstore-agent-password.yml \
 -o ... additional opsfiles \
 --vars-store ./creds.yml \
 -v ... additional vars
```

`rotate-blobstore-agent-password.yml`:

```yaml
---
- type: replace
  path: /instance_groups/name=bosh/properties/agent/env/bosh/blobstores?/provider=dav/options/user
  value: agent-new

- type: replace
  path: /instance_groups/name=bosh/properties/blobstore/agent/user
  value: agent-new

- type: replace
  path: /instance_groups/name=bosh/properties/blobstore/agent/additional_users?
  value:
    - user: agent
      password: ((blobstore_agent_old_password))
```

* move the old user and password to `additional_users` section of blobstore properties
* create new user and password

### Step 2: Redeploy all VMs {: #step-2}
The recreation of all VMs will add the new credentials and remove the old credentials from their agent
settings.

### Step 3: Update director to remove old user {: #step-3}

```shell
bosh interpolate ./creds.yml \
 -o remove-old-blobstore-agent-password.yml > creds_new.yml
mv creds_new.yml creds.yml
```

`remove-old-blobstore-agent-password.yml`:

```yaml
---
- type: remove
  path: /blobstore_agent_old_password?
```

```shell
bosh create-env ~/workspace/bosh-deployment/bosh.yml \
 --state ./state.json \
 -o ~/workspace/bosh-deployment/[IAAS]/cpi.yml \
 -o ./rename-default-agent-user.yml \
 -o ... additional opsfiles \
 --vars-store ./creds.yml \
 -v ... additional vars
```

`rename-default-agent-user.yml`:

```yaml
---
- type: replace
  path: /instance_groups/name=bosh/properties/agent/env/bosh/blobstores?/provider=dav/options/user
  value: agent-new

- type: replace
  path: /instance_groups/name=bosh/properties/blobstore/agent/user
  value: agent-new
```

* Deploy director without the old user in the `additional_users` section of blobstore properties.
* Since the new user name is `agent-new`, from now one you have to deploy the Director with the following `rename-default-agent-user.yml` ops file.

### Optional steps:
Rotate a second time to get rid of the additional `rename-default-agent-user.yml` ops file by naming the new user `agent` and the old user `agent-new`.
