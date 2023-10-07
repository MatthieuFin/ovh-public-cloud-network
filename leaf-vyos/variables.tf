variable "region" {
  description = "region to deploy spine-leaf stack"
  type        = string
  validation {
    condition     = contains(["GRA9", "GRA11", "SBG5"], var.region)
    error_message = "Allowed values for region are GRA9, GRA11, SBG5."
  }
}

variable "ipmi" {
  description = "ipmi network informations (same for all regions)"
  type = object({
    cidr_prefix  = string
    cidr_newbits = number
  })
}

variable "bgp_as_spines" {
  description = "BGP AS number for spines"
  type        = number
  validation {
    condition     = 64512 <= var.bgp_as_spines && var.bgp_as_spines <= 65535
    error_message = "BGP spines AS should be in BGP private range [64512-65535]"
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
  })
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

variable "leaf_openstack" {
    description = "Openstack module which provision leaf vm"
}

variable "vyos_api_key_leaf" {
  description = "vyos api key https"
  type        = string
}

variable "tenant_network" {
  description = "list of network / subnet tenants names"
  type = map(object({
    cidr_newbits = number

  }))
}

variable "leafs_additionnal_tenant_peers" {
  description = "Custom additionnal peering on leaf from tenant network"
  type = map(object({
    route          = list(string)
    remote-as      = number
    tenant_network = string
  }))
  validation {
    condition = (
      length([for ip in keys(var.leafs_additionnal_tenant_peers) : ip if can(cidrnetmask(format("%s/32", ip)))]) == length(var.leafs_additionnal_tenant_peers)
    )
    error_message = "Keys should be bgp peer ip address"
  }
  validation {
    condition = (
      length([for as in [for peer in var.leafs_additionnal_tenant_peers : peer.remote-as] : as if(64512 <= as && as <= 65535)]) == length(var.leafs_additionnal_tenant_peers)
    )
    error_message = "BGP spines AS should be in BGP private range [64512-65535]"
  }
  //validation {
  //    condition     = (
  //        length([for ntwk in [for peer in var.leafs_additionnal_tenant_peers : peer.tenant_network] : ntwk if contains(keys(var.tenant_network), ntwk)]) == length(var.leafs_additionnal_tenant_peers)
  //    )
  //    error_message = "tenant_network not configured"
  //}
}

