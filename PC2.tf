
// Private network create via ovh provider
data "openstack_networking_network_v2" "ntwk2" {
  depends_on = [ovh_cloud_project_network_private.vlan-ntwk2]
  for_each   = var.available_region
  region     = each.key
  provider   = openstack.PC2
  name       = "ntwk2"
}

resource "openstack_networking_subnet_v2" "ntwk2" {
  for_each    = var.available_region
  region      = each.key
  provider    = openstack.PC2
  name        = "ntwk2"
  description = "tenant network ntwk2"
  network_id  = data.openstack_networking_network_v2.ntwk2[each.key].id
  cidr        = var.tenant_network["ntwk2"].cidr
  allocation_pool {
    # avoid 0 host, ip 1 is for router gw interface, so start at ip 10 to keep space
    start = cidrhost(cidrsubnet(var.tenant_network["ntwk2"].cidr, var.tenant_network["ntwk2"].cidr_newbits, each.value.offset), 10)
    end   = cidrhost(cidrsubnet(var.tenant_network["ntwk2"].cidr, var.tenant_network["ntwk2"].cidr_newbits, each.value.offset), -1)
  }
  enable_dhcp     = true
  gateway_ip      = cidrhost(cidrsubnet(var.tenant_network["ntwk2"].cidr, var.tenant_network["ntwk2"].cidr_newbits, each.value.offset), 1)
  dns_nameservers = ["8.8.8.8", "1.1.1.1"]
}


