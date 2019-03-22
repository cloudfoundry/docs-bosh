# Rotating mbus password

Currently the mbus password can be rotated, but this will kill the Director's VM without executing the drain script first.

### Preconditions

* If Director is in a healthy state there are no new deployments in progress.
* These instructions must be adapted if used with bosh-lite ops files, as they overwrite the variables used in this procedure.

### Step 1: Remove mbus password from `creds.yml` {: #step-1}

```shell
bosh interpolate ./creds.yml \
 -o remove-mbus-password.yml > creds_new.yml

mv creds_new.yml creds.yml
```

Ops file:

`remove-mbus-password.yml`

```yaml
---
- type: remove
  path: /mbus_bootstrap_password?
```

* This will remove the `mbus_bootstrap_password` from the `creds.yml`, which will cause the next create-env to create a new one.

### Step 2: Redeploy the Director with a new mbus password {: #step-2}

```shell
bosh create-env ~/workspace/bosh-deployment/bosh.yml \
 --state ./state.json \
 -o ~/workspace/bosh-deployment/[IAAS]/cpi.yml \
 -o ... additional opsfiles \
 --vars-store ./creds.yml \
 -v ... additional vars
```

* This adds new mbus password to `creds.yml`.
* Since the password is replaced the CLI will not be able to communicate with the Agent and execute the drain script.
It will ultimately kill the Director's VM and recreate it. It is important that no deployments are in progress at this moment 
since a downtime is expected.
