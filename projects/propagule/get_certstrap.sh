#!/usr/bin/env bash

set -euo pipefail

source scripts/_header.sh

certurl="https://github.com/square/certstrap/releases/download/v1.3.0/"

if command -v certstrap &> /dev/null; then
    error "certstrap was found. skipping installation"
fi

if [ -f certstrap ]; then
    error "certstrap was found. skipping installation"
fi


case $os in
'Darwin x86_64')
    certbin=certstrap-darwin-amd64
    ;;
'Linux x86_64')
    certbin=certstrap-linux-amd64
    ;;
  * )
    error "Unsupported OS: $os"
    ;;
esac

info "Downloading certstrap..."
curl -sL "${certurl}${certbin}" -o certstrap
chmod +x certstrap
