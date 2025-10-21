# Terraform Azure Project with GitHub Actions

This repository contains Infrastructure as Code (IaC) for deploying and managing Azure resources using Terraform, with automated deployment pipelines via GitHub Actions.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [GitHub Actions Workflows](#github-actions-workflows)
- [Contributing](#contributing)
- [License](#license)

## Overview

This project automates the provisioning and management of Azure infrastructure using Terraform. GitHub Actions workflows enable continuous integration and continuous deployment (CI/CD) for infrastructure changes.

### Key Features

- Infrastructure as Code using Terraform
- Automated CI/CD with GitHub Actions
- State management with Azure Storage Backend
- Environment-based configurations (dev, staging, prod)
- Secure secrets management

## Prerequisites

Before you begin, ensure you have the following installed and configured:

### Required Tools

1. **Terraform** (v1.5.0 or higher)
   - Download: https://www.terraform.io/downloads
   - Verify installation:
     ```bash
     terraform --version
     ```

2. **Azure CLI** (v2.50.0 or higher)
   - Download: https://docs.microsoft.com/cli/azure/install-azure-cli
   - Verify installation:
     ```bash
     az --version
     ```

3. **Git**
   - Download: https://git-scm.com/downloads
   - Verify installation:
     ```bash
     git --version
     ```

4. **jq** (optional, for JSON processing)
   - Download: https://stedolan.github.io/jq/download/
   - Verify installation:
     ```bash
     jq --version
     ```

### Azure Account Requirements

- Active Azure subscription
- Appropriate permissions:
  - Owner or Contributor role on the subscription
  - Ability to create service principals
  - Access to create storage accounts (for Terraform state)

### GitHub Requirements

- GitHub account with repository access
- Appropriate permissions to configure repository secrets and enable workflows

## Project Structure

```
.
├── README.md                  # Project documentation
├── .gitignore                 # Git ignore rules
├── terraform/
│   ├── main.tf               # Main configuration
│   ├── variables.tf           # Variable definitions
│   ├── outputs.tf             # Output definitions
│   ├── terraform.tfvars      # Variable values
│   └── backend.tf             # Remote state configuration
├── .github/
│   └── workflows/
│       ├── plan.yml           # Terraform plan workflow
│       ├── apply.yml          # Terraform apply workflow
│       └── destroy.yml        # Terraform destroy workflow
└── scripts/
    ├── init.sh               # Initialize Terraform environment
    └── cleanup.sh            # Cleanup resources
```

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/your-repo.git
cd your-repo
```

### 2. Authenticate with Azure

```bash
az login
```

For CI/CD pipelines, you'll need to set up a service principal:

```bash
az ad sp create-for-rbac --role Contributor --scopes /subscriptions/{subscription-id}
```

### 3. Initialize Terraform

```bash
cd terraform
terraform init
```

If using remote state backend:

```bash
terraform init -backend-config="resource_group_name=<rg-name>" \
  -backend-config="storage_account_name=<sa-name>" \
  -backend-config="container_name=<container-name>" \
  -backend-config="key=terraform.tfstate"
```

## Configuration

### Environment Variables

Create a `.env.local` file in the project root (not committed to Git):

```bash
# Azure Configuration
ARM_CLIENT_ID="<service-principal-client-id>"
ARM_CLIENT_SECRET="<service-principal-password>"
ARM_SUBSCRIPTION_ID="<subscription-id>"
ARM_TENANT_ID="<tenant-id>"

# Terraform Configuration
TF_VAR_environment="dev"
TF_VAR_location="eastus"
```

### Terraform Variables

Update `terraform/terraform.tfvars` with your specific values:

```hcl
environment = "dev"
location    = "eastus"
project_name = "your-project"
```

## Deployment

### Local Deployment

#### Plan
```bash
cd terraform
terraform plan -out=tfplan
```

#### Apply
```bash
terraform apply tfplan
```

#### Destroy
```bash
terraform destroy
```

### GitHub Actions Deployment

Push changes to trigger automated workflows:

```bash
git add .
git commit -m "Update infrastructure"
git push origin main
```

## GitHub Actions Workflows

This project includes the following GitHub Actions workflows:

### 1. Plan Workflow (`plan.yml`)
- Triggered on: Pull requests to `main` branch
- Actions:
  - Checks out code
  - Initializes Terraform
  - Runs `terraform plan`
  - Posts plan output to PR comments

### 2. Apply Workflow (`apply.yml`)
- Triggered on: Pushes to `main` branch
- Actions:
  - Checks out code
  - Initializes Terraform
  - Runs `terraform apply -auto-approve`
  - Updates infrastructure

### 3. Destroy Workflow (`destroy.yml`)
- Triggered on: Manual workflow dispatch
- Actions:
  - Checks out code
  - Initializes Terraform
  - Runs `terraform destroy -auto-approve`
  - Removes all infrastructure

### Secrets Configuration

Configure the following secrets in GitHub repository settings:

- `ARM_CLIENT_ID` - Azure Service Principal Client ID
- `ARM_CLIENT_SECRET` - Azure Service Principal Password
- `ARM_SUBSCRIPTION_ID` - Azure Subscription ID
- `ARM_TENANT_ID` - Azure Tenant ID
- `TF_STATE_RESOURCE_GROUP` - Resource group for Terraform state
- `TF_STATE_STORAGE_ACCOUNT` - Storage account for Terraform state
- `TF_STATE_CONTAINER` - Container name for Terraform state

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes and commit: `git commit -am 'Add your feature'`
3. Push to the branch: `git push origin feature/your-feature`
4. Submit a pull request for review

## Troubleshooting

### Authentication Issues

If you encounter authentication errors:

```bash
az login
az account set --subscription <subscription-id>
```

### Terraform State Lock

If the state is locked:

```bash
terraform force-unlock <lock-id>
```

### Workflow Failures

Check GitHub Actions logs:
1. Go to repository → Actions tab
2. Select the failed workflow
3. Review the logs for error messages

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions, please open a GitHub issue or contact the project maintainers.

---

**Last Updated:** October 21, 2025
