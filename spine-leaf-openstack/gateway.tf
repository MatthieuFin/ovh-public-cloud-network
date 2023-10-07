
// Gateway-1 for leafs

resource "openstack_networking_port_v2" "gateway-1_internet" {
  region         = var.region
  name           = "gateway-1_internet"
  network_id     = data.openstack_networking_network_v2.internet.id
  admin_state_up = "true"
  #security_group_ids    = ["default"]
  #no_security_groups    = false
  #port_security_enabled = true
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.leaf_internet.id
    ip_address = cidrhost(openstack_networking_subnet_v2.leaf_internet.cidr, 1)
  }
}

resource "openstack_networking_router_v2" "router-internet-gw-1" {
  region              = var.region
  name                = "router-internet-1-snat"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.ext-net.id
  #  enable_snat = true
}

resource "openstack_networking_router_interface_v2" "gateway-1_internet" {
  region    = var.region
  router_id = openstack_networking_router_v2.router-internet-gw-1.id
  port_id   = openstack_networking_port_v2.gateway-1_internet.id
}

