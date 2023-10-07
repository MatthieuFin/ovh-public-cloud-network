
output "subnets" {
  value = {
    ipmi = openstack_networking_subnet_v2.ipmi
    leaf-1_leaf-2 = openstack_networking_subnet_v2.leaf-1_leaf-2
    spine-1_leaf-1 = openstack_networking_subnet_v2.spine-1_leaf-1
    spine-1_leaf-2 = openstack_networking_subnet_v2.spine-1_leaf-2
    leaf-1_spine-1 = openstack_networking_subnet_v2.leaf-1_spine-1
    leaf-2_spine-1 = openstack_networking_subnet_v2.leaf-2_spine-1
    leaf_internet = openstack_networking_subnet_v2.leaf_internet
  }
}

output "compute_servergroup" {
  value = openstack_compute_servergroup_v2.sg
}

