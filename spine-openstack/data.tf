data "openstack_networking_network_v2" "backbone" {
  region = var.region
  name   = "backbone"
}
