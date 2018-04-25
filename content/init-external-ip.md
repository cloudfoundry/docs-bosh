It's strongly recommended to not allow ingress traffic to the Director VM via public IP. One way to achieve that is to use a [jumpbox](terminology.md#jumpbox) to access internal networks.

If you do have a jumpbox consider using [CLI tunneling functionality](cli-tunnel.md) instead of running CLI from the jumpbox VM.

When it's not desirable or possible to have a jumpbox, you can use following steps to assign public IP to the Director VM.

For CPIs that do not use registry (Google, vSphere, vCloud):

```shell
$ bosh create-env bosh-deployment/bosh.yml \
    -o ... \
    -o bosh-deployment/external-ip-not-recommended.yml \
    -v ... \
    -v external_ip=12.34.56.78
```

Or for CPIs that do use registry (AWS, Azure, and OpenStack):

```shell
$ bosh create-env bosh-deployment/bosh.yml \
    -o ... \
    -o bosh-deployment/external-ip-with-registry-not-recommended.yml \
    -v ... \
    -v external_ip=12.34.56.78
```

!!! note
    If you have already ran `bosh create-env` command before adding above operations file, you may have to remove generated Director (and other components such as UAA) SSL certificates from the variables store so that SSL certificates can be regenerated with SANs.
