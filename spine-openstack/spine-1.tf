
resource "openstack_networking_port_v2" "spine-1_ipmi" {
  region                = var.region
  name                  = "spine-1_ipmi"
  network_id            = data.openstack_networking_network_v2.backbone.id
  admin_state_up        = "true"
  security_group_ids    = []
  no_security_groups    = true
  port_security_enabled = false
  fixed_ip {
    subnet_id = var.spine_leaf_openstack.subnets.ipmi.id
    ip_address = cidrhost(cidrsubnet(
      var.ipmi.cidr_prefix,
      var.ipmi.cidr_newbits,
      var.available_region[var.region].offset
      ),
    100)
  }
}

resource "openstack_networking_port_v2" "spine-1_leaf-1" {
  for_each              = var.available_region
  region                = var.region
  name                  = format("spine-1_%s-leaf-1", lower(each.key))
  description           = format("spine-1 to %s-leaf-1", lower(each.key))
  network_id            = data.openstack_networking_network_v2.backbone.id
  admin_state_up        = "true"
  security_group_ids    = []
  no_security_groups    = true
  port_security_enabled = false
  fixed_ip {
    subnet_id = var.spine_leaf_openstack.subnets.spine-1_leaf-1[each.key].id
    ip_address = cidrhost(var.spine_leaf_openstack.subnets.spine-1_leaf-1[each.key].cidr, 1)
  }
}

resource "openstack_networking_port_v2" "spine-1_leaf-2" {
  for_each              = var.available_region
  region                = var.region
  name                  = format("spine-1_%s-leaf-2", lower(each.key))
  description           = format("spine-1 to %s-leaf-2", lower(each.key))
  network_id            = data.openstack_networking_network_v2.backbone.id
  admin_state_up        = "true"
  security_group_ids    = []
  no_security_groups    = true
  port_security_enabled = false
  fixed_ip {
    subnet_id = var.spine_leaf_openstack.subnets.spine-1_leaf-2[each.key].id
    ip_address = cidrhost(var.spine_leaf_openstack.subnets.spine-1_leaf-2[each.key].cidr, 1)
  }
}

resource "openstack_compute_instance_v2" "spine-1" {
  region      = var.region
  name        = format("%s-spine-1", lower(var.region))
  image_name  = var.vyos_image_name
  flavor_name = var.flavor
  #  key_pair        = "INFRA"
  security_groups = []

  user_data = templatefile("templates/vyos.tpl", {
    admin_username = local.vyos.spine.admin_username
    admin_password = local.vyos.spine.admin_password
    api_key        = local.vyos.spine.api_key
  })

  scheduler_hints {
    group = var.spine_leaf_openstack.compute_servergroup.id
  }

  // IPMI
  network {
    #name           = "ipmi"
    port = openstack_networking_port_v2.spine-1_ipmi.id
  }

  // ebgp neighbors spine-1 from all availables regions
  dynamic "network" {
    for_each = var.available_region
    content {
      port = openstack_networking_port_v2.spine-1_leaf-1[network.key].id
    }
  }

  dynamic "network" {
    for_each = var.available_region
    content {
      port = openstack_networking_port_v2.spine-1_leaf-2[network.key].id
    }
  }

  metadata = {
    "ovh-monthly-instance" = var.monthly
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    command = format(<<-EOF
    set -Ee -o pipefail
    for ((i = 0 ; i < 30; ++i)); do
        sleep 2
        nc -zvv %s 11443
        if [ $? -eq 0 ]; then
            exit 0
        fi
    done
    exit 1
    EOF
    , openstack_networking_port_v2.spine-1_ipmi.fixed_ip.0.ip_address)
  }

}

