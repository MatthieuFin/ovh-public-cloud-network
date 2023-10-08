
// Tenants networks

// Create network ntwk1 vlan 1100 on each cloud project tenants
resource "ovh_cloud_project_network_private" "vlan-ntwk1" {
  for_each     = var.cloud_projects
  service_name = each.value
  vlan_id      = 2100
  name         = "ntwk1"
}


// Create network ntwk2 vlan 1200 on each cloud project tenants
resource "ovh_cloud_project_network_private" "vlan-ntwk2" {
  for_each     = var.cloud_projects
  service_name = each.value
  vlan_id      = 2200
  name         = "ntwk2"
}




// Backbone

// Creating Network backbone in PC1 tenant it shouldn't be created on other projetcs
resource "ovh_cloud_project_network_private" "vlan-backbone_PC1" {
  service_name = var.cloud_projects.PC1
  vlan_id      = 2000
  name         = "backbone"
}

// Internet

// internet network only used by leafs for snat so only create on project "backbone" (PC1 here)
resource "ovh_cloud_project_network_private" "vlan-internet_PC1" {
  service_name = var.cloud_projects.PC1
  vlan_id      = 2001
  name         = "internet"
}





