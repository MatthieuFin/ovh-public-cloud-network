
resource "openstack_networking_port_v2" "leaf_ipmi" {
  region                = var.region
  name                  = format("leaf-%d_ipmi", var.leaf_number)
  description           = format("leaf-%d ipmi + sync conntrack tables", var.leaf_number)
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
    10 + var.leaf_number)
  }
}

// neighbor port ibgp (leaf-2)

resource "openstack_networking_port_v2" "leaf_leaf" {
  region                = var.region
  name                  = format("leaf-%d_leaf-%d", var.leaf_number, var.leaf_number%2+1)
  description           = format("iBGP leaf-%d to leaf-%d", var.leaf_number, var.leaf_number%2+1)
  network_id            = data.openstack_networking_network_v2.backbone.id
  admin_state_up        = "true"
  security_group_ids    = []
  no_security_groups    = true
  port_security_enabled = false
  fixed_ip {
    subnet_id  = var.spine_leaf_openstack.subnets.leaf-1_leaf-2.id
    ip_address = cidrhost(var.spine_leaf_openstack.subnets.leaf-1_leaf-2.cidr, var.leaf_number)
  }
}

// neighbor ports ebgp

resource "openstack_networking_port_v2" "leaf_spine-1" {
  for_each              = var.available_region
  region                = var.region
  name                  = format("leaf-%d_%s-spine-1", var.leaf_number, lower(each.key))
  description           = format("eBGP leaf-%d to %s-spine-1", var.leaf_number, lower(each.key))
  network_id            = data.openstack_networking_network_v2.backbone.id
  admin_state_up        = "true"
  security_group_ids    = []
  no_security_groups    = true
  port_security_enabled = false
  fixed_ip {
    subnet_id = (each.key == var.region ?
        var.spine_leaf_openstack.subnets[format("spine-1_leaf-%d", var.leaf_number)][each.key].id :
        var.spine_leaf_openstack.subnets[format("leaf-%d_spine-1", var.leaf_number)][each.key].id
    )
    ip_address = (each.key == var.region ?
        cidrhost(var.spine_leaf_openstack.subnets[format("spine-1_leaf-%d", var.leaf_number)][each.key].cidr, 2) :
        cidrhost(var.spine_leaf_openstack.subnets[format("leaf-%d_spine-1", var.leaf_number)][each.key].cidr, 2)
    )
  }
}

// tenants network ports

resource "openstack_networking_port_v2" "leaf_ntwk-tenant" {
  for_each              = var.tenant_network
  region                = var.region
  name                  = format("leaf-%d_ntwk-%s", var.leaf_number, each.key)
  description           = format("leaf-%d tenant network %s", var.leaf_number, each.key)
  network_id            = data.openstack_networking_network_v2.tenant[each.key].id
  admin_state_up        = "true"
  security_group_ids    = []
  no_security_groups    = true
  port_security_enabled = false
  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.tenant[each.key].id
    ip_address = cidrhost(
      cidrsubnet(
        data.openstack_networking_subnet_v2.tenant[each.key].cidr,
        var.tenant_network[each.key].cidr_newbits,
        var.available_region[var.region].offset
      ),
    var.leaf_number + 1)
  }
}

resource "openstack_networking_port_v2" "leaf_internet" {
  region         = var.region
  name           = format("leaf-%d_internet", var.leaf_number)
  description    = format("leaf-%d internet", var.leaf_number)
  network_id     = data.openstack_networking_network_v2.internet.id
  admin_state_up = "true"
  #security_group_ids    = ["default"]
  #no_security_groups    = false
  #port_security_enabled = true
  security_group_ids    = []
  no_security_groups    = true
  port_security_enabled = false
  fixed_ip {
    subnet_id  = var.spine_leaf_openstack.subnets.leaf_internet.id
    ip_address = cidrhost(var.spine_leaf_openstack.subnets.leaf_internet.cidr, 10 + var.leaf_number)
  }
}


resource "openstack_compute_instance_v2" "leaf" {
  region      = var.region
  name        = format("%s-leaf-%d", lower(var.region), var.leaf_number)
  image_name  = var.vyos_image_name
  flavor_name = var.flavor
  #  key_pair        = "INFRA"
  security_groups = []

  user_data = templatefile("templates/vyos.tpl", {
    admin_username = local.vyos.leaf.admin_username
    admin_password = local.vyos.leaf.admin_password
    api_key        = local.vyos.leaf.api_key
  })

  scheduler_hints {
    group = var.spine_leaf_openstack.compute_servergroup.id
  }

  // IPMI
  network {
    port = openstack_networking_port_v2.leaf_ipmi.id
  }
  // internet snat interface
  network {
    port = openstack_networking_port_v2.leaf_internet.id
  }
  // tenants network interfaces
  dynamic "network" {
    for_each = var.tenant_network
    content {
      port = openstack_networking_port_v2.leaf_ntwk-tenant[network.key].id
    }
  }
  // ibgp neighbor leaf
  network {
    port = openstack_networking_port_v2.leaf_leaf.id
  }
  // ebgp neighbors spine-1 from all availables regions
  dynamic "network" {
    for_each = var.available_region
    content {
      port = openstack_networking_port_v2.leaf_spine-1[network.key].id
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
    , openstack_networking_port_v2.leaf_ipmi.fixed_ip.0.ip_address)
  }

}

