# main.tf - Contains infrastructure definitions for Azure resources

variable "resourceName" {
  type = string
}

variable "dataFactoryName" {
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

variable "keyVaultName" {
  type = string
}

#######################################################
## terraform backend for state storage
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
## provider configuration
#######################################################
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

#######################################################
## Data Source to get current configuration
#######################################################
data "azurerm_client_config" "current" {}

#######################################################
## Create a random string for unique resource names
#######################################################
resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
}

#######################################################
## Azure SQL Server and Database
#######################################################
resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sqlServerName
  resource_group_name          = var.resourceGroupName
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sqlAdminUser
  administrator_login_password = var.sqlAdminPassword
  minimum_tls_version          = "1.2"
  
  tags = {
    environment = var.env
    managed_by  = "terraform"
  }
}

resource "azurerm_mssql_database" "database" {
  name                = var.sqlDatabaseName
  server_id           = azurerm_mssql_server.sql_server.id
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb         = 2
  sku_name            = "Basic"
  zone_redundant      = false
  
  tags = {
    environment = var.env
    managed_by  = "terraform"
  }
}

#######################################################
## Azure Key Vault
#######################################################
resource "azurerm_key_vault" "kv" {
  name                        = var.keyVaultName
  location                    = var.location
  resource_group_name         = var.resourceGroupName
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenantId
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  enable_rbac_authorization   = true
  
  tags = {
    environment = var.env
    managed_by  = "terraform"
  }
}

#######################################################
## Store SQL password in Key Vault
#######################################################
resource "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-password"
  value        = var.sqlAdminPassword
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [
    azurerm_role_assignment.kv_admin
  ]
}

#######################################################
## Azure Data Factory
#######################################################
resource "azurerm_data_factory" "adf" {
  name                = var.dataFactoryName
  location            = var.location
  resource_group_name = var.resourceGroupName
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = {
    environment = var.env
    managed_by  = "terraform"
  }
}

#######################################################
## RBAC Role Assignments
#######################################################
# Assign Key Vault administrator role to deployment identity
resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Assign Key Vault Secrets User role to Data Factory
resource "azurerm_role_assignment" "adf_kv_reader" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_data_factory.adf.identity[0].principal_id
}

#######################################################
## Output Values
#######################################################
output "sql_server_fqdn" {
  description = "FQDN of the SQL Server"
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

output "data_factory_name" {
  description = "Name of the Data Factory"
  value       = azurerm_data_factory.adf.name
}