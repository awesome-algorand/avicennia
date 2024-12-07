
resource "vault_mount" "propagule" {
 path                      = "propagule"
 type                      = "pki"
 description               = "An authorized intermediate CA (Propagule)"
 default_lease_ttl_seconds = local.default_1hr_in_sec
 max_lease_ttl_seconds     = local.default_3y_in_sec
}

resource "vault_pki_secret_backend_intermediate_cert_request" "propagule_ca_csr" {
 depends_on   = [vault_mount.propagule]
 backend      = vault_mount.propagule.path
 type         = "internal"
 common_name  = "Propagule"
 key_type     = "rsa"
 key_bits     = "2048"
 ou           = "Propagule"
 organization = "Propagule Number One"
 country      = "United States"
 province     = "Maryland"
 locality     = "Chesapeak Watershed"

}

