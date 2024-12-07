provider "vault" {
  address = "http://127.0.0.1:8200"
  token = "root"
}

locals {
 default_3y_in_sec   = 94608000
 default_1y_in_sec   = 31536000
 default_1hr_in_sec = 3600
}

