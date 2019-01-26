# Database

The database is the persistent store used by BOSH for tracking state, configuration, and references to external resources (e.g. blobs or cloud VMs). BOSH uses [Sequel](https://github.com/jeremyevans/sequel) as an ORM in order to support MySQL and PostgreSQL (for production) and SQLite (for development).

By default BOSH includes a PostgreSQL database which can be used, however an external database can be configured as well. Operators will often use services such as [Amazon RDS](https://aws.amazon.com/rds/) or [Google Cloud SQL](https://cloud.google.com/sql/docs/) to provide a hosted database server.


## Additional resources

 * [cloudfoundry/bosh models](https://github.com/cloudfoundry/bosh/tree/master/src/bosh-director/lib/bosh/director/api) - database model-related source code
