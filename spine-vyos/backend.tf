terraform {
  required_version = ">= 0.14.0"
  required_providers {
    vyos = {
      source                = "TGNThump/vyos"
      version               = "2.1.0"
      configuration_aliases = [vyos.spine]
    }
  }
}


