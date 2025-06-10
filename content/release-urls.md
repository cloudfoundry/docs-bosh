This topic describes allowed types of URLs for downloading releases (typically
found in deployment manifests).

## Local URLs {: #local }

Upload Release tarball from local filesystem.

```yaml
releases:
  - name: syslog
    version: 11
    url: file://syslog-11.tgz
    sha1: 332ac15609b220a3fdf5efad0e0aa069d8235788
```

`sha1` key is not required but can be specified.

CLI v2 will look for file locally and provide it to the `upload-release` command.

Above declaration is equivalent to running
`bosh upload-release syslog-11.tgz --sha1 332ac15609b220a3fdf5efad0e0aa069d8235788`.

---
## HTTP/HTTPs URLs {: #http }

Upload Release tarball from remote location.

```yaml
releases:
  - name: syslog
    version: 11
    url: https://bosh.io/d/github.com/cloudfoundry/syslog-release?v=11
    sha1: 332ac15609b220a3fdf5efad0e0aa069d8235788
```

CLI v2 will delegate download of the release to the Director, hence Director
must have connectivity to specified resource.

Above declaration is equivalent to running
`bosh upload-release https://bosh.io/d/github.com/cloudfoundry/syslog-release?v=11 --sha1 332ac15609b220a3fdf5efad0e0aa069d8235788`.

---
## Git over HTTP/HTTPs URLs {: #git-http }

Reconstruct Release tarball from remote Git repository.

```yaml
releases:
  - name: syslog
    version: 11
    url: git+https://github.com/cloudfoundry/syslog-release
```

`sha1` key is not required as we rely on Git's HTTP transport mechanism to
pull down expected content.

CLI v2 will perform a shallow clone locally and run `upload-release` command
from within cloned repository.

Above declaration is equivalent to running
`bosh upload-release git+https://github.com/cloudfoundry/syslog-release --name syslog --version 11`.
