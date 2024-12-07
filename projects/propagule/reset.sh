#!/usr/bin/env bash

set -euo pipefail

source scripts/_header.sh

warn "Deleting all certificates, requests and keys..."
rm -rf cacerts certs csr

warn "Cleaning up tofu..."
rm ./install.tf
tofu apply -auto-approve -destroy

warn "Bringing container down..."
docker compose down


