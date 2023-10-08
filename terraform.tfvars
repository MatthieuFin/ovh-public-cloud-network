
cloud_projects = {
  PC1 = "xxx"
  PC2   = "yyy"
}

leafs_additionnal_tenant_peers = {
  "GRA9" = {
    "10.100.1.131" = {
      "route" = [
        "10.4.4.4",
      ]
      "remote-as"      = 64531
      "tenant_network" = "ntwk1"
    }
  }
  "GRA11" = {}
  "SBG5" = {}
}



tenant_network = {
    "ntwk1" = {
        "cidr" = "10.100.0.0/16"
        "cidr_newbits" = 4
    }
    "ntwk2" = {
        "cidr" = "10.200.0.0/16"
        "cidr_newbits" = 4
    }
}

vyos_image_name = "vyos-1.3.4-cloud-init"

bgp_as_spines = 64520

#servergroup_name = "vm-group-spine-leaf"


available_region = {
  "GRA9" = {
    "offset" = 0
    "ASN"    = 64600
  }
  "GRA11" = {
    "offset" = 1
    "ASN"    = 64601
  }
  "SBG5" = {
    "offset" = 2
    "ASN"    = 64602
  }
  "DE1" = {
    "offset" = 3
    "ASN"    = 64603
  }
  "UK1" = {
    "offset" = 4
    "ASN"    = 64604
  }
  "WAW1" = {
    "offset" = 5
    "ASN"    = 64605
  }
  "BHS5" = {
    "offset" = 6
    "ASN"    = 64606
  }
  /// ...
}

ipmi = {
  "cidr_prefix"  = "10.14.0.0/16"
  "cidr_newbits" = 8
}


backbone = {
  "name" = "backbone"
  "leafs" = {
      "loopback" = {
        "cidr_prefix"         = "10.12.0.0/16"
        "cidr_region_newbits" = 8
      }
    "ibgp" = {
      "cidr_prefix"  = "10.10.0.0/24"
      "cidr_newbits" = 6
    }
    "ebgp" = {
      "cidr_prefix"              = "10.11.0.0/17"
      "cidr_newbits"             = 7
      "cidr_bgp_session_newbits" = 6
    }
    "internet" = {
      "cidr_prefix"  = "10.11.128.0/17"
      "cidr_newbits" = 7
    }
  }
  "spine" = {
    "loopback" = {
      "cidr_prefix"         = "10.12.0.0/16"
      "cidr_region_newbits" = 8
    }
  }
}
  
