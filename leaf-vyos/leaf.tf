
resource "null_resource" "leaf_deleteSystemConntrackModules" {
  provisioner "local-exec" {
    command = format(
      "curl -k --location --request POST '%s/configure' --form data='%s' --form key='%s' && curl -k --location --request POST '%s/config-file' --form data='%s' --form key='%s'",
      local.vyos.leaf.endpoint,
      jsonencode({
        "op" = "delete"
        "path" = [
          "system",
          "conntrack",
          "modules"
        ]
      }),
      sensitive(local.vyos.leaf.api_key),
      local.vyos.leaf.endpoint,
      jsonencode({
        "op" = "save"
      }),
      sensitive(local.vyos.leaf.api_key)
    )
    interpreter = ["bash", "-c"]
    on_failure  = fail
  }
}

// loopback

resource "vyos_config" "leaf_loopback" {
  provider = vyos.leaf
  path     = "interfaces loopback lo address"
  value = jsonencode(
    format(
      "%s/32",
      cidrhost(
        cidrsubnet(
          var.backbone.leafs.loopback.cidr_prefix,
          var.backbone.leafs.loopback.cidr_region_newbits,
          var.available_region[var.region].offset
        ),
        10 + var.leaf_openstack.leaf_number
      )
    )
  )
}

// IPMI

resource "vyos_config" "leaf_eth0_description" {
  provider = vyos.leaf
  path     = "interfaces ethernet eth0 description"
  value = jsonencode(
    "ipmi + sync conntrack tables"
  )
}

// Internet

resource "vyos_config" "leaf_firewall" {
  provider = vyos.leaf
  path     = "firewall"
  value = jsonencode({
    "all-ping"               = "enable"
    "broadcast-ping"         = "disable"
    "config-trap"            = "disable"
    "ip-src-route"           = "disable"
    "ipv6-receive-redirects" = "disable"
    "ipv6-src-route"         = "disable"
    "log-martians"           = "enable"
    "name" = {
      "OUTSIDE-IN" = {
        "default-action" = "drop"
        "rule" = {
          "10" = {
            "action" = "accept"
            "state" = {
              "established" = "enable"
              "related"     = "enable"
            }
          }
        }
      }
      "OUTSIDE-LOCAL" = {
        "default-action" = "drop"
        "rule" = {
          "10" = {
            "action" = "accept"
            "state" = {
              "established" = "enable"
              "related"     = "enable"
            }
          }
          #"20" = {
          #    "action" = "accept"
          #    "icmp" = {
          #        "type-name" = "echo-request"
          #    }
          #    "protocol" = "icmp"
          #    "state" = {
          #        "new" = "enable"
          #    }
          #}
        }
      }
    }
    "receive-redirects"      = "disable"
    "send-redirects"         = "enable"
    "source-validation"      = "disable"
    "syn-cookies"            = "enable"
    "twa-hazards-protection" = "disable"
  })
}

resource "vyos_config" "leaf_eth1_internet_description" {
  provider = vyos.leaf
  path     = "interfaces ethernet eth1 description"
  value = jsonencode(
    "internet snat"
  )
}
resource "vyos_config" "leaf_eth1_internet_firewall" {
  provider   = vyos.leaf
  depends_on = [vyos_config.leaf_firewall]
  path       = "interfaces ethernet eth1 firewall"
  value = jsonencode({
    "in" = {
      "name" = "OUTSIDE-IN"
    }
    "local" = {
      "name" = "OUTSIDE-LOCAL"
    }
  })
}

// tenants interfaces

resource "vyos_config" "leaf_eth_ternant_description" {
  provider = vyos.leaf
  for_each = { for idx, tenant in keys(var.tenant_network) :
    idx => {
      name = tenant
      data = var.tenant_network[tenant]
    }
  }
  // tenants interfaces are after ipmi and internet interfaces (which why + 2)
  path = format("interfaces ethernet eth%d description", each.key + 2)
  value = jsonencode(
    format("%s tenant ntwk interface vrrp", each.value.name)
  )
}

// iBGP

resource "vyos_config" "leaf_eth_ibgp_description" {
  provider = vyos.leaf
  path     = format("interfaces ethernet eth%d description", 2 + length(var.tenant_network))
  value = jsonencode(
    format("to_leaf-%d_ibgp", var.leaf_openstack.leaf_number%2+1)
  )
}

// eBGP neighbors

resource "vyos_config" "leaf_eth_eBGP_description" {
  for_each = { for idx, region in keys(var.available_region) :
    idx => {
      name = region
      data = var.available_region[region]
    }
  }
  provider = vyos.leaf
  path     = format("interfaces ethernet eth%d description", 2 + length(var.tenant_network) + 1 + each.key)
  value = jsonencode(
    format("to_%s_spine-1", lower(each.value.name))
  )
}

resource "vyos_config" "leaf_internet_snat_tenant" {
  provider = vyos.leaf
  for_each = { for idx, tenant in keys(var.tenant_network) :
    tenant => {
      idx  = idx
      data = var.tenant_network[tenant]
    }
  }
  path = format("nat source rule %d", each.value.idx + 1)
  value = jsonencode({
    "outbound-interface" = "eth1"
    "source" = {
      "address" = cidrsubnet(
        data.openstack_networking_subnet_v2.tenant[each.key].cidr,
        var.tenant_network[each.key].cidr_newbits,
        var.available_region[var.region].offset
      )

    }
    "translation" = {
      "address" = "masquerade"
    }
  })
}

resource "vyos_config" "leaf_policy_prefix-list_tenant-network" {
  provider = vyos.leaf
  for_each = { for idx, tenant in keys(var.tenant_network) :
    tenant => {
      idx  = idx
      data = var.tenant_network[tenant]
    }
  }
  path = format("policy prefix-list tenant-network rule %d", each.value.idx + 1)
  value = jsonencode({
    "action" = "permit"
    "prefix" = cidrsubnet(
      data.openstack_networking_subnet_v2.tenant[each.key].cidr,
      var.tenant_network[each.key].cidr_newbits,
      var.available_region[var.region].offset
    )
  })
}

resource "vyos_config" "leaf_policy_prefix-list_tenant-route" {
  provider = vyos.leaf
  path     = format("policy prefix-list tenant-route rule")
  value = jsonencode(
    zipmap(
      concat(
        ["1"],
      [for idx, route in distinct(flatten([for peer in var.leafs_additionnal_tenant_peers : peer.route])) : idx + 2]),
      concat(
        [{
          "action" = "permit"
          "prefix" = format("%s/32",
            cidrhost(
              cidrsubnet(
                var.backbone.leafs.loopback.cidr_prefix,
                var.backbone.leafs.loopback.cidr_region_newbits,
                var.available_region[var.region].offset
              ),
              10 + var.leaf_openstack.leaf_number
            )
          )
          }
        ],
        [for route in distinct(flatten([for peer in var.leafs_additionnal_tenant_peers : peer.route])) : {
          "action" = "permit"
          "prefix" = format("%s/32", route)
      }])
    )
  )
}


resource "vyos_config" "leaf_policy_route-map_local-spine_tenant-route" {
  provider = vyos.leaf
  depends_on = [vyos_config.leaf_policy_prefix-list_tenant-route]
  path     = "policy route-map local-spine rule 1"
  value = jsonencode({
    "action" = "permit"
    "match" = {
      "ip" = {
        "address" = {
          "prefix-list" = "tenant-route"
        }
      }
    }
  })
}
resource "vyos_config" "leaf_policy_route-map_local-spine_tenant-network" {
  provider = vyos.leaf
  depends_on = [vyos_config.leaf_policy_prefix-list_tenant-network]
  path     = "policy route-map local-spine rule 2"
  value = jsonencode({
    "action" = "permit"
    "match" = {
      "ip" = {
        "address" = {
          "prefix-list" = "tenant-network"
        }
      }
    }
    "set" = {
      "metric" = "100"
    }
  })
}

resource "vyos_config" "leaf_policy_route-map_remote-spine_tenant-route" {
  provider = vyos.leaf
  depends_on = [vyos_config.leaf_policy_prefix-list_tenant-route]
  path     = "policy route-map remote-spine rule 1"
  value = jsonencode({
    "action" = "permit"
    "match" = {
      "ip" = {
        "address" = {
          "prefix-list" = "tenant-route"
        }
      }
    }
  })
}

resource "vyos_config" "leaf_policy_route-map_remote-spine_tenant-network" {
  provider = vyos.leaf
  depends_on = [vyos_config.leaf_policy_prefix-list_tenant-network]
  path     = "policy route-map remote-spine rule 2"
  value = jsonencode({
    "action" = "permit"
    "match" = {
      "ip" = {
        "address" = {
          "prefix-list" = "tenant-network"
        }
      }
    }
    "set" = {
      "metric" = "150"
    }
  })
}

resource "vyos_config" "leaf_vrrp_sync" {
  provider = vyos.leaf
  path     = "high-availability vrrp group sync"
  value = jsonencode({
    "interface" = "eth0"
    "hello-source-address" = cidrhost(
      cidrsubnet(
        var.ipmi.cidr_prefix,
        var.ipmi.cidr_newbits,
        var.available_region[var.region].offset
      ),
      10 + var.leaf_openstack.leaf_number
    )
    "peer-address" = cidrhost(
      cidrsubnet(
        var.ipmi.cidr_prefix,
        var.ipmi.cidr_newbits,
        var.available_region[var.region].offset
      ),
      10 + (var.leaf_openstack.leaf_number%2 + 1)
    )
    "preempt-delay" = "1"
    // 200 on leaf-1 and 100 on leaf-2
    "priority"      = format("%d", 100 * (var.leaf_openstack.leaf_number%2 + 1))
    "virtual-address" = {
      format(
        "%s/%s",
        cidrhost(
          cidrsubnet(
            var.ipmi.cidr_prefix,
            var.ipmi.cidr_newbits,
            var.available_region[var.region].offset
          ),
          10
        ),
        split("/", var.ipmi.cidr_prefix)[1]
      ) = {}
    }
    "vrid" = "1"
  })
}
resource "vyos_config" "leaf_vrrp_sync-group" {
  provider   = vyos.leaf
  depends_on = [vyos_config.leaf_vrrp_sync]
  path       = "high-availability vrrp sync-group syncgrp"
  value = jsonencode({
    "member" = "sync"
  })
}
resource "vyos_config" "leaf_nat_conntrack-sync" {
  provider = vyos.leaf
  depends_on = [
    vyos_config.leaf_vrrp_sync,
    vyos_config.leaf_vrrp_sync-group
  ]
  path = "service conntrack-sync"
  value = jsonencode({
    "accept-protocol" = [
      "tcp",
      "udp",
      "icmp"
    ]
    "disable-external-cache"  = {}
    "event-listen-queue-size" = "8"
    "failover-mechanism" = {
      "vrrp" = {
        "sync-group" = "syncgrp"
      }
    }
    "listen-address" = cidrhost(
      cidrsubnet(
        var.ipmi.cidr_prefix,
        var.ipmi.cidr_newbits,
        var.available_region[var.region].offset
      ),
      10 + var.leaf_openstack.leaf_number
    )
    "interface" = {
      "eth0" = {
        "peer" = cidrhost(
          cidrsubnet(
            var.ipmi.cidr_prefix,
            var.ipmi.cidr_newbits,
            var.available_region[var.region].offset
          ),
          10 + (var.leaf_openstack.leaf_number%2 + 1)
        )
      }
    }
    "sync-queue-size" = "8"
  })
}

resource "vyos_config" "leaf_vrrp_tenant" {
  provider = vyos.leaf
  for_each = { for idx, tenant in keys(var.tenant_network) :
    tenant => {
      idx  = idx
      data = var.tenant_network[tenant]
    }
  }
  path = format("high-availability vrrp group %s", each.key)
  value = jsonencode({
    // tenants interfaces are after ipmi and internet interfaces (which why + 2)
    "interface" = format("eth%d", each.value.idx + 2)
    "hello-source-address" = cidrhost(
      cidrsubnet(
        data.openstack_networking_subnet_v2.tenant[each.key].cidr,
        var.tenant_network[each.key].cidr_newbits,
        var.available_region[var.region].offset
      ),
      1 + var.leaf_openstack.leaf_number
    )
    "peer-address" = cidrhost(
      cidrsubnet(
        data.openstack_networking_subnet_v2.tenant[each.key].cidr,
        var.tenant_network[each.key].cidr_newbits,
        var.available_region[var.region].offset
      ),
      1 + (var.leaf_openstack.leaf_number%2 + 1)
    )
    "preempt-delay" = "180"
    // 200 on leaf-1 and 100 on leaf-2
    "priority"      = format("%d", 100 * (var.leaf_openstack.leaf_number%2 + 1))
    "virtual-address" = {
      format(
        "%s/%s",
        cidrhost(
          cidrsubnet(
            data.openstack_networking_subnet_v2.tenant[each.key].cidr,
            var.tenant_network[each.key].cidr_newbits,
            var.available_region[var.region].offset
          ),
          1
        ),
        split("/", data.openstack_networking_subnet_v2.tenant[each.key].cidr)[1] + var.tenant_network[each.key].cidr_newbits
      ) = {}
    }
    "vrid" = format("%d", 10 + each.value.idx)
  })
}


resource "vyos_config" "leaf_bgp_address-family_ipv4_max-path" {
  provider = vyos.leaf
  path     = format("protocols bgp %s address-family ipv4-unicast maximum-paths", var.available_region[var.region].ASN)
  value = jsonencode({
    "ebgp" = "8"
  })
}
resource "vyos_config" "leaf_bgp_parameters" {
  provider = vyos.leaf
  path     = format("protocols bgp %s parameters", var.available_region[var.region].ASN)
  value = jsonencode({
    "router-id" = cidrhost(
      cidrsubnet(
        var.backbone.leafs.loopback.cidr_prefix,
        var.backbone.leafs.loopback.cidr_region_newbits,
        var.available_region[var.region].offset
      ),
      10 + var.leaf_openstack.leaf_number
    )
    "bestpath" = {
      "as-path" = {
        "multipath-relax" = {}
      }
    }
  })
}

// annonce local loopback

resource "vyos_config" "leaf_announce_loopback" {
  provider = vyos.leaf
  path = format(
    "protocols bgp %s address-family ipv4-unicast network %s",
    var.available_region[var.region].ASN,
    format("%s/32",
      cidrhost(
        cidrsubnet(
          var.backbone.leafs.loopback.cidr_prefix,
          var.backbone.leafs.loopback.cidr_region_newbits,
          var.available_region[var.region].offset
        ),
        10 + var.leaf_openstack.leaf_number
      )
    )
  )
  value = jsonencode({})
}

// annonce local networks

resource "vyos_config" "leaf_ntwk_tenant" {
  provider = vyos.leaf
  for_each = {
    for idx, tenant in keys(var.tenant_network) :
    tenant => {
      idx  = idx
      data = var.tenant_network[tenant]
    }
  }
  path = format(
    "protocols bgp %s address-family ipv4-unicast network %s",
    var.available_region[var.region].ASN,
    cidrsubnet(
      data.openstack_networking_subnet_v2.tenant[each.key].cidr,
      var.tenant_network[each.key].cidr_newbits,
      var.available_region[var.region].offset
    )
  )
  value = jsonencode({})
}



// neighbor iBGP

resource "vyos_config" "leaf_iBGP" {
  provider = vyos.leaf
  path = format(
    "protocols bgp %s neighbor %s",
    var.available_region[var.region].ASN,
    cidrhost(
      cidrsubnet(
        var.backbone.leafs.ibgp.cidr_prefix,
        var.backbone.leafs.ibgp.cidr_newbits,
        var.available_region[var.region].offset
      ),
      var.leaf_openstack.leaf_number%2 + 1
    )
  )
  value = jsonencode({
    "remote-as" = format("%d", var.available_region[var.region].ASN)
    "update-source" = cidrhost(
      cidrsubnet(
        var.backbone.leafs.ibgp.cidr_prefix,
        var.backbone.leafs.ibgp.cidr_newbits,
        var.available_region[var.region].offset
      ),
      var.leaf_openstack.leaf_number
    )
    "address-family" = {
      "ipv4-unicast" = {
        "nexthop-self" = {}
      }
    }
  })
}

// neighbor eBGP

resource "vyos_config" "leaf_eBGP" {
  provider = vyos.leaf
  depends_on = [
    vyos_config.leaf_policy_route-map_local-spine_tenant-route,
    vyos_config.leaf_policy_route-map_local-spine_tenant-network,
    vyos_config.leaf_policy_route-map_remote-spine_tenant-route,
    vyos_config.leaf_policy_route-map_remote-spine_tenant-network
  ]
  for_each = var.available_region
  path = format(
    "protocols bgp %s neighbor %s",
    var.available_region[var.region].ASN,
    cidrhost(
      cidrsubnet(
        cidrsubnet(
          var.backbone.leafs.ebgp.cidr_prefix,
          var.backbone.leafs.ebgp.cidr_newbits,
          var.available_region[each.key].offset
        ),
        var.backbone.leafs.ebgp.cidr_bgp_session_newbits,
        (var.available_region[var.region].offset * 2) + ((var.leaf_openstack.leaf_number + 1)%2)
      ),
      1
    )
  )
  value = jsonencode({
    "remote-as" = format("%d", var.bgp_as_spines)
    "update-source" = cidrhost(
      cidrsubnet(
        cidrsubnet(
          var.backbone.leafs.ebgp.cidr_prefix,
          var.backbone.leafs.ebgp.cidr_newbits,
          var.available_region[each.key].offset
        ),
        var.backbone.leafs.ebgp.cidr_bgp_session_newbits,
        (var.available_region[var.region].offset * 2) + ((var.leaf_openstack.leaf_number + 1)%2)
      ),
      2
    )
    "address-family" = {
      "ipv4-unicast" = {
        "allowas-in" = {
          "number" = "1"
        }
        "route-map" = {
          "export" = trim(each.key, "0123456789") == trim(var.region, "0123456789") ? "local-spine" : "remote-spine"
        }
      }
    }
  })
}


// custom additionnal tenant bgp peers

resource "vyos_config" "leaf_additionnal_tenant_eBGP" {
  provider = vyos.leaf
  for_each = var.leafs_additionnal_tenant_peers
  path = format(
    "protocols bgp %s neighbor %s",
    var.available_region[var.region].ASN,
    each.key
  )
  value = jsonencode({
    "remote-as" = format("%d", each.value.remote-as)
    "update-source" = cidrhost(
      cidrsubnet(
        data.openstack_networking_subnet_v2.tenant[each.value.tenant_network].cidr,
        var.tenant_network[each.value.tenant_network].cidr_newbits,
        var.available_region[var.region].offset
      ),
      1
    ),
    "address-family" = {
      "ipv4-unicast" = {
        "nexthop-self" = {}
      }
    }
  })
}


