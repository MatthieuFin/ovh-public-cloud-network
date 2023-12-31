


variable "cloud_projects" {
  type = map(string)
}


# spine-leaf-openstack module

variable "ipmi" {
  description = "ipmi network informations (same for all regions)"
  type = object({
    cidr_prefix  = string
    cidr_newbits = number
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


# spine-openstack module

variable "vyos_image_name" {
  description = "QEMU vyos image name"
  type        = string
  validation {
    condition     = contains(["vyos-1.3.4-cloud-init"], var.vyos_image_name)
    error_message = "Allowed images for vyos are \"vyos-1.3.4-cloud-init\"."
  }
}

# spine-vyos module

variable "bgp_as_spines" {
  description = "BGP AS number for spines"
  type        = number
  validation {
    condition     = 64512 <= var.bgp_as_spines && var.bgp_as_spines <= 65535
    error_message = "BGP spines AS should be in BGP private range [64512-65535]"
  }
}


# leaf-openstack module


# leaf-vyos module

variable "tenant_network" {
  description = "list of network / subnet tenants names, cidr_newbits permit to split network in subnets per regions"
  type = map(object({
    cidr         = string
    cidr_newbits = number
  }))
}

variable "leafs_additionnal_tenant_peers" {
  description = "Custom additionnal peering on leaf from tenant network"
  type = map(
    map(object({
      route          = list(string)
      remote-as      = number
      tenant_network = string
    }))
  )
  //  validation {
  //    condition = (
  //      length([for ip in keys(var.leafs_additionnal_tenant_peers) : ip if can(cidrnetmask(format("%s/32", ip)))]) == length(var.leafs_additionnal_tenant_peers)
  //    )
  //    error_message = "Keys should be bgp peer ip address"
  //  }
  //  validation {
  //    condition = (
  //      length([for as in [for peer in var.leafs_additionnal_tenant_peers : peer.remote-as] : as if(64512 <= as && as <= 65535)]) == length(var.leafs_additionnal_tenant_peers)
  //    )
  //    error_message = "BGP spines AS should be in BGP private range [64512-65535]"
  //  }
  //validation {
  //    condition     = (
  //        length([for ntwk in [for peer in var.leafs_additionnal_tenant_peers : peer.tenant_network] : ntwk if contains(keys(var.tenant_network), ntwk)]) == length(var.leafs_additionnal_tenant_peers)
  //    )
  //    error_message = "tenant_network not configured"
  //}
}




# vyos credentials

variable "vyos_username" {
  description = "vyos admin username"
  type        = string
}

variable "vyos_password_gra9_leaf_1" {
  description = "vyos password admin"
  type        = string
}
variable "vyos_api_key_gra9_leaf_1" {
  description = "vyos api key https"
  type        = string
}

variable "vyos_password_gra9_leaf_2" {
  description = "vyos password admin"
  type        = string
}
variable "vyos_api_key_gra9_leaf_2" {
  description = "vyos api key https"
  type        = string
}

variable "vyos_password_gra9_spine_1" {
  description = "vyos password admin"
  type        = string
}
variable "vyos_api_key_gra9_spine_1" {
  description = "vyos api key https"
  type        = string
}

variable "vyos_password_gra11_leaf_1" {
  description = "vyos password admin"
  type        = string
}
variable "vyos_api_key_gra11_leaf_1" {
  description = "vyos api key https"
  type        = string
}

variable "vyos_password_gra11_leaf_2" {
  description = "vyos password admin"
  type        = string
}
variable "vyos_api_key_gra11_leaf_2" {
  description = "vyos api key https"
  type        = string
}

variable "vyos_password_gra11_spine_1" {
  description = "vyos password admin"
  type        = string
}
variable "vyos_api_key_gra11_spine_1" {
  description = "vyos api key https"
  type        = string
}

variable "vyos_password_sbg5_leaf_1" {
  description = "vyos password admin"
  type        = string
}
variable "vyos_api_key_sbg5_leaf_1" {
  description = "vyos api key https"
  type        = string
}

variable "vyos_password_sbg5_leaf_2" {
  description = "vyos password admin"
  type        = string
}
variable "vyos_api_key_sbg5_leaf_2" {
  description = "vyos api key https"
  type        = string
}

variable "vyos_password_sbg5_spine_1" {
  description = "vyos password admin"
  type        = string
}
variable "vyos_api_key_sbg5_spine_1" {
  description = "vyos api key https"
  type        = string
}




# Openstack Auth variables

variable "openstack_username_pc1" {
  description = "Openstack username (horizon) OS_USERNAME for project PC1"
  type        = string
}
variable "openstack_password_pc1" {
  description = "Openstack password (horizon) OS_PASSWORD for project PC1"
  type        = string
}
variable "openstack_username_pc2" {
  description = "Openstack username (horizon) OS_USERNAME for project PC2"
  type        = string
}
variable "openstack_password_pc2" {
  description = "Openstack password (horizon) OS_PASSWORD for project PC2"
  type        = string
}
variable "openstack_auth_url" {
  description = "Openstack auth url OS_AUTH_URL"
  type        = string
  default     = "https://auth.cloud.ovh.net/v3/"
}

variable "openstack_project_domain_name" {
  description = "Openstack project domain name OS_PROJECT_DOMAIN_NAME"
  type        = string
  default     = "default"
}
variable "openstack_user_domain_name" {
  description = "Openstack user domain name OS_USER_DOMAIN_NAME"
  type        = string
  default     = "Default"
}

# OVH auth variables

variable "ovh_application_key" {
  description = "OVH application key OVH_APPLICATION_KEY aka TF_VAR_ovh_application_key"
  type        = string
}
variable "ovh_application_secret" {
  description = "OVH application secret OVH_APPLICATION_SECRET aka TF_VAR_ovh_application_secret"
  type        = string
}
variable "ovh_consumer_key" {
  description = "OVH consumer key OVH_CONSUMER_KEY aka TF_VAR_ovh_consumer_key"
  type        = string
}
