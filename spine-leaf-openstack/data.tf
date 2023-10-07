data "openstack_networking_network_v2" "backbone" {
  region = var.region
  name   = "backbone"
}

data "openstack_networking_network_v2" "internet" {
  region = var.region
  name   = "internet"
}

data "openstack_networking_network_v2" "ext-net" {
  region = var.region
  name   = var.ext-net
}

