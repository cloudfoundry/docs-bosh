# Rotating CredHub Encryption Password

### Preconditions

* The director is in a healthy state.

### Assumptions

* CredHub is co-located on the BOSH director VM

### Step 1: Update CredHub to encrypt with new password {: #step-1}

```shell
OLD_PWD=$(bosh interpolate --path=/credhub_encryption_password creds.yml)
cp creds.yml creds.yml.bak
bosh interpolate creds.yml.bak \
 -o rename-credhub-encryption-password.yml \
 -v credhub_encryption_password_old=$OLD_PWD > creds.yml
unset OLD_PWD
```

Ops file `rename-credhub-encryption-password.yml`:

```yaml
---
- type: remove
  path: /credhub_encryption_password

- type: replace
  path: /credhub_encryption_password_old?
  value: ((credhub_encryption_password_old))
```

```shell
bosh create-env ~/workspace/bosh-deployment/bosh.yml \
 --state state.json \
 -o ~/workspace/bosh-deployment/[IAAS]/cpi.yml \
 -o ~/workspace/bosh-deployment/credhub.yml \
 -o add-old-credhub-encryption-password.yml \
 -o ... additional ops files \
 --vars-store ./creds.yml \
 -v ... additional vars
```

Ops file `add-old-credhub-encryption-password.yml`:

```yaml
---
- type: replace
  path: /instance_groups/name=bosh/jobs/name=credhub/properties/credhub/encryption/keys/-
  value:
    active: false
    key_properties:
      encryption_password: ((credhub_encryption_password_old))
    provider_name: internal
```

* create new password
* deactivate old password
* let CredHub decrypt all secrets with old password and encrypt all secrets with
  new password

### Step 2: Update CredHub to remove old password {: #step-2}

```shell
cp creds.yml creds.yml.bak
bosh interpolate creds.yml.bak \
 -o remove-old-credhub-encryption-password.yml > creds.yml
```

Ops file `remove-old-credhub-encryption-password.yml`:

```yaml
---
- type: remove
  path: /credhub_encryption_password_old
```

```shell
bosh create-env ~/workspace/bosh-deployment/bosh.yml \
 --state ./state.json \
 -o ~/workspace/bosh-deployment/[IAAS]/cpi.yml \
 -o ~/workspace/bosh-deployment/credhub.yml \
 -o ... additional ops files \
 --vars-store ./creds.yml \
 -v ... additional vars
```
