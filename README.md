# TofuPilot Self-Hosting Repository

Welcome to the TofuPilot Self-Hosting Deployment Guide. This repository provides everything you need to self-host [TofuPilot](https://www.tofupilot.com), exclusively available for our Enterprise plan clients. This includes the TofuPilot web app, a database and object storage.

## Prerequisites

1. **Enterprise Plan Subscription**: You must be a TofuPilot client on an Enterprise plan. If you’re not yet subscribed, please contact [our sales team](support@tofupilot.com).
2. **Domain Name**: A domain name that you will use for your self-hosted TofuPilot application (e.g., tofupilot.yourcompany.com).
3. **Domain Name**: A sub-domain name that you will use for the object storage of your self-hosted TofuPilot application (defaults to storage.DOMAIN_NAME).
4. **DNS Configuration**: Create two `A` records in your DNS settings pointing both chosen domain to the public IPv4 address of your server.
5. **Server Access**: Have root or sudo access to a server where you will install TofuPilot.
6. **Valid Email Address**: You will need a valid email address for SSL certificate registration with Let’s Encrypt.

## System Requirements

Ensure your server meets the following minimum requirements:

- **Operating System**: Ubuntu 20.04 LTS or later (64-bit)
- **CPU**: 2 cores or more
- **RAM**: 4 GB minimum
- **Storage**: 20 GB of free disk space
- **Network**: Open ports 80 (HTTP) and 443 (HTTPS)

## Quickstart

1. **SSH into your server**:

```bash
ssh root@your_server_ip
```

2. **Download the deployment script**:

```bash
curl -o ~/deploy.sh https://raw.githubusercontent.com/tofupilot/self-hosting/main/deploy.sh
```

3. **Configure the deployment script**:

```bash
nano ~/deploy.sh
```

Locate the following lines:

```bash
# Main domain name for TofuPilot (e.g., tofupilot.example.com)
DOMAIN_NAME="" # YOUR_DOMAIN_NAME_FOR_TOFUPILOT

# Email associated with your domain name (used for SSL certificates)
EMAIL="" # THE_EMAIL_ASSOCIATED_WITH_YOUR_DOMAIN_NAME

# Storage domain name (used for object storage service)
STORAGE_DOMAIN_NAME="storage.$DOMAIN_NAME" # Default value; replace if desired
```

Replace the placeholders:

- **DOMAIN_NAME**: Enter your domain name (e.g., tofupilot.yourcompany.com).
- **EMAIL**: Enter your email address for SSL certificate registration.

(Optional): Replace the placeholder:

- **STORAGE_DOMAIN_NAME**: Defaults to storage.$DOMAIN_NAME. This must match the DNS `A` record you registered.

4. **Configure authentication**:

   To authenticate with your TofuPilot instance, you must configure at least one of the three authentication methods—Azure Active Directory (Azure AD), Google, or Email—but you can also configure any combination of two or all three for added flexibility.

   **Configuring Authentication with Azure Active Directory (Azure AD)**:

   - In https://portal.azure.com search for "Microsoft Entra ID", and select your organization.
   - Next, in the left menu expand the "Manage" accordion and then go to "App Registration" , and create a new one.
   - Pay close attention to "Who can use this application or access this API?"
     - This allows you to scope access to specific types of user accounts
     - Only your tenant, all azure tenants, or all azure tenants and public Microsoft accounts (Skype, Xbox, Outlook.com, etc.)
   - When asked for a redirection URL, select the platform type "Web" and use https://{DOMAIN_NAME>}/api/auth/callback/azure-ad
   - After your App Registration is created, under "Client Credential" create your Client secret.
   - Now copy your:
     - Application (client) ID
     - Directory (tenant) ID
     - Client secret (value)

   In `deploy.sh`, replace the following placeholders:

   ```bash
   AZURE_AD_CLIENT_ID=""
   AZURE_AD_TENANT_ID=""
   AZURE_AD_CLIENT_SECRET=""
   ```

   **Configuring Authentication with Google**:

   - See https://console.developers.google.com/apis/credentials
   - When asked for the "Authorized redirect URIs", use https://{DOMAIN_NAME}/api/auth/callback/google

   **Configuring Authentication with Email**:

   In `deploy.sh`, replace the following placeholders:

   ```bash
    # SMTP Credentials (for email authentication)
    SMTP_HOST=""
    SMTP_PASSWORD=""
    SMTP_PORT="587"
    SMTP_USER=""
    EMAIL_FROM="" # Example: tofupilot-auth@your-domain
   ```

5. **Run the deployment script**:

```bash
chmod +x ~/deploy.sh
sudo bash deploy.sh
```

## Post-Installation

After the script completes:

- Access TofuPilot: Open a web browser and navigate to https://{YOUR_DOMAIN}. You should see the TofuPilot application interface.
- Verify SSL Certificate: Ensure the SSL certificate is valid and the connection is secure.
- Check Docker Containers: Verify that all Docker containers are running:

```bash
docker-compose ps
```

• Review Logs: Check application logs for any errors:

```bash
docker-compose logs tofupilot
```

## Updating your deployment

To update TofuPilot to the latest version, run the update script:

```bash
chmod +x ~/update.sh
sudo bash update.sh
```
