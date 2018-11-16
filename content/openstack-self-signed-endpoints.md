!!! note
    This feature is available with bosh-openstack-cpi v23+.

When your OpenStack is using a self-signed certificate, you want to enable the OpenStack CPI to validate it. You can configure the OpenStack CPI with the public certificate of the RootCA that signed the OpenStack endpoint certificate.

1. Configure `properties.openstack.connection_options` to include the property `ca_cert`. It can contain one or more certificates.

    ```yaml
    properties:
      openstack:
        connection_options:
          ca_cert: |+
            -----BEGIN CERTIFICATE-----
            MII...
            -----END CERTIFICATE-----
    ```

1. Set the `registry.endpoint` configuration to [include basic auth credentials](openstack-registry.md)

1. Deploy the Director
