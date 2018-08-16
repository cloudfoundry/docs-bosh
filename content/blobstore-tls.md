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
                  ca: ((blobstore_ca.certificate))

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


## Ignored or Stopped Instances

Take note of any ignored instances with `bosh instances --details`. These instances will not be considered when redeploying or recreating instances. Ignored instances will only receive new certificates when recreated.

Any instances stopped with `bosh stop` will not receive the new CA or certificate until recreated. Performing `bosh start` on these instances will transition the VM to running successfully. However, if a redeploy does not trigger a recreate, this instance will fail to update. The agent consults the blobstore for templates during VM lifecycle changes.

Instances that have been stopped with `bosh stop --hard` have been destroyed, keeping the persistent disk if applicable. Performing a `bosh start` on those instances will recreate the VM. These instances will then receive the new CA.

## Introducing a New Certificate Authority (CA)

1. Create a backup of the existing credentials file (usually `creds.yml`). Remove the `blobstore_ca` and `blobstore_server_tls` records (including children) from the working copy of `creds.yml`. Removing the existing keys and values will regenerate them during the next director update.
1. Redeploy the director with `bosh create-env` using the updated `creds.yml`.
1. Recreate all instances in all deployments to update instances with the new CA.

## Troubleshooting

Performing a redeploy across one or more instances that continue to use the old CA will cause the deployment to fail.

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
