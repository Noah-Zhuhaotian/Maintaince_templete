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

# SQL Server variables
variable "createSqlServer" {
  default = false
}

variable "sqlServerName" {
  type = string
}

variable "sqlDatabaseName" {
  type = string
}

variable "sqlAdminUser" {
  type = string
}

variable "sqlAdminPassword" {
  type = string
  sensitive = true
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
## Data Source to get current configuration
#######################################################
data "azurerm_client_config" "current" {}

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

  # Add app settings to connect to Key Vault - will be populated if Key Vault is created
  dynamic "app_settings" {
    for_each = var.createKeyVault ? [1] : []
    content {
      "KeyVaultName" = var.keyVaultName
      "ASPNETCORE_ENVIRONMENT" = var.env
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
    }
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

########################################################
## SQL Server and Database
########################################################
resource "azurerm_mssql_server" "main" {
  count                        = var.createSqlServer ? 1 : 0
  name                         = var.sqlServerName
  location                     = var.location
  resource_group_name          = var.resourceGroupName
  version                      = "12.0"
  administrator_login          = var.sqlAdminUser
  administrator_login_password = var.sqlAdminPassword

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = data.azurerm_client_config.current.object_id
    tenant_id      = var.tenantId
  }
}

resource "azurerm_mssql_database" "main" {
  count       = var.createSqlServer ? 1 : 0
  name        = var.sqlDatabaseName
  server_id   = azurerm_mssql_server.main[0].id
  collation   = "SQL_Latin1_General_CP1_CI_AS"
  sku_name    = "S0"
  max_size_gb = 2
}

# Save DB connection string to Key Vault if both SQL and KeyVault are created
resource "azurerm_key_vault_secret" "db_connection" {
  count        = var.createSqlServer && var.createKeyVault ? 1 : 0
  name         = "ConnectionStrings--DefaultConnection"
  value        = "Server=tcp:${azurerm_mssql_server.main[0].fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main[0].name};Persist Security Info=False;User ID=${var.sqlAdminUser};Password=${var.sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.main[0].id
  depends_on   = [azurerm_key_vault.main, azurerm_mssql_database.main]
}

########################################################
## Output Values
########################################################
output "app_service_url" {
  description = "URL of the deployed App Service"
  value       = "https://${azurerm_windows_web_app.main.default_hostname}"
}

output "sql_server_fqdn" {
  description = "FQDN of the SQL Server"
  value       = var.createSqlServer ? azurerm_mssql_server.main[0].fully_qualified_domain_name : ""
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = var.createKeyVault ? azurerm_key_vault.main[0].name : ""
}

output "app_service_principal_id" {
  description = "Principal ID of the App Service Managed Identity"
  value       = azurerm_windows_web_app.main.identity[0].principal_id
}