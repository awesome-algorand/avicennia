
resource "vault_mount" "validator" {
 path                      = "validator"
 type                      = "pki"
 description               = "An authorized intermediate CA (Validator)"
 default_lease_ttl_seconds = local.default_1hr_in_sec
 max_lease_ttl_seconds     = local.default_1y_in_sec
}

resource "vault_pki_secret_backend_intermediate_cert_request" "validator_ca_csr" {
 depends_on   = [vault_mount.validator]
 backend      = vault_mount.validator.path
 type         = "internal"
 common_name  = "Validator"
 key_type     = "rsa"
 key_bits     = "2048"
 ou           = "Validator"
 organization = "Validator Number One"
 country      = "United States"
 province     = "Maryland"
 locality     = "Chesapeake Bay Watershed"
}

resource "vault_pki_secret_backend_role" "role" {
 backend            = vault_mount.validator.path
 name               = "test-dot-com-subdomain"
 ttl                = local.default_1hr_in_sec
 allow_ip_sans      = true
 key_type           = "ed25519"
 key_bits           = 2048
 key_usage          = [ "DigitalSignature"]
 allow_any_name     = false
 allow_localhost    = false
 allowed_domains    = ["test.com"]
 allow_bare_domains = false
 allow_subdomains   = true
 server_flag        = false
 client_flag        = true
 no_store           = false
 country            = ["US"]
 locality           = ["Bethesda"]
 province           = ["MD"]
}
