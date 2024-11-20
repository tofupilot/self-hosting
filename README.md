# TofuPilot Self Hosting Repository

Welcome to the TofuPilot On-Premise Deployment Guide. This repository provides everything you need to deploy an on-premise version of [TofuPilot](https://www.tofupilot.com), exclusively available for our Enterprise plan clients.

## Prerequisites

1. **Enterprise Plan Subscription**: You must be a TofuPilot client on an Enterprise plan. If you’re not yet subscribed, please contact [our sales team](support@tofupilot.com).
2. **Domain Name**: Purchase a domain name that you’ll use for your self-hosted TofuPilot application (e.g., tofupilot.yourcompany.com).
3. **DNS Configuration**: Create an `A` record in your DNS settings pointing your chosen domain to the public IPv4 address of your server.
4. **Server Access**: Have root or sudo access to a server where you will install TofuPilot.
5. **Valid Email Address**: You’ll need a valid email address for SSL certificate registration with Let’s Encrypt.

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
curl -o ~/deploy.sh https://raw.githubusercontent.com/tofupilot/on-premise/main/deploy.sh
```

3. **Configure the deployment script**:

```bash
nano ~/deploy.sh
```

Locate the following lines:

```bash
DOMAIN_NAME="" # Add your own
EMAIL=""       # Add your own
```

Replace the placeholders:

- **DOMAIN_NAME**: Enter your domain name (e.g., tofupilot.yourcompany.com).
- **EMAIL**: Enter your email address for SSL certificate registration.

4. **Run the deployment script**:

```bash
chmod +x ~/deploy.sh
sudo ./deploy.sh
```

## Post-Installation

After the script completes:

- Access TofuPilot: Open a web browser and navigate to https://your_domain_name (replace with your actual domain). You should see the TofuPilot application interface.
- Verify SSL Certificate: Ensure the SSL certificate is valid and the connection is secure.
- Check Docker Containers: Verify that all Docker containers are running:

```bash
docker-compose ps
```

• Review Logs: Check application logs for any errors:

```bash
docker-compose logs web
```

## Running Locally

If you want to run this setup locally using Docker, you can follow these steps:

```bash
docker-compose up -d
```

This will start both services and make your TofuPilot app available at `http://localhost:3000` with the database running in the background. We also create a network so that our two containers can communicate with each other.

## Updating your deployment

To update TofuPilot to the latest version, run the update script:

```bash
  chmod +x ~/update.sh
  sudo ./update.sh
```
