# 🌰 Propagule

<a href="https://algokit.io"><img src="https://img.shields.io/badge/Built%20with-algokit-teal.svg"/></a>
[![GitHub license](https://img.shields.io/github/license/awesome-algorand/avicennia)]()

> [!CAUTION]
> This project is not intended for production use. Use at your own risk.

This project aims to provide a Validator for the Propagule Certificate Authority.
It is based on Hashicorp's Vault PKI backend and aims to provide a REST/RPC interface for the Certificate Authority.

### Why Propagule?
> A Propagule represent the Intermediary Certificate Authority (IAC).


This project is named after the Propagule, a bud of a plant that is capable of developing into a new individual.
These buds are often found in coastal areas and are capable of growing into a new plant.

### Why a Validator?
> A Validator represents the Intermediary Certificate Authority (IAC2)

A Validator is a trusted entity that issues digital certificate based on the Propagule Certificate Authority.
The validator is responsible for validating Certificate Signing Requests (CSR) and issuing digital certificates.


## 🎉 Getting Started

Bootstrap all the project dependencies by running the following command:

```bash
./bootstrap.sh
```

Navigate to http://localhost:8200 to view the vault UI and Certificate Authority.

## TODO:

- [ ] Investigate the feasibility of a Hashicorp Vault plugin for the Propagule Certificate Authority
- [ ] Define REST/RPC interface for Validator (see certbot for inspiration)
