# Developer Documentation - Inception

## Overview

This document provides comprehensive technical guidance for developers to set up, build, deploy, and manage the Inception project infrastructure. It covers environment configuration, containerization, data persistence, and operational management.

---

## Environment Setup

### Prerequisites

Before setting up the development environment, ensure you have:

- **Docker**: v20.10+ ([Install](https://docs.docker.com/get-docker/))
- **Docker Compose**: v2.0+ ([Install](https://docs.docker.com/compose/install/))
- **GNU Make**: v4.0+ (included on macOS/Linux; install via MinGW on Windows)
- **Git**: v2.0+ ([Install](https://git-scm.com/downloads))
- **Bash**: v4.0+ (for shell scripts)
- **System Requirements**:
  - Minimum 4GB RAM available for Docker
  - At least 10GB free disk space
  - Ports 80, 443, 3306, 5432 available (or configured differently)

### Clone the Repository

```bash
git clone https://github.com/stick0789/inception.git
cd inception
```

### Directory Structure

```
inception/
├── Makefile              # Build and deployment automation
├── docker-compose.yml    # Service orchestration configuration
├── .env.example          # Example environment variables (DO NOT edit)
├── .env                  # Local environment variables (GITIGNORED)
├── srcs/                 # Dockerfiles and service configurations
│   ├── nginx/            # Web server configuration
│   ├── wordpress/        # WordPress application
│   ├── mariadb/          # Database service
│   └── ...
├── conf/                 # Configuration files
├── data/                 # Persistent volumes (GITIGNORED)
├── README.md             # Project overview
├── USER_DOC.md           # User documentation
└── DEV_DOC.md            # Developer documentation (this file)
```

### Environment Configuration

#### 1. Initialize Environment Variables

Copy the example environment file:

```bash
cp .env.example .env
```

#### 2. Configure .env File

Edit `.env` with your development settings:

```bash
# Domain Configuration
DOMAIN_NAME=localhost
CERT_PATH=/etc/ssl/certs
KEY_PATH=/etc/ssl/private

# MariaDB Configuration
DB_NAME=inception_db
DB_USER=dev_user
DB_PASSWORD=$(openssl rand -base64 16)
DB_ROOT_PASSWORD=$(openssl rand -base64 16)

# WordPress Configuration (if applicable)
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=$(openssl rand -base64 16)
WP_ADMIN_EMAIL=admin@localhost

# Service Ports
HTTP_PORT=80
HTTPS_PORT=443
DB_PORT=3306
```

⚠️ **IMPORTANT**: 
- Add `.env` to `.gitignore` if not already present
- Never commit `.env` files
- For production, use secrets management systems (Docker Secrets, HashiCorp Vault)
- Regenerate all passwords for each environment

#### 3. Generate SSL Certificates (Development)

```bash
mkdir -p certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/inception.key \
  -out certs/inception.crt \
  -subj "/C=ES/ST=Madrid/L=Madrid/O=42/CN=localhost"
```

⚠️ **Note**: For production, use valid certificates from a Certificate Authority (Let's Encrypt, DigiCert, etc.)

#### 4. Secrets Management

For sensitive credentials:

```bash
# Using Docker Secrets (for Swarm mode)
echo "your_secret_password" | docker secret create db_password -

# Or use .env with restricted permissions
chmod 600 .env
```

---

## Building and Launching the Project

### Using Makefile

The Makefile automates common tasks. View all available targets:

```bash
make help
```

### Build Process

#### 1. Build All Services

```bash
make build
```

This executes:
- Reads `docker-compose.yml` and `.env`
- Builds Docker images from Dockerfiles in `srcs/`
- Creates networks and volumes
- Prepares containers for deployment

#### 2. Start Services in Detached Mode

```bash
make up
```

Or with logs:

```bash
make up logs
```

#### 3. Combined Build and Start

```bash
make
```

Equivalent to: `docker-compose up -d --build`

### Full Initialization Workflow

```bash
# 1. Clean previous state (optional)
make clean

# 2. Build images
make build

# 3. Start services
make up

# 4. Verify status
make status

# 5. Check logs
make logs
```

### Using Docker Compose Directly

For more granular control:

```bash
# Build specific service
docker-compose build nginx

# Build with no cache
docker-compose build --no-cache

# Start specific services
docker-compose up -d mariadb
docker-compose up -d nginx

# Start all with resource limits
docker-compose up -d --max-parallel-pulls 2
```

---

## Container and Volume Management

### Container Operations

#### View Running Containers

```bash
# Docker Compose format
docker-compose ps

# Docker format (shows more details)
docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"

# With size information
docker ps --size
```

#### Execute Commands Inside Containers

```bash
# Interactive shell access
docker-compose exec <service_name> /bin/bash

# Examples
docker-compose exec nginx bash
docker-compose exec mariadb bash
docker-compose exec wordpress bash

# Run single commands
docker-compose exec mariadb mysql -u root -p$DB_ROOT_PASSWORD -e "SHOW DATABASES;"

# Run with environment variables
docker-compose exec -e LOG_LEVEL=DEBUG nginx nginx -t
```

#### View Container Logs

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs nginx

# Follow mode (real-time)
docker-compose logs -f nginx

# Last 100 lines, follow mode
docker-compose logs -f --tail 100 nginx

# With timestamps
docker-compose logs --timestamps nginx

# Filter by time
docker-compose logs --since 2026-05-01T10:00:00 nginx
```

#### Inspect Container Details

```bash
# View configuration
docker-compose inspect nginx

# View environment variables
docker inspect <container_id> | grep -A 20 "Env"

# View volume mounts
docker inspect <container_id> | grep -A 10 "Mounts"

# View network configuration
docker network inspect inception_default
```

#### Restart Containers

```bash
# Restart specific service
docker-compose restart nginx

# Restart with rebuild
make restart

# Stop then start (full cycle)
docker-compose down
docker-compose up -d
```

#### Remove Containers

```bash
# Stop and remove running containers
docker-compose down

# Remove containers and volumes
docker-compose down -v

# Remove everything (containers, volumes, networks, images)
docker-compose down -v --rmi all
```

### Volume Management

#### Understand Volume Types

| Type | Use Case | Persistence |
|------|----------|-------------|
| Named Volumes | Database data, persistent storage | Yes, survives container restart |
| Bind Mounts | Source code, config files | Yes, synced with host filesystem |
| Tmpfs | Temporary data, cache | No, lost on container stop |

#### View Volumes

```bash
# List all volumes
docker volume ls

# Inspect specific volume
docker volume inspect inception_mariadb_data

# Find volume mount points
docker inspect <container_id> --format='{{json .Mounts}}' | jq
```

#### Create and Manage Volumes

```bash
# Create named volume
docker volume create inception_db_data

# Clean up unused volumes
docker volume prune

# Backup volume data
docker run --rm -v inception_mariadb_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/mariadb_backup.tar.gz -C /data .

# Restore volume data
docker run --rm -v inception_mariadb_data:/data -v $(pwd):/backup \
  alpine tar xzf /backup/mariadb_backup.tar.gz -C /data
```

#### Volume Configuration in docker-compose.yml

```yaml
services:
  mariadb:
    volumes:
      - db_data:/var/lib/mysql              # Named volume
      - ./conf/mariadb:/etc/mysql/conf.d    # Bind mount
      - /tmp/tmpdata:/var/tmp               # Tmpfs

volumes:
  db_data:
    driver: local
    driver_opts:
      type: tmpfs
      device: tmpfs
      o: size=100m,uid=1000
```

---

## Data Persistence and Storage

### Data Location

All persistent data is stored in the `data/` directory structure:

```
data/
├── mariadb/              # Database files
│   └── mysql/            # Database tables and configuration
├── wordpress/            # WordPress files and uploads
│   ├── wp-content/       # Plugins, themes, uploads
│   └── wp-config.php     # WordPress configuration
├── volumes/              # Other service volumes
└── backups/              # Database and file backups
```

### Persistence Mechanism

#### Named Volumes

```yaml
# docker-compose.yml example
volumes:
  db_data:
    driver: local
    driver_opts:
      type: local
```

Located in Docker's data directory:
- **Linux/Mac**: `/var/lib/docker/volumes/inception_db_data/_data/`
- **Windows**: `C:\ProgramData\Docker\volumes\inception_db_data\_data\`
- **WSL2**: `\\wsl$\docker-desktop-data\version-pack-data\community\docker\volumes\`

#### Bind Mounts

```yaml
# docker-compose.yml example
volumes:
  - ./data/mysql:/var/lib/mysql
```

Data synchronized with host filesystem at `./data/mysql/`

### Data Backup and Recovery

#### Full System Backup

```bash
# Backup all volumes and configuration
docker-compose exec mariadb mysqldump -u root -p$DB_ROOT_PASSWORD --all-databases \
  > data/backups/mysql_dump_$(date +%Y%m%d_%H%M%S).sql

# Backup uploaded files
tar -czf data/backups/wordpress_$(date +%Y%m%d_%H%M%S).tar.gz data/wordpress/
```

#### Database Restore

```bash
# Restore from SQL dump
docker-compose exec -T mariadb mysql -u root -p$DB_ROOT_PASSWORD < data/backups/mysql_dump_TIMESTAMP.sql
```

#### Automated Backups (Cron)

```bash
# Create backup script: scripts/backup.sh
#!/bin/bash
BACKUP_DIR="./data/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

docker-compose exec mariadb mysqldump -u root -p$DB_ROOT_PASSWORD --all-databases \
  | gzip > "$BACKUP_DIR/mysql_$TIMESTAMP.sql.gz"

tar -czf "$BACKUP_DIR/wordpress_$TIMESTAMP.tar.gz" data/wordpress/

# Keep only last 7 days of backups
find "$BACKUP_DIR" -mtime +7 -delete
```

Schedule with crontab:
```bash
# Run backup daily at 2 AM
0 2 * * * cd /path/to/inception && bash scripts/backup.sh
```

### Database Schema Inspection

```bash
# Connect to database
docker-compose exec mariadb mysql -u $DB_USER -p$DB_PASSWORD $DB_NAME

# Inside mysql shell
SHOW TABLES;
DESCRIBE table_name;
SELECT * FROM table_name LIMIT 10;
```

### Verify Data Persistence

```bash
# Test volume persistence by stopping and restarting
docker-compose stop mariadb
docker-compose start mariadb

# Verify data still exists
docker-compose exec mariadb mysql -u root -p$DB_ROOT_PASSWORD -e "SELECT COUNT(*) FROM $DB_NAME.wp_posts;"
```

---

## Advanced Container Operations

### Resource Limits and Monitoring

#### Set Resource Limits

```yaml
# docker-compose.yml
services:
  mariadb:
    deploy:
      resources:
        limits:
          cpus: '1.5'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

#### Monitor Resource Usage

```bash
# Real-time statistics
docker stats

# Specific container
docker stats inception_mariadb_1

# Non-streaming output
docker stats --no-stream
```

### Network Configuration

```bash
# List networks
docker network ls

# Inspect network
docker network inspect inception_default

# Services communicate using service names
# Example from nginx config: proxy_pass http://wordpress:9000;
```

### Debugging and Troubleshooting

#### Container Health Checks

```yaml
# docker-compose.yml example
services:
  mariadb:
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s
```

#### View Container Exit Codes

```bash
# Container exited unexpectedly
docker-compose ps

# Check exit code (0 = success, non-zero = error)
docker inspect <container_id> --format='{{.State.ExitCode}}'

# View detailed container state
docker inspect <container_id> --format='{{json .State}}' | jq
```

#### Debug with Verbose Output

```bash
# Enable debug mode
DOCKER_BUILDKIT=1 docker-compose build --verbose

# View Makefile execution details
make -d build

# Trace script execution
bash -x scripts/init.sh
```

### Multi-stage Builds

```dockerfile
# srcs/nginx/Dockerfile example
FROM alpine:3.18 as builder
RUN apk add --no-cache build-base openssl-dev
COPY . /src
RUN cd /src && make

FROM alpine:3.18
COPY --from=builder /src/nginx /usr/local/sbin/
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
```

---

## Development Workflow

### Local Development Loop

```bash
# 1. Start containers
make up

# 2. Edit source files (live reload if configured)
vim srcs/wordpress/index.php

# 3. Rebuild affected service
docker-compose build wordpress
docker-compose up -d wordpress

# 4. Verify changes
docker-compose logs -f wordpress

# 5. Stop when done
make down
```

### Using Make Targets

```bash
# View available targets
make help

# Common targets
make build      # Build all images
make up         # Start services
make down       # Stop services
make restart    # Restart services
make status     # Show container status
make logs       # View logs
make clean      # Clean volumes and containers
make fclean     # Complete cleanup including images
```

### Creating Custom Makefile Targets

```makefile
# Add to Makefile
.PHONY: migrate
migrate:
	docker-compose exec wordpress wp migrate
	@echo "✓ Database migration complete"

.PHONY: test
test:
	docker-compose exec nginx sh -c "nginx -t && echo '✓ Nginx config valid'"
	docker-compose exec mariadb mysqladmin ping && echo "✓ Database responding"
```

---

## Performance Optimization

### Build Optimization

```bash
# Use build cache efficiently
docker-compose build --parallel

# Inspect build stages
docker history inception_nginx:latest

# Reduce image size
docker image ls --format "table {{.Repository}}\t{{.Size}}"
```

### Runtime Optimization

```yaml
# docker-compose.yml
services:
  mariadb:
    environment:
      MYSQL_SLOW_QUERY_LOG: "1"
      LONG_QUERY_TIME: "2"
    command: --slow-query-log=/var/log/mysql/slow-query.log
```

### Volume Performance

```bash
# For Mac/Windows: use named volumes instead of bind mounts for better performance
# Bind mounts slower due to filesystem sync overhead
volumes:
  - data:/var/lib/mysql          # Named volume (faster)
  - ./config:/etc/nginx/conf      # Bind mount (slower, but needed for config)
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/build.yml
name: Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build with Make
        run: make build
      - name: Start services
        run: make up
      - name: Run tests
        run: make test
      - name: Cleanup
        run: make down
```

---

## Troubleshooting

### Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Port already in use | Another process using port 80/443 | `lsof -i :80` or change `HTTP_PORT` in `.env` |
| Container won't start | Image build failure | Check logs: `docker-compose logs` |
| Database connection timeout | Service not ready | Wait for healthcheck: `docker-compose logs mariadb` |
| Permission denied on volumes | Ownership mismatch | `docker-compose exec mariadb chown -R mysql:mysql /var/lib/mysql` |
| Out of disk space | Unused images/volumes accumulating | `docker system prune -a` |
| Network isolation issues | Container networking misconfigured | Verify: `docker network inspect inception_default` |

### Get Help

```bash
# View Docker daemon logs (Linux)
sudo journalctl -u docker

# View Docker logs (Mac)
log stream --process docker --level debug

# Check system resources
docker system df
docker system events
```

---

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Specification](https://github.com/compose-spec/compose-spec)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Container Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

---

## AI Usage Notice

This documentation was created with the assistance of AI. While efforts have been made to ensure technical accuracy and comprehensiveness, developers should:

- Verify all instructions align with your specific implementation and infrastructure
- Test all procedures in development environments before production deployment
- Review generated configurations against your organization's security policies
- Consult official Docker and Compose documentation for authoritative information
- Report any inaccuracies or gaps in documentation for continuous improvement

For production environments, conduct thorough security audits and compliance reviews of all AI-generated content.

