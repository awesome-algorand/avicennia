# 🌱 Avicennia Germinans
<a href="https://algokit.io"><img src="https://img.shields.io/badge/Built%20with-algokit-teal.svg"/></a>
[![GitHub license](https://img.shields.io/github/license/awesome-algorand/avicennia)]()

> [!CAUTION]
> This project is not intended for production use. Use at your own risk.

Extending on the work of Hashicorp's Vault PKI backend, this project aims to provide a Root CA, Intermediary CA and End Entity Certificates for Algorand Blockchain. The Root CA is self-signed and the Intermediary CA is signed by the Root CA. The End Entity Certificates are signed by the Intermediary CA.

## 🎉 Getting Started

Bootstrap all of the project dependencies by running the following command:

```bash
algokit boostrap all
algokit project run build
```

## 🏗️ Class Diagram
```mermaid
classDiagram
  CertificateAuthority "1" --o "1" Certificate : Owns
  CertificateAuthority "1" --o "1" Metrics : Provides

  class CertificateAuthority {
    <<interface>>
    +String name
    +String revokation_list
    +Certificate cert
    +Metrics metrics

    -initialize(String) bool
    +sign(SigningRequest) bool
    +revoke(String) bool
    +renew(String) bool
  }

  Germinans "1" --> "*" Propagule : Produces
  Germinans <|-- CertificateAuthority : Implements
  class Germinans {
    +String guid
  }

  Propagule <|-- CertificateAuthority : Implements
  class Propagule {
    +int root
  }

  Validator <|-- CertificateAuthority : Implements
  Propagule "1" --> "*" Validator : Produces
  Validator "1" --> "*" Certificate : Produces

  class Validator {
    +int root
  }
  class Certificate{
    +String public
    -String private
  }
  class Metrics{
    requests: UInt64
    issued: UInt64
    revoked: UInt64
  }
```
