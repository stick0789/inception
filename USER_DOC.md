# User Documentation - Inception

## Overview

This document provides clear and simple instructions for end users and administrators to understand, operate, and manage the Inception project services.

---

## Services Provided by the Stack

The Inception project is a 42 Project that implements a complete infrastructure stack using containerization. The stack includes:

- **Web Server**: Serves your website and applications
- **Administration Panel**: Provides administrative interface for system management
- **Database Services**: Persistent data storage for application data
- **Networking Services**: Internal and external communication infrastructure
- **SSL/TLS Security**: Encrypted connections for secure communications

All services are containerized and orchestrated for seamless deployment and management.

---

## Starting and Stopping the Project

### Prerequisites

Before starting the project, ensure you have:
- Docker installed and running on your system
- Docker Compose installed
- Sufficient disk space for containers and data volumes
- Required ports available (typically 80 for HTTP, 443 for HTTPS)

### Starting the Project

1. Navigate to the project root directory:
   ```bash
   cd /path/to/inception
   ```

2. Build and start all services:
   ```bash
   make
   ```

   Or using Docker Compose directly:
   ```bash
   docker-compose up -d
   ```

3. Wait for all services to initialize (usually 30-60 seconds)

4. Verify services are running:
   ```bash
   make status
   ```
   Or:
   ```bash
   docker-compose ps
   ```

### Stopping the Project

1. Navigate to the project root directory:
   ```bash
   cd /path/to/inception
   ```

2. Stop all services:
   ```bash
   make down
   ```

   Or using Docker Compose directly:
   ```bash
   docker-compose down
   ```

### Restarting the Project

```bash
make restart
```

---

## Accessing the Website and Administration Panel

### Website Access

Once the project is running:

1. Open your web browser
2. Navigate to: `https://localhost` (HTTPS is recommended for security)
3. If prompted about SSL certificate, accept the self-signed certificate (this is normal in development)

### Administration Panel Access

1. Open your web browser
2. Navigate to: `https://localhost/admin` (or the configured admin path)
3. Log in with your administrator credentials (see Credentials section below)

### Troubleshooting Access Issues

- **Connection refused**: Ensure services are running with `make status`
- **SSL certificate errors**: These are expected with self-signed certificates in development
- **Page not loading**: Check that all containers are healthy: `docker-compose ps`
- **404 errors**: Verify the correct URL path and that services have fully initialized

---

## Locating and Managing Credentials

### Credentials Location

Credentials are typically stored in:

- **Environment variables**: `.env` file in the project root
- **Configuration files**: `config/` directory
- **Docker secrets**: Managed by Docker for sensitive data

⚠️ **IMPORTANT**: Never commit `.env` files or credentials to version control.

### Common Credentials

| Service | Username | Password | Location |
|---------|----------|----------|----------|
| Web Server | (see admin panel) | (see admin panel) | `.env` file |
| Administration Panel | admin | (see `.env`) | `.env` file |
| Database | root | (see `.env`) | `.env` file |

### Accessing Credentials

1. View your credentials:
   ```bash
   cat .env
   ```

2. To change credentials:
   - Edit the `.env` file
   - Restart services: `make restart`

3. For database access:
   ```bash
   docker-compose exec database mysql -u root -p
   ```
   When prompted, enter the password from `.env`

### Credential Best Practices

- ✅ Use strong, unique passwords for production
- ✅ Rotate credentials regularly
- ✅ Store backup copies in a secure location
- ✅ Restrict `.env` file permissions: `chmod 600 .env`
- ❌ Never share credentials via email or chat
- ❌ Never hardcode credentials in source code

---

## Checking Service Health and Status

### Quick Status Check

```bash
make status
```

Or:
```bash
docker-compose ps
```

This shows all containers with their current status.

### Detailed Service Health

```bash
docker-compose logs
```

View logs for all services in real-time.

### Service-Specific Logs

```bash
docker-compose logs <service-name>
```

Example:
```bash
docker-compose logs web
docker-compose logs database
```

### Verifying Individual Services

#### Web Server
```bash
curl -k https://localhost
```
Should return HTTP 200 with webpage content.

#### Database
```bash
docker-compose exec database mysql -u root -p -e "SELECT 1"
```
Should execute successfully and return `1`.

#### Administration Panel
```bash
curl -k https://localhost/admin
```
Should return HTTP 200 with admin panel content.

### Resource Usage Monitoring

```bash
docker stats
```

Shows CPU, memory, and network usage for all containers.

### Container Health Signals

- **Status: Up**: Service is running normally
- **Status: Exit**: Service has stopped (check logs for errors)
- **Status: Unhealthy**: Service detected a problem (check logs)

### Troubleshooting Common Issues

| Issue | Solution |
|-------|----------|
| Container keeps restarting | Check logs: `docker-compose logs <service>` |
| Services won't start | Verify ports are not in use: `netstat -tuln` |
| High memory usage | Increase Docker memory limit or reduce concurrent connections |
| Database won't initialize | Check `.env` credentials, ensure `data/` directory is writable |
| SSL certificate errors | Regenerate certificates or trust self-signed cert in browser |

---

## Maintenance Commands

### View All Available Commands

```bash
make help
```

### Clean Up Unused Data

```bash
make clean
```

### Rebuild Containers

```bash
make rebuild
```

### View Container Logs

```bash
make logs
```

---

## Support and Additional Resources

For additional help:
- Check the `README.md` for development information
- Review individual service documentation in `docs/` directory
- Inspect Dockerfiles in `srcs/` for service configuration details

---

## AI Usage Notice

This documentation was created with the assistance of AI. While efforts have been made to ensure accuracy and clarity, please verify all instructions match your specific implementation and configuration. For production environments, it is recommended to review and test all procedures before implementation.

