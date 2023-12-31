variable "region" {
  description = "region to deploy spine-leaf stack"
  type        = string
  validation {
    condition     = contains([
        "SBG1",
        "SBG3",
        "SBG5",
        "SBG7",
        "GRA1",
        "GRA3",
        "GRA5",
        "GRA7",
        "GRA9",
        "GRA11",
        //"RBX",
        "UK1",
        "DE1",
        "WAW1",
        "BHS1",
        "BHS2",
        "BHS3",
        "BHS5",
        "VIN1",
        "HIL1",
        "SGP1",
        "SYD1",
    ], var.region)
    error_message = "Region is not allowed."
  }
}

variable "bgp_as_spines" {
  description = "BGP AS number for spines"
  type        = number
  validation {
    condition     = 64512 <= var.bgp_as_spines && var.bgp_as_spines <= 65535
    error_message = "BGP spines AS should be in BGP private range [64512-65535]"
  }
}

variable "available_region" {
  description = "available region which who peering"
  type = map(object({
    offset = number
    ASN    = number
  }))
  validation {
    condition = (
      length(var.available_region) == length(distinct([for region in keys(var.available_region) : var.available_region[region].offset]))
    )
    error_message = "Regions offset have to be unique"
  }
  validation {
    condition = (
      length(var.available_region) == length(distinct([for region in keys(var.available_region) : var.available_region[region].ASN]))
    )
    error_message = "Regions ASN have to be unique"
  }
}

variable "backbone" {
  description = "backbone network informations (same for all regions)"
  type = object({
    name = string
    leafs = object({
      loopback = object({
        cidr_prefix         = string
        cidr_region_newbits = number
      })
      ibgp = object({
        cidr_prefix  = string
        cidr_newbits = number
      })
      ebgp = object({
        cidr_prefix              = string
        cidr_newbits             = number
        cidr_bgp_session_newbits = number
      })
      internet = object({
        cidr_prefix  = string
        cidr_newbits = number
      })
    })
    spine = object({
      loopback = object({
        cidr_prefix         = string
        cidr_region_newbits = number
      })
    })
  })
}







