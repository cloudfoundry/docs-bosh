---
title: Link Properties
---

(See [Links](links.html) for an introduction.)

<p class="note">Note: This feature is available with bosh-release v255.5+.</p>

In addition to sharing basic networking information (name, AZ, IP, etc.) links allow to show arbitrary information via properties. Most common example is sharing a port value. From our previous example here is a `web` job that communicates with a database:

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

Here is an example Postgres job that provides a `conn` link of type `db`, and now also includes server's port for client connections:

```yaml
name: postgres

templates: {...}

provides:
- name: conn
  type: db
  properties:
  - port
  - adapter
  - username
  - password
  - name

properties:
  port:
    description: "Port for Postgres to listen on"
    default: 5432
  adapter:
    description: "Type of this database"
    default: postgres
  username:
    description: "Username"
    default: postgres
  password:
    description: "Password"
  name:
    description: "Database name"
    default: postgres
```

Note that all properties included in the `conn` link are defined by the job itself in the `properties` section.

And finally `web` job can use the port and a few other properties in its ERB templates when configuring how to connect to the database:

```ruby
<%%=

db = link("primary_db")

result = {
  "production" => {
    "adapter" => db.p("adapter"),
    "username" => db.p("username"),
    "password" => db.p("password"),
    "host" => db.instances.first.address,
    "port" => db.p("port"),
    "database" => db.p("name"),
    "encoding" => "utf8",
    "reconnect" => false,
    "pool" => 5
  }
}

JSON.dump(result)

%>
```

Similarly to how [`p` template accessor](jobs.html#properties) provides access to the job's top level properties, `link("...").p("...)` and `link("...").if_p("...)` accessors work with properties included in the link.

`if_p` template accessor becomes very useful when trying to provide backwards compatibility around link properties as their interface changes. For example if Postgres job author decides to start including `encoding` property in the link and `web` job's author wants to continue to support older links that don't include that information, they can use `db.if_p("encoding") { ... }`.

And finally in the above example the operator needs to configure database password to deploy these two jobs since password property doesn't have a default:

```yaml
instance_groups:
- name: app
  jobs:
  - name: web
    release: my-app
    consumes:
      primary_db: {from: data_db}

- name: data_db
  jobs:
  - name: postgres
    release: postgres
    provides:
      conn: {as: data_db}
    properties:
      password: some-password
```

---
Next: [Manual linking](links-manual.html)

[Back to Table of Contents](index.html#deployment-config)
