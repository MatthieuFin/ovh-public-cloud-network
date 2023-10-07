locals {
  vyos = {
    "leaf" = {
      endpoint       = format("https://%s:11443", var.leaf_openstack.ports.ipmi.fixed_ip.0.ip_address)
      api_key        = var.vyos_api_key_leaf
    }
  }
}
