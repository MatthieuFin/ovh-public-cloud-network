terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
    ovh = {
      source = "ovh/ovh"
    }
    vyos = {
      source  = "TGNThump/vyos"
      version = "2.1.0"
    }
  }
}




provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}


provider "openstack" {
  user_name           = var.openstack_username_pc1
  password            = var.openstack_password_pc1
  auth_url            = var.openstack_auth_url
  project_domain_name = var.openstack_project_domain_name
  user_domain_name    = var.openstack_user_domain_name
  // Public Cloud project 1
  alias    = "PC1"
}

provider "openstack" {
  user_name           = var.openstack_username_pc2
  password            = var.openstack_password_pc2
  auth_url            = var.openstack_auth_url
  project_domain_name = var.openstack_project_domain_name
  user_domain_name    = var.openstack_user_domain_name
  // Public Cloud project 2
  alias    = "PC2"
}

provider "vyos" {
  endpoint = local.vyos.gra9-leaf-1.endpoint
  api_key  = local.vyos.gra9-leaf-1.api_key
  alias    = "gra9-leaf-1"
}

provider "vyos" {
  endpoint = local.vyos.gra9-leaf-2.endpoint
  api_key  = local.vyos.gra9-leaf-2.api_key
  alias    = "gra9-leaf-2"
}
provider "vyos" {
  endpoint = local.vyos.gra9-spine-1.endpoint
  api_key  = local.vyos.gra9-spine-1.api_key
  alias    = "gra9-spine-1"
}

provider "vyos" {
  endpoint = local.vyos.gra11-leaf-1.endpoint
  api_key  = local.vyos.gra11-leaf-1.api_key
  alias    = "gra11-leaf-1"
}
provider "vyos" {
  endpoint = local.vyos.gra11-leaf-2.endpoint
  api_key  = local.vyos.gra11-leaf-2.api_key
  alias    = "gra11-leaf-2"
}
provider "vyos" {
  endpoint = local.vyos.gra11-spine-1.endpoint
  api_key  = local.vyos.gra11-spine-1.api_key
  alias    = "gra11-spine-1"
}

provider "vyos" {
  endpoint = local.vyos.sbg5-leaf-1.endpoint
  api_key  = local.vyos.sbg5-leaf-1.api_key
  alias    = "sbg5-leaf-1"
}
provider "vyos" {
  endpoint = local.vyos.sbg5-leaf-2.endpoint
  api_key  = local.vyos.sbg5-leaf-2.api_key
  alias    = "sbg5-leaf-2"
}
provider "vyos" {
  endpoint = local.vyos.sbg5-spine-1.endpoint
  api_key  = local.vyos.sbg5-spine-1.api_key
  alias    = "sbg5-spine-1"
}
