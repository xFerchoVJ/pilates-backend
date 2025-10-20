# Luum Studio Pilates - API Backend

API backend para el sistema de gestión de Luum Studio Pilates, desarrollada con Ruby on Rails 7.2.

## 📋 Descripción

Esta API proporciona los endpoints necesarios para gestionar un estudio de pilates, incluyendo:

- **Autenticación y autorización** con JWT y Google OAuth
- **Gestión de usuarios** con perfiles y recuperación de contraseñas
- **Sesiones de clase** con reservaciones
- **Gestión de salones** y diseños de layout
- **Sistema de lesiones** para usuarios
- **Filtrado y paginación** avanzada
- **Documentación automática** con Swagger

## 🛠️ Tecnologías

- **Ruby 3.1.4**
- **Rails 7.2.2**
- **PostgreSQL 15**
- **Redis 7**
- **Docker & Docker Compose**
- **Sidekiq** para jobs en background
- **JWT** para autenticación
- **Pundit** para autorización
- **RSpec** para testing
- **Swagger/OpenAPI** para documentación

## 🚀 Instalación y Configuración

### Prerrequisitos

- Docker
- Docker Compose

### Configuración

1. **Clona el repositorio:**
   ```bash
   git clone <repository-url>
   cd pilates-backend
   ```

2. **Crea el archivo de variables de entorno:**
   ```bash
   cp .env.example .env
   ```
   
   Configura las siguientes variables en `.env`:

3. **Levanta los servicios:**
   ```bash
   docker-compose up -d
   ```

## 📚 Documentación de la API

Una vez que el proyecto esté corriendo, la documentación interactiva de la API estará disponible en:

**http://localhost:3000/api-docs**

La documentación incluye:
- Todos los endpoints disponibles
- Esquemas de request/response
- Ejemplos de uso
- Autenticación requerida
- Códigos de error

## 🐳 Servicios Docker

- **web**: Aplicación Rails (puerto 3000)
- **db**: PostgreSQL (puerto 5433)
- **redis**: Redis (puerto 6378)
- **sidekiq**: Procesador de jobs en background

## 📝 Notas de Desarrollo

- **No se aceptan contribuciones** - Este es un proyecto privado
- **Desarrollado por**: Fernando
- **Timezone**: America/Mexico_City
- **Queue Adapter**: Sidekiq
- **API Only**: Configurado para ser solo API (sin vistas)

## 🔍 Monitoreo

- **Health Check**: `GET /up`
- **Sidekiq Web UI**: Disponible en desarrollo
- **Logs**: En `log/development.log`

**Luum Studio Pilates API** - Sistema de gestión para estudios de pilates
