variable "resourceName" {
  type = string
}

variable "tenantId" {  
  type = string
} 

variable "subscriptionId" {
  type = string
}

variable "resourceGroupName" {
  type = string
}

variable "env" {
  type = string
}

variable "location" {  
  type = string
} 

variable "createServicePlan" {
  default= true
}

variable "servicePlanName" {
  type = string
}

variable "sku" {
  type = string
}

variable "createInsight" {
  default= true
}

variable "insightName" {
  type = string
}

variable "insightLocation" {
  type = string
}

variable "insightWorkspaceId" {
  type = string
}

variable "createKeyVault" {
  default= false
}

variable "keyVaultName" {
  type = string
}

variable "createStorage" {
  default= false
}

variable "storageName" {
  type = string
}

variable "createRedis" {
  default= false
}

variable "redisName" {
  type = string
}

#######################################################
## terraform storage
#######################################################
terraform {
  backend "azurerm" {
    storage_account_name     = "__terraformStorageAccount__"
    container_name           = "__terraformStorageContainer__"
    key                      = "__terraformStateFile__"
    access_key               = "__terraformStorageKey__"
  }
}

#######################################################
## provider
#######################################################
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=3.5.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration  = true
  features {}
}
#######################################################
## Application Service plan
#######################################################
resource "azurerm_service_plan" "main" {
  count               = var.createServicePlan ? 1 : 0
  name                = var.servicePlanName
  location            = var.location
  resource_group_name = var.resourceGroupName
  os_type             = "Windows"
  sku_name            = var.sku
}

########################################################
## Application Service
##########################################################
resource "azurerm_windows_web_app" "main" {
  name                = var.resourceName
  location            = var.location
  resource_group_name = var.resourceGroupName
  service_plan_id = "/subscriptions/${var.subscriptionId}/resourceGroups/${var.resourceGroupName}/providers/Microsoft.Web/serverfarms/${var.servicePlanName}"
  depends_on          = [azurerm_service_plan.main]

  site_config {
    ftps_state               = "FtpsOnly"
    always_on                = true
    application_stack {
      current_stack          = "dotnet"
      dotnet_version         = "v6.0"
    }
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 90
        retention_in_mb   = 100
      }
    }
  }
  
  identity {
    type = "SystemAssigned"
  }
}

########################################################
## App Insight
########################################################
resource "azurerm_application_insights" "main" {
  count               = var.createInsight ? 1 : 0
  name                = var.insightName
  location            = var.insightLocation
  resource_group_name = var.resourceGroupName
  workspace_id        = var.insightWorkspaceId
  application_type    = "web"
}

########################################################
## Key Vault
########################################################
resource "azurerm_key_vault" "main" {
  count                       = var.createKeyVault ? 1 : 0
  name                        = var.keyVaultName
  location                    = var.location
  resource_group_name         = var.resourceGroupName
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenantId
  
  soft_delete_retention_days  = 90
  purge_protection_enabled    = false
  sku_name                    = "standard"

  access_policy {
    tenant_id = var.tenantId
    object_id = azurerm_windows_web_app.main.identity.0.principal_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get","Set","List","Delete"
    ]
  }  
}

########################################################
## Storage Blob
########################################################
resource "azurerm_storage_account" "main" {
  count                    = var.createStorage ? 1 : 0
  name                     = var.storageName
  resource_group_name      = var.resourceGroupName
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"
}

resource "azurerm_storage_container" "main" {
  count                 = var.createStorage ? 1 : 0
  name                  = "container"
  storage_account_name  = azurerm_storage_account.main.0.name
  container_access_type = "private"
}

########################################################
## Redis
########################################################
resource "azurerm_redis_cache" "main" {
  count               = var.createRedis ? 1 : 0
  name                = var.redisName
  location            = var.location
  resource_group_name = var.resourceGroupName
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {}
}