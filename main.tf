terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
  version = "~> 2.4"
  features {}
}

variable "name_prefix" {
  type        = string
  description = "A prefix for the naming scheme as part of prefix-base-suffix."
}

variable "name_base" {
  type        = string
  description = "A base for the naming scheme as part of prefix-base-suffix."
}

variable "name_suffix" {
  type        = string
  description = "A suffix for the naming scheme as part of prefix-base-suffix."
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be created."
}

locals {
  base_name = "${var.name_prefix}-${var.name_base}-${var.name_suffix}"
}

resource "azurerm_resource_group" "group" {
  name     = local.base_name
  location = var.location
}

resource "azurerm_app_service_plan" "plan" {
  name                = "${local.base_name}-plan"
  resource_group_name = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location
  kind                = "xenon"
  is_xenon            = true
  # reserved            = true

  sku {
    tier = "PremiumContainer"
    size = "PC2"
  }
}

resource "azurerm_app_service" "appsvc" {
  name                = local.base_name
  resource_group_name = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location
  app_service_plan_id = azurerm_app_service_plan.plan.id

#   app_settings = merge(var.environment-variables, {
#     "DOCKER_REGISTRY_SERVER_USERNAME" = var.docker-registry-username,
#     "DOCKER_REGISTRY_SERVER_PASSWORD" = var.docker-registry-password,
#     "DOCKER_REGISTRY_SERVER_URL"      = "https://${var.docker-registry-url}",
#   })

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    DOCKER_REGISTRY_SERVER_URL          = "https://mcr.microsoft.com"
    DOCKER_CUSTOM_IMAGE_NAME            = "https://mcr.microsoft.com/azure-app-service/samples/aspnethelloworld:latest"
    DOCKER_REGISTRY_SERVER_USERNAME     = ""
    DOCKER_REGISTRY_SERVER_PASSWORD     = ""
  }

#   site_config {
#     windows_fx_version = "DOCKER|${var.imageAndTag}"
#   }
  
  site_config {
    always_on        = true
    windows_fx_version = "DOCKER|mcr.microsoft.com/azure-app-service/samples/aspnethelloworld:latest"
  }
  
  lifecycle {
    ignore_changes = [
      app_settings.DOCKER_CUSTOM_IMAGE_NAME,
      site_config.0.linux_fx_version,
      site_config.0.scm_type
    ]
  }

  # identity {
  #   type = "SystemAssigned"
  # }
}