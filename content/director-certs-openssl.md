Depending on you configuration, there are up to three endpoints to be secured using SSL certificates: The Director, the UAA, and the SAML Service Provider on the UAA.

!!! note
    If you are using the UAA for user management, an SSL certificate is mandatory for the Director and the UAA.

!!! note
    Unless you are using a configuration server, your SSL certificates will be stored in the Director's database.

## Generate SSL certificates (with OpenSSL) {: #generate }

You can use the following script to generate a root CA certificate and use it to sign three generated SSL certificates:

```bash
#!/bin/bash

set -e

certs=`dirname $0`/certs

rm -rf $certs && mkdir -p $certs

cd $certs

echo "Generating CA..."
openssl genrsa -out rootCA.key 2048
yes "" | openssl req -x509 -new -nodes -key rootCA.key \
  -out rootCA.pem -days 99999

function generateCert {
  name=$1
  ip=$2

  cat >openssl-exts.conf <<-EOL
extensions = san
[san]
subjectAltName = IP:${ip}
EOL

  echo "Generating private key..."
  openssl genrsa -out ${name}.key 2048

  echo "Generating certificate signing request for ${ip}..."
  # golang requires to have SAN for the IP
  openssl req -new -nodes -key ${name}.key \
    -out ${name}.csr \
    -subj "/C=US/O=BOSH/CN=${ip}"

  echo "Generating certificate ${ip}..."
  openssl x509 -req -in ${name}.csr \
    -CA rootCA.pem -CAkey rootCA.key -CAcreateserial \
    -out ${name}.crt -days 99999 \
    -extfile ./openssl-exts.conf

  echo "Deleting certificate signing request and config..."
  rm ${name}.csr
  rm ./openssl-exts.conf
}

generateCert director 10.244.4.2 # <--- Replace with public Director IP
generateCert uaa-web 10.244.4.2  # <--- Replace with public Director IP
generateCert uaa-sp 10.244.4.2   # <--- Replace with public Director IP

echo "Finished..."
ls -la .
```

---
## Configure the Director to use certificates {: #configure }

Update the Director deployment manifest:

- `director.ssl.key`
    - Private key for the Director (e.g. content of `certs/director.key`)
- `director.ssl.cert`
    - Associated certificate for the Director (e.g. content of `certs/director.crt`)
    - Include all intermediate certificates if necessary
- `hm.director_account.ca_cert`
    - CA certificate used by the HM to verify the Director's certificate (e.g. content of `certs/rootCA.pem`)

Example manifest excerpt:

```yaml
...
jobs:
- name: bosh
  properties:
    director:
      ssl:
        key: |
          -----BEGIN RSA PRIVATE KEY-----
          MII...
          -----END RSA PRIVATE KEY-----
        cert: |
          -----BEGIN CERTIFICATE-----
          MII...
          -----END CERTIFICATE-----
...
```

!!! note
    A `path` to the key or certificate file is not supported.

If you are using the UAA for user management, additionally put certificates in these properties:

- `uaa.sslPrivateKey`
    - Private key for the UAA (e.g. content of `certs/uaa-web.key`)
- `uaa.sslCertificate`
    - Associated certificate for the UAA (e.g. content of `certs/uaa-web.crt`)
    - Include all intermediate certificates if necessary
- `login.saml.serviceProviderKey`
    - Private key for the UAA (e.g. content of `certs/uaa-sp.key`)
- `login.saml.serviceProviderCertificate`
    - Associated certificate for the UAA (e.g. content of `certs/uaa-sp.crt`)

---
## Target the Director {: #target }

After you deployed your Director with the above changes, you need to specify `--ca-cert` when targeting the Director:

```shell
$ bosh --ca-cert certs/rootCA.pem target 10.244.4.2
```

!!! note
    If your certificates are trusted via system installed CA certificates, there is no need to provide `--ca-cert` option.
