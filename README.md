# Self-Hosting TofuPilot

Welcome to the **TofuPilot Self-Hosting Repository**!

For detailed instructions and a step-by-step guide, visit our [self-hosting documentation](https://www.tofupilot.com/docs/self-hosting).

## Deployment Methods

TofuPilot supports two deployment methods:

### 1. Interactive Deployment

Run the deployment script without any parameters:

```bash
./deploy.sh
```

This will guide you through an interactive setup where you can configure each parameter individually.

### 2. Automated Deployment

For automated deployments in CI/CD environments, you can:

1. Create a `config.env` file containing all required configuration values:

```
# Required values
DOMAIN_NAME=tofupilot.yourdomain.com
EMAIL=your-email@example.com

# Authentication - Configure at least one of these sections
# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Azure AD
AZURE_AD_CLIENT_ID=your-azure-client-id
AZURE_AD_CLIENT_SECRET=your-azure-client-secret
AZURE_AD_TENANT_ID=your-azure-tenant-id

# Email authentication
SMTP_HOST=your-smtp-host
SMTP_PORT=your-smtp-port
SMTP_USER=your-smtp-username
SMTP_PASSWORD=your-smtp-password
EMAIL_FROM=noreply@yourdomain.com

# For custom SSL certificates
USE_CUSTOM_CERTS=true
CERT_PATH=/path/to/ssl.crt
KEY_PATH=/path/to/ssl.key
STORAGE_CERT_PATH=/path/to/storage-ssl.crt
STORAGE_KEY_PATH=/path/to/storage-ssl.key
```

2. Run the deployment script with the `-a` flag for automatic deployment:

```bash
./deploy.sh -a
```

This will read all values from your `config.env` file without prompting for user input.