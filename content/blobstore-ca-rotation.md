!!! note
    Applicable for director version 266.2.0+

    Linux stemcells v3586.5+ (agent 2.83.0)

    Windows 2016 stemcell v1709.9+, Windows 2012R2 v1200.20+ (agent 2.110.0)

# Rotating the Blobstore CA

Applies to a director with TLS enabled for the default DAV blobstore.

Example director configuration enabling TLS for the DAV blobstore. Refer to [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment) for a full manifest reference.
```
...
instance_groups:
- name: bosh
  properties:
    agent:
      env:
        bosh:
          blobstores:
          - provider: dav
            options:
              endpoint: https://((internal_ip)):25250
              user: agent
              password: ((blobstore_agent_password))
              tls:
                cert:
                  cat: ((blobstore_ca.certificate))

    blobstore:
      address: ((internal_ip))
      port: 25250
      provider: dav
      director:
        user: director
        password: ((blobstore_director_password))
      agent:
        user: agent
        password: ((blobstore_agent_password))
      tls:
        cert:
          ca: ((blobstore_ca.certificate))
          certificate: ((blobstore_server_tls.certificate))
          private_key: ((blobstore_server_tls.private_key))
...
```


## Ignored Instances

Take note of any ignored instances with `bosh instances --details`. These instances will not be considered when redeploying or recreating instances. Ignored instances will only receive new certificates when recreated.

## Introducing a New Certificate Authority (CA) **(for smaller environments)**

When rotating blobstore CA with this method, all instances **must** be recreated before jobs can be successfully updated on the instance.  Consider the method for larger instances if that is an issue.

1. Create a backup of the existing credentials file (usually `creds.yml`). Remove the `blobstore_ca` and `blobstore_server_tls` records (including children) from the working copy of `creds.yml`. Removing the existing keys and values will regenerate them during the next director update.
1. Redeploy the director with `bosh create-env` using the updated `creds.yml`.
1. Recreate all instances in all deployments to update instances with the new CA.


## Introducing a New Certificate Authority (CA) **(for larger environments)**

This method transitionally allows both the blobstore with the old and new certificate on all VMs which makes quick patches of jobs possible if interrupted temporarily. To achieve this it requires multiple deploys and recreates of all deployments.  Note that this method is analogous to the [NATS CA rotation](nats-ca-rotation.md) which could be done at the same time.

### Preconditions

* Director is in a healthy state.
* All VMs are in `running` state in all deployments.
* These instructions would have to be adapted if used with bosh-lite ops files, as they overwrite the same variables in this guide.


### Step 1: Redeploy the director with new blobstore CA. {: #step-1}

```shell

$ bosh create-env ~/workspace/bosh-deployment/bosh.yml \
 --state ./state.json \
 -o ~/workspace/bosh-deployment/[IAAS]/cpi.yml \
 -o ~/workspace/bosh-deployment/misc/blobstors-tls.yml \
 -o add-new-blobstore-ca.yml \
 -o ... additional opsfiles \
 --vars-store ./creds.yml \
 -v ... additional vars
```

* Adds new variables for the new CA/certificates/private_key.
* The director is given a modified CA with the original CA and the new CA concatenated as `((blobstore_server_tls.ca))((blobstore_server_tls_2.ca))`.
* Blobstore continues to use the old certificates and private key.
* Each VM/agent continues to use the old certificates to communicate with the blobstore.

`add-new-blobstore-ca.yml`

```yaml
---
- type: replace
  path: /instance_groups/name=bosh/properties/agent/env/bosh/blobstores?/provider=dav/options/tls/cert/ca
  value: ((blobstore_server_tls_2.ca))((blobstore_server_tls.ca))

- type: replace
  path: /variables/-
  value:
    name: blobstore_ca_2
    type: certificate
    options:
      is_ca: true
      common_name: default.blobstore-ca.bosh-internal

- type: replace
  path: /variables/-
  value:
    name: blobstore_server_tls_2
    type: certificate
    options:
      ca: blobstore_ca_2
      common_name: ((internal_ip))
      alternative_names: [((internal_ip))]
```

### Step 2: Recreate all VMs, for each deployment. {: #step-2}

VMs need to be recreated in order to receive new certificates generated from the new Blobstore CA being rotated in. If not recreated, agents will continue to attempt communication with the blobstore, which sends a certificate signed by the new CA. The agent cannot verify the certificate with the old CA.

```shell
$ bosh -d deployment-name recreate
```

### Step 3: Redeploy the director to remove the old Blobstore CA. {: #step-3}

```shell
$ bosh create-env ~/workspace/bosh-deployment/bosh.yml \
 --state ./state.json \
 -o ~/workspace/bosh-deployment/[IAAS]/cpi.yml \
 -o ~/workspace/bosh-deployment/misc/blobstors-tls.yml \
 -o remove-old-blobstore-ca.yml \
 -o ... additional opsfiles \
 --vars-store ./creds.yml \
 -v ... additional vars
```

`remove-old-blobstore-ca.yml`

* `blobstore.tls.ca` is updated to remove the old CA from the concatenated CAs.
* The blobstore server is updated to use a new certificate and private key, generated by the new CA.
* All components can communicate using the new CA.

```yaml
---
- type: replace
  path: /instance_groups/name=bosh/properties/agent/env/bosh/blobstores?/provider=dav/options/tls/cert/ca
  value: ((blobstore_server_tls_2.ca))

- type: replace
  path: /instance_groups/name=bosh/properties/blobstore/tls?/cert
  value:
    ca: ((blobstore_server_tls_2.ca))
    certificate: ((blobstore_server_tls_2.certificate))
    private_key: ((blobstore_server_tls_2.private_key))

- type: replace
  path: /variables/-
  value:
    name: blobstore_ca_2
    type: certificate
    options:
      is_ca: true
      common_name: default.blobstore-ca.bosh-internal

- type: replace
  path: /variables/-
  value:
    name: blobstore_server_tls_2
    type: certificate
    options:
      ca: blobstore_ca_2
      common_name: ((internal_ip))
      alternative_names: [((internal_ip))]
```

### Step 4: Recreate all VMs, for each deployment. {: #step-4}

Recreating all VMs will remove the old CA from each.

```shell
$ bosh -d deployment-name recreate
```

#### Commands that will reset blobstore configuration on deployed VM
  - stop hard and start VMs
```
$ bosh -d deployment-name stop --hard
$ bosh -d deployment-name start
```
  - recreate VMs
```
$ bosh -d deployment-name recreate
```

#### Commands that will NOT reset blobstore configuration on deployed VM
  - restart VMs
```
$ bosh -d deployment-name restart
```
  - just stop and start VMs
```
$ bosh -d deployment-name stop
$ bosh -d deployment-name start
```


## Troubleshooting

* Performing a redeploy across one or more instances that continue to use the old CA will cause the deployment to fail using the smaller deployment technique.

```
Task 135 | 14:43:43 | Updating instance zookeeper: zookeeper/c7f03a6d-fcde-4d85-874f-8cb1503082f6 (0) (canary) (00:00:01)
                    L Error: Action Failed get_task:
                    Task 968fad85-0f1a-494b-6040-5cc949555d17 result:
                    Preparing apply spec: Preparing package openjdk-8:
                    Fetching package blob: Getting blob from inner blobstore:
                    Getting blob from inner blobstore: Shelling out to bosh-blobstore-dav cli:
                    Running command: 'bosh-blobstore-dav -c /var/vcap/bosh/etc/blobstore-dav.json get d1bccd47-95ad-4516-49bc-0cf42a2782c3 /var/vcap/data/tmp/bosh-blobstore-externalBlobstore-Get731225442',
                    stdout: 'Error running app - Getting dav blob d1bccd47-95ad-4516-49bc-0cf42a2782c3:
                    Get https://10.0.1.6:25250/d1/d1bccd47-95ad-4516-49bc-0cf42a2782c3:
                    x509: certificate signed by unknown authority (possibly because of
                    "crypto/rsa: verification error" while trying to verify
                    candidate authority certificate "default.blobstore-ca.bosh-internal")', stderr: '': exit status 1
```

Any instances that have not been recreated with `bosh recreate` or a redeploy which causes a recreate will cause the above error. Perform a `bosh recreate` on any instances impacting a redeploy.
