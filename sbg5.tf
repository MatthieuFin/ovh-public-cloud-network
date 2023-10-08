module "sbg5-openstack" {
  source = "./spine-leaf-openstack"
  providers = {
    openstack = openstack.PC1
  }
  region             = "SBG5"
  servergroup_name   = "vm-group-spine-leaf"
  servergroup_policy = "anti-affinity"
  available_region   = var.available_region
  ext-net            = "Ext-Net"
  ipmi               = var.ipmi
  backbone           = var.backbone
}

module "sbg5-openstack-spine-1" {
  source = "./spine-openstack"
  depends_on = [
    module.sbg5-openstack
  ]
  providers = {
    openstack = openstack.PC1
  }
  monthly = false
  region  = "SBG5"
  flavor  = "b2-7"

  spine_leaf_openstack = module.sbg5-openstack

  vyos_username_spine = var.vyos_username
  vyos_password_spine = var.vyos_password_sbg5_spine_1
  vyos_api_key_spine  = var.vyos_api_key_sbg5_spine_1

  vyos_image_name  = var.vyos_image_name
  available_region = var.available_region
  ipmi             = var.ipmi
}

module "sbg5-vyos-spine-1" {
  source = "./spine-vyos"
  depends_on = [
    module.sbg5-openstack,
    module.sbg5-openstack-spine-1
  ]
  providers = {
    vyos.spine = vyos.sbg5-spine-1
  }
  region           = "SBG5"
  bgp_as_spines    = var.bgp_as_spines
  available_region = var.available_region
  backbone         = var.backbone
}

module "sbg5-openstack-leaf-1" {
  source = "./leaf-openstack"
  depends_on = [
    module.sbg5-openstack
  ]
  providers = {
    openstack = openstack.PC1
  }
  leaf_number     = 1
  monthly         = false
  region          = "SBG5"
  flavor          = "b2-7"
  ipmi            = var.ipmi
  vyos_image_name = var.vyos_image_name

  spine_leaf_openstack = module.sbg5-openstack

  vyos_username_leaf = var.vyos_username
  vyos_password_leaf = var.vyos_password_sbg5_leaf_1
  vyos_api_key_leaf  = var.vyos_api_key_sbg5_leaf_1

  tenant_network   = var.tenant_network
  available_region = var.available_region
}

module "sbg5-vyos-leaf-1" {
  source = "./leaf-vyos"
  depends_on = [
    module.sbg5-openstack,
    module.sbg5-openstack-leaf-1
  ]
  providers = {
    openstack = openstack.PC1
    vyos.leaf = vyos.sbg5-leaf-1
  }
  region           = "SBG5"
  ipmi             = var.ipmi
  bgp_as_spines    = var.bgp_as_spines
  backbone         = var.backbone
  available_region = var.available_region

  leaf_openstack = module.sbg5-openstack-leaf-1

  vyos_api_key_leaf = var.vyos_api_key_sbg5_leaf_1

  tenant_network                 = var.tenant_network
  leafs_additionnal_tenant_peers = var.leafs_additionnal_tenant_peers["SBG5"]
}


module "sbg5-openstack-leaf-2" {
  source = "./leaf-openstack"
  depends_on = [
    module.sbg5-openstack,
    module.sbg5-openstack-leaf-1,
    module.sbg5-vyos-leaf-1
  ]
  providers = {
    openstack = openstack.PC1
  }
  leaf_number     = 2
  monthly         = false
  region          = "SBG5"
  flavor          = "b2-7"
  ipmi            = var.ipmi
  vyos_image_name = var.vyos_image_name

  spine_leaf_openstack = module.sbg5-openstack

  vyos_username_leaf = var.vyos_username
  vyos_password_leaf = var.vyos_password_sbg5_leaf_2
  vyos_api_key_leaf  = var.vyos_api_key_sbg5_leaf_2

  tenant_network   = var.tenant_network
  available_region = var.available_region
}

module "sbg5-vyos-leaf-2" {
  source = "./leaf-vyos"
  depends_on = [
    module.sbg5-openstack-leaf-2
  ]
  providers = {
    openstack = openstack.PC1
    vyos.leaf = vyos.sbg5-leaf-2
  }
  region           = "SBG5"
  ipmi             = var.ipmi
  bgp_as_spines    = var.bgp_as_spines
  backbone         = var.backbone
  available_region = var.available_region

  leaf_openstack = module.sbg5-openstack-leaf-2

  vyos_api_key_leaf = var.vyos_api_key_sbg5_leaf_2

  tenant_network                 = var.tenant_network
  leafs_additionnal_tenant_peers = var.leafs_additionnal_tenant_peers["SBG5"]
}

