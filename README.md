*This project has been created as part of the 42 curriculum by stick0789.*

# Inception

## Description

**Inception** is a 42 School project designed to provide hands-on experience with Docker and containerization technologies. The project focuses on setting up a multi-container application environment using Docker Compose, featuring a complete LEMP stack (Linux, Nginx, MariaDB, PHP-FPM) with WordPress as the primary application.

The main goal of this project is to:
- Understand containerization concepts and Docker architecture
- Learn Docker networking, volumes, and orchestration with Docker Compose
- Set up a production-like environment with multiple interconnected services
- Practice infrastructure as code principles using Docker and environment configuration
- Implement security best practices with secrets management and environment variables

## Project Overview

Inception orchestrates multiple Docker containers to create a fully functional WordPress hosting environment. The architecture includes:

- **Nginx**: Web server and reverse proxy
- **PHP-FPM**: PHP application processor
- **MariaDB**: Relational database management system
- **WordPress**: Content management system
- **Docker Compose**: Container orchestration

## Instructions

### Requirements

- Docker Engine installed (version 20.10+)
- Docker Compose installed (version 1.29+)
- Make utility
- Bash shell
- Linux system (Ubuntu/Debian recommended)

### Installation and Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/stick0789/inception.git
   cd inception
   ```

2. **Configure environment variables**:
   Create a `.env` file in the `srcs/` directory with the required environment variables:
   ```bash
   # Database Configuration
   DB_NAME=wordpress_db
   DB_USER=wordpress_user
   DB_PASSWORD=your_secure_password
   DB_HOST=mariadb
   
   # WordPress Configuration
   WP_URL=localhost
   WP_TITLE=My WordPress Site
   WP_ADMIN_USER=admin
   WP_ADMIN_PASSWORD=admin_password
   WP_ADMIN_EMAIL=admin@example.com
   ```

3. **Build and start containers**:
   ```bash
   make all
   ```

### Make Commands

| Command | Description |
|---------|-------------|
| `make all` | Configure project and start all containers in detached mode |
| `make build` | Build and start containers with fresh builds |
| `make down` | Stop all running containers |
| `make re` | Restart containers (down + all) |
| `make clean` | Stop containers and clean Docker images/volumes |
| `make fclean` | Complete Docker system cleanup including all containers, images, and volumes |

### Accessing the Application

After running `make all`, access the application at:
- **WordPress**: `http://localhost`
- **Database**: MariaDB service runs on port 3306 (internal only)

## Docker and Project Architecture

### Design Choices

This project follows modern containerization best practices:

1. **Separation of Concerns**: Each service (Nginx, PHP-FPM, MariaDB) runs in its own container
2. **Docker Compose Orchestration**: Simplifies multi-container management and networking
3. **Volume Persistence**: Data persists across container restarts
4. **Environment-Driven Configuration**: Flexible deployment across different environments
5. **Custom Docker Images**: Dockerfiles for each service ensure reproducibility and consistency

### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker |
|--------|-----------------|--------|
| **Boot Time** | Minutes | Seconds |
| **Resource Usage** | Heavy (full OS per VM) | Lightweight (shared kernel) |
| **Scalability** | Limited by hardware | Highly scalable |
| **Isolation** | Full OS isolation | Process-level isolation |
| **Use Case** | Multiple OS/kernels needed | Application isolation, microservices |
| **Development Experience** | Slower feedback loop | Faster iteration |
| **Production Readiness** | Mature, proven | Industry standard for modern apps |

**For this project**: Docker provides sufficient isolation while maintaining lightweight, fast deployment ideal for development and testing.

### Secrets vs Environment Variables

| Aspect | Environment Variables | Secrets |
|--------|----------------------|---------|
| **Security** | Visible in process list | Hidden, access-controlled |
| **Use Cases** | Non-sensitive config | Passwords, API keys, tokens |
| **Storage** | Plain text files/shell | Encrypted storage (Docker Secrets, Vault) |
| **Rotation** | Manual or scripted | Managed by orchestration platform |
| **Flexibility** | Easy to change | More rigid, requires orchestration |

**For this project**: Environment variables (via `.env` file) are used for configuration; sensitive credentials should be treated carefully. For production deployments, consider using Docker Secrets or external secret management systems like HashiCorp Vault.

### Docker Network vs Host Network

| Aspect | Docker Network | Host Network |
|--------|----------------|--------------|
| **Isolation** | Full network isolation | No isolation, shares host network |
| **Performance** | Slight overhead | Native performance |
| **Port Binding** | Required for external access | Ports directly exposed |
| **Container Communication** | Via service names | Via localhost/IP |
| **Security** | Better (isolated by default) | Reduced (exposed to host network) |
| **Use Cases** | Multi-container apps, microservices | Single service, performance-critical |

**For this project**: Docker bridge network (custom) is used to allow Nginx, PHP-FPM, and MariaDB containers to communicate securely while remaining isolated from the host network, with only necessary ports exposed.

### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|----------------|------------|
| **Management** | Managed by Docker daemon | Host filesystem dependent |
| **Performance** | Optimized on all platforms | Better on Linux, slower on Mac/Windows |
| **Portability** | Portable across environments | Platform-dependent paths |
| **Permissions** | Simplified | Complex (host UID/GID issues) |
| **Use Cases** | Data persistence, production | Development, quick sharing |
| **Backup** | Easy with `docker volume` commands | Manual or scripted |

**For this project**: 
- **Docker Volumes**: Used for database files (`mariadb_data`) and WordPress content (`wordpress_data`) to ensure data persistence and portability
- **Bind Mounts**: Used during development for source code synchronization, allowing live code editing on the host machine

The combination provides both data durability and development convenience.

## File Structure

```
inception/
├── Makefile              # Build and container management commands
├── srcs/
│   ├── docker-compose.yml  # Docker Compose configuration
│   ├── .env                # Environment variables
│   └── requirements/
│       ├── nginx/          # Nginx service configuration
│       ├── mariadb/        # MariaDB service configuration
│       └── wordpress/      # WordPress service configuration
└── README.md             # This file
```

## Resources

### Docker Documentation
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Guide](https://docs.docker.com/compose/)
- [Docker Networking](https://docs.docker.com/network/)
- [Docker Volumes](https://docs.docker.com/storage/volumes/)

### WordPress Development
- [WordPress Codex](https://codex.wordpress.org/)
- [WordPress PHP Administration](https://developer.wordpress.org/plugins/)
- [WordPress REST API](https://developer.wordpress.org/rest-api/)

### System Administration
- [Nginx Documentation](https://nginx.org/en/docs/)
- [PHP-FPM Manual](https://www.php.net/manual/en/install.fpm.php)
- [MariaDB Documentation](https://mariadb.com/docs/)

### Learning Resources
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [12 Factor App](https://12factor.net/)
- [OWASP Docker Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

## AI Usage

This README.md was generated by **Claude (Anthropic's AI Assistant)** to fulfill the 42 School project requirements. The AI was used for:

- **Content Structure**: Organizing the README according to 42 School guidelines and best practices
- **Docker Concepts**: Creating comprehensive comparison tables (VMs vs Docker, Volumes vs Bind Mounts, etc.)
- **Documentation Quality**: Writing clear, professional descriptions of technical concepts
- **Format and Style**: Ensuring consistency, readability, and proper Markdown formatting
- **Examples and Instructions**: Generating relevant setup instructions and configuration examples

The project implementation itself (Dockerfiles, services, configurations) was created by the human developer. This README acts as documentation to explain those implementation choices and provide guidance for understanding and running the project.

---

**Last Updated**: May 1, 2026
