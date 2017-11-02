---
title: Connecting the Director to an External Postgres Database
---

The Director stores VM, persistent disk and other information in a database. An internal database might be sufficient for your deployment; however, a highly-available external database can improve performance, scalability and protect against data loss.

## <a id="included"></a> Included Postgres (default)

1. Add postgres release job and make sure that persistent disk is enabled:

    ```yaml
    jobs:
    - name: bosh
      templates:
      - {name: postgres, release: bosh}
      # ...
      persistent_disk: 25_000
      # ...
    ```

1. Configure postgres job, and let the Director and the Registry (if configured) use the database:

    ```yaml
    properties:
      postgres: &database
        host: 127.0.0.1
        user: postgres
        password: postgres-password
        database: bosh
        adapter: postgres

      director:
        db: *database
        # ...

      registry:
        db: *database
        # ...
    ```

---
## <a id="external"></a> External

The Director is tested to be compatible with MySQL and Postgresql databases.

1. Modify deployment manifest for the Director

    ```yaml
    properties:
      director:
        db: &database
          host: DB-HOST
          port: DB-PORT
          user: DB-USER
          password: DB-PASSWORD
          database: bosh
          adapter: postgres

      registry:
        db: *database
        # ...
    ```

    See [director.db job configuration](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh#p=director.db) for more details.
