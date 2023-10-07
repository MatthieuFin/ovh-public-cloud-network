locals {
  vyos = {
    "spine" = {
      endpoint       = format("https://%s:11443", openstack_networking_port_v2.spine-1_ipmi.fixed_ip.0.ip_address)
      admin_username = var.vyos_username_spine
      admin_password = var.vyos_password_spine
      api_key        = var.vyos_api_key_spine
    }
  }
}
