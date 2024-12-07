#!/usr/bin/env bash

set -euo pipefail

source scripts/_header.sh

info "Checking for required tools..."

if ! command -v docker &> /dev/null; then
    error "Docker required but not found. Please install Docker and try again."
fi

if ! command -v docker compose &> /dev/null; then
    error "Docker Compose v2 required but not found. Please install Docker Compose v2 and try again."
fi

if ! command -v openssl &> /dev/null; then
    error "openssl required but not found. Please install openssl and try again."
fi

if ! command -v tofu &> /dev/null; then
    error "tofu required but not found. Please install tofu and try again."
fi

if ! command -v jq &> /dev/null; then
    error "jq required but not found. Please install jq and try again."
fi

if ! command -v vault &> /dev/null; then
    error "vault required but not found. Please install vault and try again."
fi

if ! [ -f certstrap ]; then
    error "certstrap required but not found. Please install certstrap and try again."
fi

success "All required tools found."

info "Starting the Docker containers..."
docker compose up -d
while ! nc -z localhost 8200; do
  sleep 0.5
done

#################### GENERATE ROOT CA ####################

root_name="Germinans"
# Generate the offline root CA if it doesn't exist
if [ ! -f "certs/${root_name}.key" ]; then
    info "Generating root CA..."
    # TODO: Handle certificates in a clever way
    ./certstrap --depot-path certs init \
        --passphrase "" \
        --organization "RootCA" \
        --organizational-unit "Algorand" \
        --country "United States" \
        --province "Maryland" \
        --locality "Chesapeake Bay Watershed" \
        --common-name "${root_name}" \
        --curve Ed25519
    else
        warn "Root CA already exists. Skipping generation."
fi

info "$(openssl x509 -in certs/$root_name.crt -noout  -subject -issuer)"


#################### TOFU INIT AND APPLY ####################

if [ ! -d .terraform ]; then
    info "Initializing Tofu..."
    tofu init
    else
        warn "Tofu already initialized. Skipping."
fi

info "Applying the Terraform configuration..."
tofu apply -auto-approve


#################### SIGN INTERMEDIATE CA CSR ####################

intermediate_name="Propagule"
if [ ! -f "certs/${intermediate_name}.crt" ]; then
    info "Generating Intermediate CA1..."
    if [ ! -f "csr/${intermediate_name}.csr" ]; then
        info "Generating CSR for ${intermediate_name}..."
        mkdir -p csr
        tofu show -json | jq '.values["root_module"]["resources"][2].values.csr' -r | grep -v null > "csr/${intermediate_name}.csr"
        else
            warn "CSR already exists. Skipping generation."
    fi
    info "Signing the CSR..."
    ./certstrap --depot-path certs sign \
         --expires "3 year" \
         --csr "csr/${intermediate_name}.csr" \
         --cert "certs/${intermediate_name}.crt" \
         --intermediate \
         --path-length "1" \
         --CA "${root_name}" \
         "${intermediate_name}"
fi
mkdir -p cacerts
cat certs/${intermediate_name}.crt certs/${root_name}.crt > cacerts/${intermediate_name}.crt

#################### Update Terraform Configuration ####################

info "Applying the Terraform configuration..."
tofu apply -auto-approve

cat > install.tf <<EOF

resource "vault_pki_secret_backend_intermediate_set_signed" "propagule_ca_csr_signed_cert" {
  depends_on   = [vault_mount.propagule]
  backend      = vault_mount.propagule.path

  certificate = file("\${path.module}/cacerts/Propagule.crt")
}
resource "vault_pki_secret_backend_root_sign_intermediate" "validator_ca_csr_signed_by_propagule" {
  depends_on = [
    vault_mount.propagule,
    vault_pki_secret_backend_intermediate_cert_request.validator_ca_csr,
    vault_pki_secret_backend_intermediate_set_signed.propagule_ca_csr_signed_cert
  ]
  backend              = vault_mount.propagule.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.validator_ca_csr.csr
  exclude_cn_from_sans = true
  max_path_length      = 1
  ttl                  = local.default_1y_in_sec
  use_csr_values = true
  common_name         = "Validator"
}
resource "vault_pki_secret_backend_intermediate_set_signed" "validator_signed_cert" {
 depends_on  = [vault_pki_secret_backend_root_sign_intermediate.validator_ca_csr_signed_by_propagule]
 backend     = vault_mount.validator.path
 certificate = format("%s\n%s", vault_pki_secret_backend_root_sign_intermediate.validator_ca_csr_signed_by_propagule.certificate, file("\${path.module}/cacerts/Propagule.crt"))
}

EOF

info "Applying the Terraform configuration..."
tofu apply -auto-approve


info "Issuing certificates..."
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root
vault write -format=json validator/issue/test-dot-com-subdomain    common_name=1.test.com | jq .data.certificate -r | openssl x509 -in /dev/stdin -text -noout
