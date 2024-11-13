# Remote Workflows

A collection of reusable GitHub Actions workflows for standardizing CI/CD processes across projects.

## Available Workflows

### 1. Pipeline Setup

Sets up repository configurations and CI/CD variables.

### 2. Build and Deploy

Handles building and deploying applications to AWS infrastructure (EC2, EKS, or Lambda).

### 3. Code Testing

Performs security scanning using Trivy.

### 4. DAST (Dynamic Application Security Testing)

Performs security scanning using OWASP ZAP.

### 5. NuGet Package Publishing

Handles building, testing, and publishing NuGet packages.

## Setup Instructions

1. Create a new branch named `pipeline-setup` in your repository
2. Copy the contents of the `workflows-setup` directory to your repository
3. Customize `cicd-variables.json` with your project-specific values
4. Push the changes to trigger the pipeline setup workflow

## Required Secrets

- `BOT_TOKEN`: GitHub Personal Access Token with repository and workflow permissions
- `GITLEAKS_LICENSE`: License key for Gitleaks secret scanning
- `NUGET_API_KEY`: API key for publishing to NuGet.org (only required for .NET projects)

## Variables Configuration

The following variables can be configured in `cicd-variables.json`:

```json
{
    "APP_TYPE": "api|web|lambda", // Type of application
    "APP_URL": "https://test.com", // Application URL for DAST scanning
    "PROJECT_DIR": "./", // Root directory of your project
    "DEPLOY_TARGET": "ec2|k8s|lambda", // Deployment target platform
    "PR_REVIEWERS": "username1,username2" // Comma-separated list of PR reviewers
}
```

## Branch Protection

The pipeline setup automatically configures branch protection rules for:

- `main`/`master` (default branch)
- `develop`
- `staging`

Protection includes:

- Required pull request reviews
- Dismissal of stale reviews
- Restriction on force pushes
- Branch restrictions to configured reviewers

## Tag Protection

Release tags (`v*.*.*`) are protected with the following rules:

- No deletion allowed
- No updates allowed
- Non-fast-forward updates blocked
- Beta tags (`v*.*.*-beta`) are excluded from protection

## Organization Variables

For setting up organization-wide variables, use the provided script:

```bash
./org-variables/setup_org_variables.sh -t <github_token> -o <organization_name>
```
