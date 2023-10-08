locals {
  vyos = {
    "gra9-leaf-1" = {
      endpoint       = local.vyos_endpoints["GRA9"].leaf-1.endpoint
      admin_username = var.vyos_username
      admin_password = var.vyos_password_gra9_leaf_1
      api_key        = var.vyos_api_key_gra9_leaf_1
    }
    "gra9-leaf-2" = {
      endpoint       = local.vyos_endpoints["GRA9"].leaf-2.endpoint
      admin_username = var.vyos_username
      admin_password = var.vyos_password_gra9_leaf_2
      api_key        = var.vyos_api_key_gra9_leaf_2
    }
    "gra9-spine-1" = {
      endpoint       = local.vyos_endpoints["GRA9"].spine-1.endpoint
      admin_username = var.vyos_username
      admin_password = var.vyos_password_gra9_spine_1
      api_key        = var.vyos_api_key_gra9_spine_1
    }
    "gra11-leaf-1" = {
      endpoint       = local.vyos_endpoints["GRA11"].leaf-1.endpoint
      admin_username = var.vyos_username
      admin_password = var.vyos_password_gra11_leaf_1
      api_key        = var.vyos_api_key_gra11_leaf_1
    }
    "gra11-leaf-2" = {
      endpoint       = local.vyos_endpoints["GRA11"].leaf-2.endpoint
      admin_username = var.vyos_username
      admin_password = var.vyos_password_gra11_leaf_2
      api_key        = var.vyos_api_key_gra11_leaf_2
    }
    "gra11-spine-1" = {
      endpoint       = local.vyos_endpoints["GRA11"].spine-1.endpoint
      admin_username = var.vyos_username
      admin_password = var.vyos_password_gra11_spine_1
      api_key        = var.vyos_api_key_gra11_spine_1
    }
    "sbg5-leaf-1" = {
      endpoint       = local.vyos_endpoints["SBG5"].leaf-1.endpoint
      admin_username = var.vyos_username
      admin_password = var.vyos_password_sbg5_leaf_1
      api_key        = var.vyos_api_key_sbg5_leaf_1
    }
    "sbg5-leaf-2" = {
      endpoint       = local.vyos_endpoints["SBG5"].leaf-2.endpoint
      admin_username = var.vyos_username
      admin_password = var.vyos_password_sbg5_leaf_2
      api_key        = var.vyos_api_key_sbg5_leaf_2
    }
    "sbg5-spine-1" = {
      endpoint       = local.vyos_endpoints["SBG5"].spine-1.endpoint
      admin_username = var.vyos_username
      admin_password = var.vyos_password_sbg5_spine_1
      api_key        = var.vyos_api_key_sbg5_spine_1
    }
  }

  vyos_endpoints = {
    for region in keys(var.available_region) :
    region => {
      "leaf-1" = {
        "endpoint" = format(
          "https://%s:11443",
          cidrhost(
            cidrsubnet(
              var.ipmi.cidr_prefix,
              var.ipmi.cidr_newbits,
              var.available_region[region].offset
            ),
          11)
        )
      },
      "leaf-2" = {
        "endpoint" = format(
          "https://%s:11443",
          cidrhost(
            cidrsubnet(
              var.ipmi.cidr_prefix,
              var.ipmi.cidr_newbits,
              var.available_region[region].offset
            ),
          12)
        )
      }
      "spine-1" = {
        "endpoint" = format(
          "https://%s:11443",
          cidrhost(
            cidrsubnet(
              var.ipmi.cidr_prefix,
              var.ipmi.cidr_newbits,
              var.available_region[region].offset
            ),
          100)
        )
      }
    }
  }
}
