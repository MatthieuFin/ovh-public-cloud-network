module "gra9-openstack" {
  source = "./spine-leaf-openstack"
  providers = {
    openstack    = openstack.PC1
  }
  region                = "GRA9"
  servergroup_name = "vm-group-spine-leaf"
  servergroup_policy = "anti-affinity"
  available_region = var.available_region
  ext-net = "Ext-Net"
  ipmi = var.ipmi
  backbone = var.backbone
}

module "gra9-openstack-spine-1" {
  source = "./spine-openstack"
  depends_on = [
    module.gra9-openstack
  ]
  providers = {
    openstack    = openstack.PC1
  }
  monthly               = false
  region                = "GRA9"
  flavor      = "b2-7"

  spine_leaf_openstack = module.gra9-openstack

  vyos_username_spine  = var.vyos_username
  vyos_password_spine  = var.vyos_password_gra9_spine_1
  vyos_api_key_spine   = var.vyos_api_key_gra9_spine_1

  vyos_image_name = var.vyos_image_name
  available_region = var.available_region
  ipmi = var.ipmi
}

module "gra9-vyos-spine-1" {
  source     = "./spine-vyos"
  depends_on = [
    module.gra9-openstack,
    module.gra9-openstack-spine-1
  ]
  providers = {
    vyos.spine  = vyos.gra9-spine-1
  }
  region               = "GRA9"
  bgp_as_spines = var.bgp_as_spines
  available_region = var.available_region
  backbone = var.backbone
}

module "gra9-openstack-leaf-1" {
  source = "./leaf-openstack"
  depends_on = [
    module.gra9-openstack
  ]
  providers = {
    openstack    = openstack.PC1
  }
  leaf_number = 1
  monthly               = false
  region                = "GRA9"
  flavor      = "b2-7"
  ipmi = var.ipmi
  vyos_image_name = var.vyos_image_name

  spine_leaf_openstack = module.gra9-openstack

  vyos_username_leaf  = var.vyos_username
  vyos_password_leaf  = var.vyos_password_gra9_leaf_1
  vyos_api_key_leaf   = var.vyos_api_key_gra9_leaf_1

  tenant_network = var.tenant_network
  available_region = var.available_region
}

module "gra9-vyos-leaf-1" {
  source     = "./leaf-vyos"
  depends_on = [
    module.gra9-openstack,
    module.gra9-openstack-leaf-1
  ]
  providers = {
    openstack    = openstack.PC1
    vyos.leaf  = vyos.gra9-leaf-1
  }
  region               = "GRA9"
  ipmi = var.ipmi
  bgp_as_spines = var.bgp_as_spines
  backbone = var.backbone
  available_region = var.available_region

  leaf_openstack = module.gra9-openstack-leaf-1

  vyos_api_key_leaf  = var.vyos_api_key_gra9_leaf_1

  tenant_network = var.tenant_network
  leafs_additionnal_tenant_peers = var.leafs_additionnal_tenant_peers["GRA9"]
}


module "gra9-openstack-leaf-2" {
  source = "./leaf-openstack"
  depends_on = [
    module.gra9-openstack,
    module.gra9-openstack-leaf-1,
    module.gra9-vyos-leaf-1
  ]
  providers = {
    openstack    = openstack.PC1
  }
  leaf_number = 2
  monthly               = false
  region                = "GRA9"
  flavor      = "b2-7"
  ipmi = var.ipmi
  vyos_image_name = var.vyos_image_name

  spine_leaf_openstack = module.gra9-openstack

  vyos_username_leaf  = var.vyos_username
  vyos_password_leaf  = var.vyos_password_gra9_leaf_2
  vyos_api_key_leaf   = var.vyos_api_key_gra9_leaf_2

  tenant_network = var.tenant_network
  available_region = var.available_region
}

module "gra9-vyos-leaf-2" {
  source     = "./leaf-vyos"
  depends_on = [
    module.gra9-openstack-leaf-2
  ]
  providers = {
    openstack    = openstack.PC1
    vyos.leaf  = vyos.gra9-leaf-2
  }
  region               = "GRA9"
  ipmi = var.ipmi
  bgp_as_spines = var.bgp_as_spines
  backbone = var.backbone
  available_region = var.available_region

  leaf_openstack = module.gra9-openstack-leaf-2

  vyos_api_key_leaf  = var.vyos_api_key_gra9_leaf_2

  tenant_network = var.tenant_network
  leafs_additionnal_tenant_peers = var.leafs_additionnal_tenant_peers["GRA9"]
}

