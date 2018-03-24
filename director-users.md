---
title: User management on the Director
---

The Director provides a very simple built-in user management system for authentication of operators and internal services (for example, the Health Monitor). Alternatively, it can integrate with UAA for more advanced use cases.

---
## Default Configuration <a id="default"></a>

<p class="note"><strong>Note</strong>: We are planning to remove this configuration. We recommend configuring the Director as described below in <a href="#preconfigured">Preconfigured Users</a> section.</p>

Once installed, the Director comes without any configured users by default. When there are no configured users you can use `admin` / `admin` credentials to login into the Director.

```shell
$ bosh login admin

Enter password: *****
Logged in as `admin'
```

When the Director is configured with at least one user, default `admin` / `admin` credentials no longer work. To create a new user:

```shell
$ bosh create user some-operator

Enter new password: ********
Verify new password: ********
User `some-operator' has been created
```

To delete existing user:

```shell
$ bosh delete user some-operator

Are you sure you would like to delete the user `some-operator'? (type 'yes' to continue): yes
User `some-operator' has been deleted
```

---
## Preconfigured Users <a id="preconfigured"></a>

<p class="note"><strong>Note</strong>: This feature is available with bosh-release v177+ (1.2999.0).</p>

In this configuration the Director is configured in advance with a list of users. There is no way to add or remove users without redeploying the Director.

To configure the Director with a list of users:

1. Change deployment manifest for the Director:

    ```yaml
    properties:
      director:
        user_management:
          provider: local
          local:
            users:
            - {name: admin, password: admin-password}
            - {name: hm, password: hm-password}
    ```

1. Redeploy the Director with the updated manifest.

---
## UAA Integration <a id="uaa"></a>

[Configure the Director with UAA user management](director-users-uaa.md).

---
## Director Tasks <a id="hm"></a>

When a user initiates a [director task](director-tasks.md), the director logs the user in the task audit log.

---
## Health Monitor Authentication <a id="hm"></a>

The Health Monitor is configured to use a custom user to query/submit requests to the Director. Since by default the Director does not come with any users, the Health Monitor is not able to successfully communicate with the Director. See the [Automatic repair with Resurrector](resurrector.md) topic for more details.

---
[Back to Table of Contents](index.md#director-config)
