resource "vyos_config" "spine-1_loopback" {
  provider = vyos.spine
  path     = "interfaces loopback lo address"
  value = jsonencode(
    format(
      "%s/32",
      cidrhost(
        cidrsubnet(
          var.backbone.spine.loopback.cidr_prefix,
          var.backbone.leafs.loopback.cidr_region_newbits,
          var.available_region[var.region].offset
        ),
        1
      )
    )
  )
}

resource "vyos_config" "spine-1_eth0_description" {
  provider = vyos.spine
  path     = "interfaces ethernet eth0 description"
  value = jsonencode(
    "ipmi"
  )
}

resource "vyos_config" "spine-1_eth_leaf-1_eBGP_description" {
  for_each = { for idx, region in keys(var.available_region) :
    idx => {
      name = region
      data = var.available_region[region]
    }
  }
  provider = vyos.spine
  path     = format("interfaces ethernet eth%d description", 1 + each.key)
  value = jsonencode(
    format("to_%s_leaf-1", lower(each.value.name))
  )
}

resource "vyos_config" "spine-1_eth_leaf-2_eBGP_description" {
  for_each = { for idx, region in keys(var.available_region) :
    idx => {
      name = region
      data = var.available_region[region]
    }
  }
  provider = vyos.spine
  path     = format("interfaces ethernet eth%d description", 1 + each.key + length(var.available_region))
  value = jsonencode(
    format("to_%s_leaf-2", lower(each.value.name))
  )
}

resource "vyos_config" "spine-1_bgp_address-family" {
  provider = vyos.spine
  path     = format("protocols bgp %s address-family", var.bgp_as_spines)
  value = jsonencode({
    "ipv4-unicast" = {
      "maximum-paths" = {
        "ebgp" = "8"
      }
      "network" = {
        format("%s/32",
          cidrhost(
            cidrsubnet(
              var.backbone.spine.loopback.cidr_prefix,
              var.backbone.spine.loopback.cidr_region_newbits,
              var.available_region[var.region].offset
            ),
            1
        )) = {}
      }
    }
  })
}
resource "vyos_config" "spine-1_bgp_parameters" {
  provider = vyos.spine
  path     = format("protocols bgp %s parameters", var.bgp_as_spines)
  value = jsonencode({
    "router-id" = format("%s",
      cidrhost(
        cidrsubnet(
          var.backbone.spine.loopback.cidr_prefix,
          var.backbone.spine.loopback.cidr_region_newbits,
          var.available_region[var.region].offset
        ),
        1
      )
    )
    "bestpath" = {
      "as-path" = {
        "multipath-relax" = {}
      }
    }
  })
}
resource "vyos_config" "spine-1_ebgp_neighbor_leaf-1" {
  provider = vyos.spine
  for_each = var.available_region
  path = format("protocols bgp %s neighbor %s", var.bgp_as_spines,
    cidrhost(
      cidrsubnet(
        cidrsubnet(var.backbone.leafs.ebgp.cidr_prefix,
          var.backbone.leafs.ebgp.cidr_newbits,
        var.available_region[var.region].offset),
        var.backbone.leafs.ebgp.cidr_bgp_session_newbits,
        (each.value.offset * 2) + 0
      ),
      2
    )
  )
  value = jsonencode({
    "remote-as" = format("%d", each.value.ASN)
    "update-source" = cidrhost(
      cidrsubnet(
        cidrsubnet(var.backbone.leafs.ebgp.cidr_prefix,
          var.backbone.leafs.ebgp.cidr_newbits,
        var.available_region[var.region].offset),
        var.backbone.leafs.ebgp.cidr_bgp_session_newbits,
        (each.value.offset * 2) + 0
      ),
      1
    )
    "address-family" = {
      "ipv4-unicast" = {
        "attribute-unchanged" = {
          "med" = {}
        }
      }
    }
  })
}
resource "vyos_config" "spine-1_ebgp_neighbor_leaf-2" {
  provider = vyos.spine
  for_each = var.available_region
  path = format("protocols bgp %s neighbor %s", var.bgp_as_spines,
    cidrhost(
      cidrsubnet(
        cidrsubnet(var.backbone.leafs.ebgp.cidr_prefix,
          var.backbone.leafs.ebgp.cidr_newbits,
        var.available_region[var.region].offset),
        var.backbone.leafs.ebgp.cidr_bgp_session_newbits,
        (each.value.offset * 2) + 1
      ),
      2
    )
  )
  value = jsonencode({
    "remote-as" = format("%d", each.value.ASN)
    "update-source" = cidrhost(
      cidrsubnet(
        cidrsubnet(var.backbone.leafs.ebgp.cidr_prefix,
          var.backbone.leafs.ebgp.cidr_newbits,
        var.available_region[var.region].offset),
        var.backbone.leafs.ebgp.cidr_bgp_session_newbits,
        (each.value.offset * 2) + 1
      ),
      1
    )
    "address-family" = {
      "ipv4-unicast" = {
        "attribute-unchanged" = {
          "med" = {}
        }
      }
    }
  })
}