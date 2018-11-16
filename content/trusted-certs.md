!!! note
    This feature is available with bosh-release v176+ (1.2992.0) and stemcells v2992+.

This document describes how to configure the Director to add a set of trusted certificates to all VMs managed by that Director. Configured trusted certificates are added to the default certificate store on each VM and will be automatically seen by the majority of software (e.g. curl).

---
## Configuring Trusted Certificates {: #configure }

To configure the Director with trusted certificates:

1. Change deployment manifest for the Director to include one or more certificates:

    ```yaml
    properties:
      director:
        trusted_certs: |
          # Comments are allowed in between certificate boundaries
          -----BEGIN CERTIFICATE-----
          MIICsjCCAhugAwIBAgIJAMcyGWdRwnFlMA0GCSqGSIb3DQEBBQUAMEUxCzAJBgNV
          BAYTAkFVMRMwEQYDVQQIEwpTb21lLVN0YXRlMSEwHwYDVQQKExhJbnRlcm5ldCBX
          ...
          ItuuqKphqhSb6PEcFMzuVpTbN09ko54cHYIIULrSj3lEkoY9KJ1ONzxKjeGMHrOP
          KS+vQr1+OCpxozj1qdBzvHgCS0DrtA==
          -----END CERTIFICATE-----
          # Some other certificate below
          -----BEGIN CERTIFICATE-----
          MIIB8zCCAVwCCQCLgU6CRfFs5jANBgkqhkiG9w0BAQUFADBFMQswCQYDVQQGEwJB
          VTETMBEGA1UECBMKU29tZS1TdGF0ZTEhMB8GA1UEChMYSW50ZXJuZXQgV2lkZ2l0
          ...
          VhORg7+d5moBrryXFJfeiybtuIEA+1AOwEkdp1MAKBhRZYmeoQXPAieBrCp6l+Ax
          BaLg0R513H6KdlpsIOh6Ywa1r/ID0As=
          -----END CERTIFICATE-----
    ```

1. Redeploy the Director with the updated manifest.

    !!! note
        Currently only VMs managed by the Director will be updated with the trusted certificates. The Director VM will not have trusted certificates installed.

1. Redeploy each deployment to immediately update deployment's VMs with trusted certificates. Otherwise trusted certificate changes will be picked up next time you run `bosh deploy` for that deployment.

    ```shell
    $ bosh deployment ~/deployments/cf-mysql.yml
    $ bosh deploy
    ...

    $ bosh deployment ~/deployments/cf-rabbitmq.yml
    $ bosh deploy
    ...
    ```

### Configuration Format {: #format }

The Director allows to specify one or more certificates concatenated together in the PEM format. Any text before, between and after certificate boundaries is ignored when importing the certificates, but may be useful for leaving notes about the certificate purpose.

Providing multiple certificates makes downtimeless certificate rotation possible; however, it involves redeploying the Director and all deployments twice -- first to add a new certificate and second to remove an old certificate.
