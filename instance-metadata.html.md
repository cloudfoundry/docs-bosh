---
title: Instance Metadata
---

<p class="note">Note: This feature is available with bosh-release v255.4+ and on 3213+ stemcell series.</p>

It's common for software to need to know where it was deployed so that it can make application level decisions or propagate location information in logs and metrics. Director instance specific information in multiple ways:

## <a id="erb"></a> Via ERB templates

Use [`spec` variable](jobs.html#properties-spec) in ERB templates to get access to AZ, deployment name, ID, etc.

## <a id="fs"></a> Via filesystem

Accessing information over filesystem might be useful when building core libraries so that explicit configuration is not required. Each VM has a `/var/vcap/instance` directory that contains following files:

<pre class="terminal">
vcap@7e87e912-35cc-4b43-9645-5a7d7d6f2caa:~$ ls -la /var/vcap/instance/
total 24
drwxr-xr-x  2 root root 4096 Mar 17 00:06 .
drwxr-xr-x 11 root root 4096 Mar 17 00:16 ..
-rw-r--r--  1 root root    2 Mar 17 00:07 az
-rw-r--r--  1 root root   10 Mar 17 00:07 deployment
-rw-r--r--  1 root root   36 Mar 17 00:07 id
-rw-r--r--  1 root root    3 Mar 17 00:07 name
</pre>

Example values:

- AZ: `z1`
- Deployment: `redis`
- ID: `fdfad8ca-a213-4a1c-b1f6-c53f86bb896a`
- Name: `redis`
