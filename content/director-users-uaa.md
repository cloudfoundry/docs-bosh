!!! note
    This feature is available with bosh-release v209+ (1.3088.0) colocated with uaa v1+.

In this configuration the Director is configured to delegate user management to the [UAA](https://github.com/cloudfoundry/uaa) server. The UAA server can be configured to manage its own list of users or work with an LDAP server, or a SAML provider. Regardless how the UAA server is configured the BOSH CLI will ask appropriate credentials and forward them to the UAA to request a token.

---
## Deploy the Director with UAA {: #configure }

1. Change deployment manifest for the Director and add UAA release:

    ```yaml
    releases:
    - name: bosh
      url: https://bosh.io/d/github.com/cloudfoundry/bosh?v=209
      sha1: a96833b6c68abda5aaa5d05ebdd0a5d394e6c15f
    # ...
    - name: uaa # <---
      url: https://bosh.io/d/github.com/cloudfoundry/uaa-release?v=24
      sha1: d0feb5494153217f3d62b346f426ad2b2f43511a
    ```

1. Colocate UAA next to the Director:

    ```yaml
    jobs:
    - name: bosh
      instances: 1
      templates:
      - {name: nats, release: bosh}
      - {name: redis, release: bosh}
      - {name: postgres, release: bosh}
      - {name: blobstore, release: bosh}
      - {name: director, release: bosh}
      - {name: health_monitor, release: bosh}
      - {name: uaa, release: uaa} # <---
      resource_pool: default
      # ...
    ```

1. Add `uaa` section to the deployment manifest:

    ```yaml
    properties:
      uaa:
        url: "https://54.236.100.56:8443"

        scim:
          users:
          - name: admin
            # password: admin-password # <--- Uncomment & change
            groups:
            - scim.write
            - scim.read
            - bosh.admin

        clients:
          bosh_cli:
            override: true
            authorized-grant-types: password,refresh_token
            # scopes the client may receive
            scope: openid,bosh.admin,bosh.read,bosh.*.admin,bosh.*.read
            authorities: uaa.none
            access-token-validity: 120 # 2 min
            refresh-token-validity: 86400 # re-login required once a day
            secret: "" # CLI expects this secret to be empty

        admin:
          # client_secret: admin-password # <--- Uncomment & change
        login:
          # client_secret: login-password # <--- Uncomment & change
        zones: {internal: {hostnames: []}}
    ```

    !!! note
        Make sure UAA URL corresponds to the Director and UAA certificate subjects.

    To configure UAA to use LDAP, SAML, etc. see [uaa release job properties](https://bosh.io/jobs/uaa?source=github.com/cloudfoundry/uaa-release).

1. Configure the Director Postgres server to have an additional database called `uaa`:

    ```yaml
    properties:
      postgres: &db
        host: 127.0.0.1
        port: 5432
        user: postgres
        # password: postgres-password # <--- Uncomment & change
        database: bosh
        additional_databases: [uaa] # <---
        adapter: postgres
    ```

    !!! note
        If you are using externally configured database, you should skip this section.

1. Configure the UAA server to point to that database:

    ```yaml
    properties:
      uaadb:
        address: 127.0.0.1
        port: 5432
        db_scheme: postgresql
        databases:
        - {tag: uaa, name: uaa}
        roles:
        - tag: admin
          name: postgres
          # password: postgres-password # <--- Uncomment & change
    ```

1. Change Director configuration to specify how to contact the UAA server and how to verify an access token. Since UAA will be on the same server we can use the same IP as the one used for the Director.

    ```yaml
    properties:
      director:
        user_management:
          provider: uaa
          uaa:
            url: "https://54.236.100.56:8443"
    ```

    !!! note
        The UAA URL given to the Director will be advertised to the CLI and the CLI will use it to ask for an access token. This means that the CLI must be able to reach that IP.

    !!! note
        Make sure UAA URL corresponds to the UAA certificate subject.

1. Configure Certificates and Keys

    See [Director certificates configuration doc](director-certs.md) to find out how to generate necessary certificates.
    Note, however, that `login.saml.serviceProviderKeyPassword` may need to be set to `""`, [see UAA v24 release notes](https://bosh.io/releases/github.com/cloudfoundry/uaa-release?version=24).

    To generate UAA signing (private key) and verification key (public key) in PEM format:

    ```shell
    $ ssh-keygen -t rsa -b 4096 -f uaa
    $ openssl rsa -in uaa -pubout > uaa.pub
    ```

    Put the keys in the Director deployment manifest:
    - `uaa.jwt.signing_key`
        - Private key used to sign authorization tokens (e.g. `./uaa`)
    - `uaa.jwt.verification_key`
        - Public key used to verify tokens (e.g. `./uaa.pub`)
    - `director.user_management.uaa.public_key`
        - Public key used by the Director to verify tokens without contacting the UAA (e.g. `./uaa.pub`)

1. Allow access to port 8443 on the Director VM from your IaaS so that the CLI can access the UAA server.

1. Redeploy the Director with the updated manifest.

