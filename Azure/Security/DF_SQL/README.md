# Azure Data Integration CI/CD Pipeline

This repository contains the CI/CD pipeline and infrastructure as code implementation for deploying an Azure data integration solution using Azure Data Factory, Azure SQL Database, and Azure Key Vault. The pipeline follows infrastructure-as-code best practices and implements the principle of least privilege.

## Solution Architecture

The solution deploys the following Azure resources:

- **Azure Data Factory**: For orchestrating and automating data movement and transformation
- **Azure SQL Database**: As the primary data storage solution
- **Azure Key Vault**: For secure storage of credentials and connection strings
- **Azure RBAC Assignments**: To ensure proper security and access control

## Repository Structure

```
├── azure-pipelines.yml           # Main pipeline definition
├── steps
│   └── deploy-infra              # Infrastructure deployment
│       ├── main.tf               # Main Terraform configuration
│       ├── provision.yml         # Provision job template
│       ├── linked-service.json   # Data Factory linked service definition
│       └── vars.tfvars           # Terraform variables with tokens
└── vars                          # Environment variables
    ├── var-common.yml            # Common variables
    ├── var-dev.yml               # Development environment variables
    ├── var-test.yml              # Test environment variables
    └── var-prod.yml              # Production environment variables
```

## Pipeline Stages

The pipeline consists of the following stages for each environment:

1. **Provision Dev**: Deploy infrastructure in the development environment
2. **Provision Test**: Deploy infrastructure in the test environment
3. **Provision Prod**: Deploy infrastructure in the production environment

Each stage uses the same Terraform code but with different variable sets for each environment.

## Security Features

This solution implements several security best practices:

1. **Key Vault Integration**: SQL Database credentials are stored securely in Azure Key Vault
2. **Managed Identities**: Data Factory uses a managed identity to access Key Vault
3. **RBAC with Least Privilege**: Only the minimum required permissions are granted
4. **TLS Enforcement**: SQL Server enforces TLS 1.2 for connections
5. **Remote State**: Terraform state is stored in Azure Storage with secure access

## Getting Started

### Prerequisites

- Azure DevOps organization and project
- Azure subscription
- Service connections configured in Azure DevOps
- Variable groups with the required secrets

### Setting Up Variable Groups

Create the following variable groups in Azure DevOps:

1. **data-integration-vargroup**
   - `terraformStorageAccessKey`: Access key for Terraform state storage
   - `sqlAdminPasswordDev`: SQL admin password for dev environment
   - `sqlAdminPasswordTest`: SQL admin password for test environment
   - `sqlAdminPasswordProd`: SQL admin password for prod environment

2. **common-vargroup**
   - Any common variables needed across projects

### Running the Pipeline

The pipeline can be run manually or triggered by changes to the main or dev branches. When running the pipeline, it will provision the infrastructure in the selected environment.

To run the pipeline manually:
1. Navigate to the Pipelines section in Azure DevOps
2. Select the pipeline
3. Click "Run Pipeline"
4. Choose the desired environment variables

## Customization

### Environment Configuration

Customize the environment-specific variables in the `vars/*.yml` files:

- **var-dev.yml**: Development environment settings
- **var-test.yml**: Test environment settings
- **var-prod.yml**: Production environment settings

### Infrastructure Changes

To modify the infrastructure components:

1. Update the Terraform code in `steps/deploy-infra/main.tf`
2. Add or remove variables in `steps/deploy-infra/vars.tfvars`
3. Update the pipeline stages in `deploy.yml` as needed

## Best Practices

- Never store sensitive information like passwords or keys in the repository
- Use Azure DevOps variable groups for secrets
- Review and approve infrastructure changes before deploying to production
- Use separate environments for development, testing, and production
- Follow the principle of least privilege for all service identities

## Troubleshooting

Common issues and solutions:

- **Resource conflicts**: Ensure resource names are unique across your subscription
- **Permission errors**: Verify service principal permissions
- **Terraform state issues**: Check storage account access and state file path
- **Key Vault access issues**: Confirm RBAC assignments are correctly configured