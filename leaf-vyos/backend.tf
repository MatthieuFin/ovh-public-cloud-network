terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
    vyos = {
      source                = "TGNThump/vyos"
      version               = "2.1.0"
      configuration_aliases = [vyos.leaf]
    }
  }
}


