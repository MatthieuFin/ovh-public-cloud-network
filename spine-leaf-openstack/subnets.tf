resource "openstack_networking_subnet_v2" "ipmi" {
  region      = var.region
  name        = "ipmi"
  no_gateway  = true
  enable_dhcp = true
  network_id  = data.openstack_networking_network_v2.backbone.id
  cidr        = var.ipmi.cidr_prefix
}

resource "openstack_networking_subnet_v2" "leaf-1_leaf-2" {
  region      = var.region
  name        = "leaf-1_leaf-2"
  no_gateway  = true
  enable_dhcp = false
  network_id  = data.openstack_networking_network_v2.backbone.id
  cidr        = cidrsubnet(var.backbone.leafs.ibgp.cidr_prefix, var.backbone.leafs.ibgp.cidr_newbits, var.available_region[var.region].offset)
}

// Internet

resource "openstack_networking_subnet_v2" "leaf_internet" {
  region      = var.region
  name        = "leaf_internet"
  no_gateway  = false
  enable_dhcp = false
  network_id  = data.openstack_networking_network_v2.internet.id
  cidr = cidrsubnet(
    var.backbone.leafs.internet.cidr_prefix,
    var.backbone.leafs.internet.cidr_newbits,
    var.available_region[var.region].offset
  )
}

// spine-1 to available regions leafs 1
resource "openstack_networking_subnet_v2" "spine-1_leaf-1" {
  for_each    = var.available_region
  region      = var.region
  name        = format("%s-spine-1_%s-leaf-1", lower(var.region), lower(each.key))
  no_gateway  = true
  enable_dhcp = false
  network_id  = data.openstack_networking_network_v2.backbone.id
  cidr = cidrsubnet(
    cidrsubnet(var.backbone.leafs.ebgp.cidr_prefix,
      var.backbone.leafs.ebgp.cidr_newbits,
    var.available_region[var.region].offset),
    var.backbone.leafs.ebgp.cidr_bgp_session_newbits,
    (each.value.offset * 2) + 0
  )
}

// spine-1 to available regions leafs 2
resource "openstack_networking_subnet_v2" "spine-1_leaf-2" {
  for_each    = var.available_region
  region      = var.region
  name        = format("%s-spine-1_%s-leaf-2", lower(var.region), lower(each.key))
  no_gateway  = true
  enable_dhcp = false
  network_id  = data.openstack_networking_network_v2.backbone.id
  cidr = cidrsubnet(
    cidrsubnet(var.backbone.leafs.ebgp.cidr_prefix,
      var.backbone.leafs.ebgp.cidr_newbits,
    var.available_region[var.region].offset),
    var.backbone.leafs.ebgp.cidr_bgp_session_newbits,
    (each.value.offset * 2) + 1
  )
}

// leaf-1 to available regions spine-1 except mine
resource "openstack_networking_subnet_v2" "leaf-1_spine-1" {
  for_each = {
    for name, data in var.available_region : name => data
    if name != var.region
  }
  region      = var.region
  name        = format("%s-leaf-1_%s-spine-1", lower(var.region), lower(each.key))
  no_gateway  = true
  enable_dhcp = false
  network_id  = data.openstack_networking_network_v2.backbone.id
  cidr = cidrsubnet(
    cidrsubnet(var.backbone.leafs.ebgp.cidr_prefix,
      var.backbone.leafs.ebgp.cidr_newbits,
    var.available_region[each.key].offset),
    var.backbone.leafs.ebgp.cidr_bgp_session_newbits,
    (var.available_region[var.region].offset * 2) + 0
  )
}

// leaf-2 to available regions spine-1 except mine
resource "openstack_networking_subnet_v2" "leaf-2_spine-1" {
  for_each = {
    for name, data in var.available_region : name => data
    if name != var.region
  }
  region      = var.region
  name        = format("%s-leaf-2_%s-spine-1", lower(var.region), lower(each.key))
  no_gateway  = true
  enable_dhcp = false
  network_id  = data.openstack_networking_network_v2.backbone.id
  cidr = cidrsubnet(
    cidrsubnet(var.backbone.leafs.ebgp.cidr_prefix,
      var.backbone.leafs.ebgp.cidr_newbits,
    var.available_region[each.key].offset),
    var.backbone.leafs.ebgp.cidr_bgp_session_newbits,
    (var.available_region[var.region].offset * 2) + 1
  )
}





