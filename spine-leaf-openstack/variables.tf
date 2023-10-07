variable "region" {
  description = "region to deploy spine-leaf stack"
  type        = string
  validation {
    condition     = contains(["GRA9", "GRA11", "SBG5"], var.region)
    error_message = "Allowed values for region are GRA9, GRA11, SBG5."
  }
}

variable "servergroup_name" {
  type        = string
  description = "VMs group spine leaf"
}

variable "servergroup_policy" {
  type        = string
  description = "Servergroup policy for spine leaf"
  validation {
    condition     = contains(["anti-affinity", "soft-anti-affinity"], var.servergroup_policy)
    error_message = "Allowed affinity  are \"anti-affinity\", \"soft-anti-affinity \"."
  }
}

variable "available_region" {
  description = "available region which who peering"
  type = map(object({
    offset = number
  }))
  validation {
    condition = (
      length(var.available_region) == length(distinct([for region in keys(var.available_region) : var.available_region[region].offset]))
    )
    error_message = "Regions offset have to be unique"
  }
}

variable "ext-net" {
  description = "Name of network with public ips"
  type        = string
}

variable "ipmi" {
  description = "ipmi network informations (same for all regions)"
  type = object({
    cidr_prefix  = string
    cidr_newbits = number
  })
}


variable "backbone" {
  description = "backbone network informations (same for all regions)"
  type = object({
    name = string
    leafs = object({
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

