---
title: Manual Linking
---

(See [Links](links.html) and [Link properties](links-properties.html) for an introduction.)

<p class="note">Note: This feature is available with bosh-release v256+.</p>

For components/endpoints that are not managed by the Director or cannot be linked, operator can explicitly specify full link details in the manifest. This allows release authors to continue exposing a single interface (link) for connecting configuration, instead of exposing adhoc job properties for use when link is not provided.

From our previous example here is a `web` job that communicates with a database:

```yaml
name: web

templates:
  config.erb: config/conf

consumes:
- name: primary_db
  type: db

provides:
- name: incoming
  type: http

properties: {...}
```

And here is how operator can configure `web` job to talk to an RDS instance instead of a Postgres server deployed with BOSH:

```yaml
instance_groups:
- name: app
  jobs:
  - name: web
    release: my-app
    consumes:
      primary_db:
        instances:
        - address: teswfbquts.cabsfabuo7yr.us-east-1.rds.amazonaws.com
        properties:
          port: 3306
          adapter: mysql2
          username: some-username
          password: some-password
          name: my-app
```

---
[Back to Table of Contents](index.html#deployment-config)
