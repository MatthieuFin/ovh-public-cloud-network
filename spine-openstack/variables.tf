
variable "spine_leaf_openstack" {
    description = "module spine leaf openstack provisioning subnets and co"
}

variable "monthly" {
  description = "monthly OpenStack VM"
  type        = bool
  default     = false
}

variable "flavor" {
  description = "flavor"
  type        = string
  default     = "b2-7"
}


variable "vyos_username_spine" {
  description = "vyos admin username"
  type        = string
}
variable "vyos_password_spine" {
  description = "vyos password admin"
  type        = string
}
variable "vyos_api_key_spine" {
  description = "vyos api key https"
  type        = string
}

variable "vyos_image_name" {
  description = "QEMU vyos image name"
  type        = string
  default     = "vyos-1.3.4-cloud-init"
  validation {
    condition     = contains(["vyos-1.3.4-cloud-init"], var.vyos_image_name)
    error_message = "Allowed images for vyos are \"vyos-1.3.4-cloud-init\"."
  }
}

variable "region" {
  description = "region to deploy spine-leaf stack"
  type        = string
  validation {
    condition     = contains(["GRA9", "GRA11", "SBG5"], var.region)
    error_message = "Allowed values for region are GRA9, GRA11, SBG5."
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

variable "ipmi" {
  description = "ipmi network informations (same for all regions)"
  type = object({
    cidr_prefix  = string
    cidr_newbits = number
  })
}
