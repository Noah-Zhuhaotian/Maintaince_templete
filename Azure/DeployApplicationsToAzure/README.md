# Azure Application Deployment Framework
This framework provides a standardized approach to deploy .NET applications to Azure using Azure DevOps pipelines. It includes everything needed to set up a CI/CD pipeline for a Todo API application, complete with database deployment and infrastructure provisioning using Terraform.

### Project Overview
This deployment framework includes:
- **Azure DevOps YAML Pipelines:** For both debug and release environments
- **Terraform Infrastructure as Code:** To provision and configure Azure resources
- **Database Initialization Scripts:** For setting up SQL Server databases
- **Sample .NET API Code:** A Todo API application with Entity Framework Core

### Solution Structure
```bash
Azure/DeployApplicationsToAzure/
├── .gitignore
├── DBScripts/
│   └── init.sql                  # Database initialization script
├── pipeline-default/
│   ├── debug-pipeline.yml        # Pipeline for debug deployments
│   ├── release-pipeline.yml      # Pipeline for release deployments
│   ├── steps/
│   │   ├── build/                # Build and test steps
│   │   ├── deploy-infra/         # Infrastructure provisioning steps
│   │   └── deploy-solution/      # Application deployment steps
│   └── vars/                     # Environment-specific variables
├── scripts/                      # Helper scripts
└── src/                          # Sample .NET API application
```

### Getting Started
**Prerequisites**
- An Azure Subscription
- Azure DevOps organization with permissions to create pipelines
- Azure DevOps Service Connections configured for your Azure Subscription
- SQL Server deployment permissions if using database features
  
**Setup Steps**

1. Clone this repository to your Azure DevOps project
2. Customize the variable files as described in the "Configuration" section below
3. Create the necessary Azure DevOps variable groups:
   - XXXXXX-vargroup (service-specific variables)
   - common-vargroup (shared variables across services)
4. Set up Azure DevOps service connections for your Azure subscriptions
5. Create the necessary Azure resources or ensure you have the correct permissions to create them via the pipeline

### Configuration
Before using this framework, you need to customize several parameters in various files. Key files to update include:
1. Common Variables (`pipeline-default/vars/var-common.yml`)
Replace all `xxxxxx` placeholders with your specific values:

- `appName`: Your application name
- `serviceName`: Your service name (used throughout the pipelines)
- `codeProjectName`: Your code project name
- `tenantId`: Your Azure tenant ID
- `terraformStorageContainer`: Storage container for Terraform state
- `repositoryProjectName`: Your Azure DevOps project name
- `repositoryName`: Your repository name
- `appNumber`: Application identifier number

2. Environment-Specific Variables
Update the following files for each environment:

- `pipeline-default/vars/var-dev.yml`
- `pipeline-default/vars/var-test.yml`
- `pipeline-default/vars/var-prod.yml`

Key parameters to replace in each file:

- `resourceName`: Azure resource name
- `jobEnv`: Environment name used in Azure DevOps
- `serviceEndpointName`: Azure DevOps service connection name
- `terraformStateFile`: Terraform state file name
- `subscriptionId`: Azure subscription ID
- `location`: Azure region (e.g., "North Central US")
- `servicePlanName`: App Service Plan name
- `insightName`: Application Insights name
- `insightLocation`: Application Insights location
- `insightWorkspaceId`: Log Analytics workspace ID
- `sqlServerName`: SQL Server name
- `sqlDatabaseName`: SQL Database name
- `sqlServiceEndpointName`: SQL Server service connection name
- `keyVaultName`: Key Vault name
- `storageName`: Storage account name
- `redisName`: Redis cache name

3. Update Scripts
In `scripts/updateRepositoryValue.ps1`, replace:

- `$tennantId`: Your Azure tenant ID

### Deployment Pipelines
**Debug Pipeline** (`debug-pipeline.yml`)

- Triggered on changes to the dev branch
- Builds the application in debug configuration

**Release Pipeline** (`release-pipeline.yml`)

- Manually triggered
- Builds the application in release configuration
- Provisions infrastructure and deploys to dev, test, and production environments

**Infrastructure Resources**
The Terraform configuration (`pipeline-default/steps/deploy-infra/main.tf`) provisions the following Azure resources:

- App Service Plan
- Windows Web App
- Application Insights
- Key Vault (optional)
- Storage Account (optional)
- Redis Cache (optional)
= SQL Server and Database (optional)

**Database Setup**
The `DBScripts/init.sql` file creates a sample database schema with:

- Users table
- Items table
- UserItems relationship table
- Sample data
- A view and stored procedure

**Sample Application**
The included Todo API application demonstrates:

- Entity Framework Core integration
- Application Insights telemetry
- Key Vault integration
- Database migrations
- RESTful API endpoints for Todo items

**Notes**

- For security reasons, sensitive values like connection strings are stored in Azure Key Vault
- The framework automatically applies database migrations on application startup
- Infrastructure provisioning is separate from application deployment to allow for independent scaling

**Troubleshooting**

- If deployment fails, check the Azure DevOps pipeline logs for detailed error information
- Ensure all service connections have the correct permissions
- Verify that the variable groups contain all required variables
- For database issues, check the SQL firewall rules to ensure the App Service has access