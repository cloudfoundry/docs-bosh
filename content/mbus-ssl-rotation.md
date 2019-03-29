# Rotating mbus SSL

Bootstrap SSL certificate needs to be removed from the `creds.yml` and re-created later with `create-env`. 
Since the signing CA is the Director's default CA and remains unchanged, no updates are required on the CLI side.

### Preconditions

* Director is in a healthy state and there are no new deployments in progress.
* These instructions must be adapted if used with ops files overwriting the variables used in this procedure (i.e. bosh-lite).

### Step 1: Remove mbus SSL from `creds.yml` {: #step-1}

```shell
bosh interpolate ./creds.yml \
 -o remove-mbus-ssl.yml > creds_new.yml

mv creds_new.yml creds.yml
```

Ops file `remove-mbus-ssl.yml`

```yaml
---
- type: remove
  path: /mbus_bootstrap_ssl?
```

* This will remove the `mbus_bootstrap_ssl` from the `creds.yml`, causing the next `create-env` to create a new one.

### Step 2: Redeploy the Director with a new mbus SSL certificate {: #step-2}

```shell
bosh create-env ~/workspace/bosh-deployment/bosh.yml \
 --state ./state.json \
 -o ~/workspace/bosh-deployment/[IAAS]/cpi.yml \
 -o ... additional ops files \
 --vars-store ./creds.yml \
 -v ... additional vars
```

* This adds a new mbus SSL certificate to `creds.yml`.
