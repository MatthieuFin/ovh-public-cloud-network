
resource "openstack_compute_servergroup_v2" "sg" {
  region      = var.region
  name     = var.servergroup_name
  policies = [var.servergroup_policy]
}

