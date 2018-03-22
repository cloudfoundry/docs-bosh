---
title: Release URLs
---

This topic describes allowed types of URLs for downloading releases (typically found in deployment manifests).

## <a id='local'></a> Local URLs

```yaml
releases:
- name: syslog
  version: 11
  url: file://syslog-11.tgz
  sha1: 332ac15609b220a3fdf5efad0e0aa069d8235788
```

`sha1` key is not required but can be specified.

CLI v2 will look for file locally and provide it to the `upload-release` command.

Above declaration is equivalent to `bosh upload-release syslog-11.tgz --sha1 332ac15609b220a3fdf5efad0e0aa069d8235788`.

---
## <a id='http'></a> HTTP/HTTPs URLs

```yaml
releases:
- name: syslog
  version: 11
  url: https://bosh.io/d/github.com/cloudfoundry/syslog-release?v=11
  sha1: 332ac15609b220a3fdf5efad0e0aa069d8235788
```

CLI v2 will delegate download of the release to the Director, hence Director must have connectivity to specified resource.

Above declaration is equivalent to `bosh upload-release https://bosh.io/d/github.com/cloudfoundry/syslog-release?v=11 --sha1 332ac15609b220a3fdf5efad0e0aa069d8235788`.

---
## <a id='git-http'></a> Git over HTTP/HTTPs URLs

```yaml
releases:
- name: syslog
  version: 11
  url: git+https://github.com/cloudfoundry/syslog-release
```

`sha1` key is not required as we rely on Git's HTTP transport mechanism to pull down expected content.

CLI v2 will perform a shallow clone locally and run `upload-release` command from within cloned repository.

Above declaration is equivalent to `bosh upload-release git+https://github.com/cloudfoundry/syslog-release --name syslog --version 11`.
