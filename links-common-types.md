---
title: Links - Common types
---

Common suggested link types that release authors should conform to if type is used.

---
## `database` type {: #database }

`link('...').address` returns database address.

* **adapter** [String]: Name of the adapter.
* **port** [Integer]: Port to connect on.
* **tls** [Hash]: See [TLS properties](props-common.md#tls)
* **username** [String]: Database username to use. Example: `u387455`.
* **password** [String]: Database password to use.
* **database** [String]: Database name. Example: `app-server`
* **options** [Hash, optional]: Opaque set of options for the adapter. Example: `{max_connections: 32, pool_timeout: 10}`.

---
## `blobstore` type {: #blobstore }

`link('...').address` returns blobstore address.

* **adapter** [String]: Name of the adapter (s3, gcp, etc.).
* **tls** [Hash]: See [TLS properties](props-common.md#tls)
* **options** [Hash, optional]: Opaque set of options. Example: `{aws_access_key: ..., secret_access_key: ...}`.
