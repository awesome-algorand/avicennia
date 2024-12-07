# 🌱 Avicennia

<a href="https://algokit.io"><img src="https://img.shields.io/badge/Built%20with-algokit-teal.svg"/></a>
[![GitHub license](https://img.shields.io/github/license/awesome-algorand/avicennia)]()


> [!CAUTION]
> This project is not intended for production use. Use at your own risk.
 
Smart contracts library for integrating a Certificate Authority(CA) with the Algorand Blockchain.

## Why Avicennia?

Traditional Public Key Infrastructure(PKI) systems rely on a centralized Certificate Authority(CA) to issue and manage digital certificates. 
This centralization creates a single point of failure and a potential security risk. 
By leveraging the Algorand blockchain, we can create a decentralized PKI system that is more secure and reliable.

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
