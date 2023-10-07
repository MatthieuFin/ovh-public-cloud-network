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

