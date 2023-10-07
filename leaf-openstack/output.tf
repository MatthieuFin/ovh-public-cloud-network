
output "ports" {
    value = {
        ipmi = openstack_networking_port_v2.leaf_ipmi
    }
}

output "leaf_number" {
  value = var.leaf_number
}