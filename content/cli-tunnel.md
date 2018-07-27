!!! note
    Applies to CLI v2.

CLI supports tunnelling all of its traffic (HTTP and SSH) through a SOCKS 5 proxy specified via `BOSH_ALL_PROXY` environment variable. (Custom environment variable was chosen instead of using `all_proxy` environment variable to avoid accidentally tunnelling non-CLI traffic.)

Common use cases for tunnelling through a jumpbox VM include:

- deploying Director VM with `bosh create-env` command
- accessing the Director and UAA APIs

```shell
# establish a tunnel and make it available on a local port
$ ssh -4 -D 12345 -fNC jumpbox@jumpbox-ip -i jumpbox.key

# let CLI know about above tunnel via environment variable
$ export BOSH_ALL_PROXY=socks5://localhost:12345

$ bosh create-env bosh-deployment/bosh.yml ...
$ bosh alias-env aws -e director-ip --ca-cert ...
```

SSH options:

- `-D` : local SOCKS port; make sure port is not already in use by a different tunnel/process
- `-f` : forks the process in the background
- `-C` : compresses data before sending
- `-N` : tells SSH that no command will be sent once the tunnel is up
- `-4` : force SSH to use IPv4 to avoid the dreaded `bind: Cannot assign requested address` error
