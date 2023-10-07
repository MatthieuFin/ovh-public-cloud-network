data "openstack_networking_network_v2" "backbone" {
  region = var.region
  name   = "backbone"
}

data "openstack_networking_network_v2" "internet" {
  region = var.region
  name   = "internet"
}

data "openstack_networking_network_v2" "tenant" {
  for_each = var.tenant_network
  region   = var.region
  name     = each.key
}

data "openstack_networking_subnet_v2" "tenant" {
  for_each = var.tenant_network
  region   = var.region
  name     = each.key
}

