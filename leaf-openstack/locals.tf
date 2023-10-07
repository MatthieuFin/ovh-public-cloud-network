locals {
  vyos = {
    "leaf" = {
      #endpoint       = format("https://%s:11443", openstack_networking_port_v2.leaf_ipmi.fixed_ip.0.ip_address)
      endpoint       = format("https://%s:11443", "plop")
      admin_username = var.vyos_username_leaf
      admin_password = var.vyos_password_leaf
      api_key        = var.vyos_api_key_leaf
    }
  }
}
