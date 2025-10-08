# Documentación de la API - Pilates Backend

Bienvenido a la documentación completa de la API del sistema de Pilates. Este archivo sirve como índice principal para acceder a toda la documentación disponible.

## 📋 Tabla de Recursos Disponibles

| Recurso | Descripción | Documentación | Estado | Endpoints | Filtrado |
|---------|-------------|---------------|--------|-----------|----------|
| **Autenticación** | Sistema de login, registro y gestión de tokens JWT | [Ver documentación](./API_DOCUMENTATION.md#endpoints-de-autenticación) | ✅ Completo | 7 endpoints | ❌ |
| **Usuarios** | Gestión de usuarios, perfiles y recuperación de contraseña | [Ver documentación](./API_DOCUMENTATION.md#endpoints-de-usuarios) | ✅ Completo | 7 endpoints | ✅ |
| **Lesiones** | Registro y seguimiento de lesiones de usuarios | [Ver documentación](./INJURIES_API.md) | ✅ Completo | 6 endpoints | ✅ |
| **Clases** | Gestión de clases de pilates | [Ver documentación](./CLASS_SESSIONS_API.md) | ✅ Completo | 5 endpoints | ✅ |
| **Reservas** | Sistema de reservas de clases | [Ver documentación](./RESERVATIONS_API.md) | ✅ Completo | 5 endpoints | ✅ |
| **Filtrado y Paginación** | Sistema de filtrado y paginación para todos los recursos | [Ver documentación](./FILTERING_AND_PAGINATION.md) | ✅ Completo | - | ✅ |
| **Instructores** | Gestión de instructores y sus clases | 🔄 En desarrollo | ⏳ Pendiente | - | - |
| **Pagos** | Sistema de pagos y suscripciones | 🔄 En desarrollo | ⏳ Pendiente | - | - |
| **Notificaciones** | Sistema de notificaciones push y email | 🔄 En desarrollo | ⏳ Pendiente | - | - |

## 🚀 Información General

### Base URL
```
http://localhost:3000/api/v1
```

### Autenticación
La API utiliza JWT (JSON Web Tokens) para la autenticación. Consulta la [documentación de autenticación](./API_DOCUMENTATION.md#autenticación) para más detalles.

### Estructura de Respuesta
```json
{
  "success": true,
  "data": { ... },
  "message": "Mensaje opcional"
}
```

## 📚 Documentación por Recurso

### 🔐 Autenticación
- **Archivo**: [API_DOCUMENTATION.md](./API_DOCUMENTATION.md#endpoints-de-autenticación)
- **Endpoints**: 7
- **Funcionalidades**:
  - Registro de usuarios
  - Login con email/contraseña
  - Login con Google OAuth
  - Renovación de tokens
  - Logout individual y global
  - Recuperación de contraseña
  - Limpieza de tokens expirados

### 👥 Usuarios
- **Archivo**: [API_DOCUMENTATION.md](./API_DOCUMENTATION.md#endpoints-de-usuarios)
- **Endpoints**: 7
- **Funcionalidades**:
  - CRUD completo de usuarios
  - Gestión de perfiles
  - Subida de imágenes de perfil
  - Recuperación de contraseña por email
  - Control de roles (user, instructor, admin)
  - **Filtrado**: Por búsqueda, rol, género y fechas
  - **Paginación**: Soporte completo

### 🩹 Lesiones
- **Archivo**: [INJURIES_API.md](./INJURIES_API.md)
- **Endpoints**: 6
- **Funcionalidades**:
  - CRUD completo de lesiones
  - Registro de tipo y severidad
  - Seguimiento de recuperación
  - Consulta por usuario
  - Control de acceso por roles
  - **Filtrado**: Por usuario, tipo, severidad, estado de recuperación y fechas
  - **Paginación**: Soporte completo

### 🏃‍♀️ Clases de Pilates
- **Archivo**: [CLASS_SESSIONS_API.md](./CLASS_SESSIONS_API.md)
- **Endpoints**: 5
- **Funcionalidades**:
  - CRUD completo de clases
  - Gestión de instructores
  - Control de capacidad
  - Validación de horarios
  - **Filtrado**: Por instructor, capacidad, fechas y horarios
  - **Paginación**: Soporte completo

### 📅 Reservas
- **Archivo**: [RESERVATIONS_API.md](./RESERVATIONS_API.md)
- **Endpoints**: 5
- **Funcionalidades**:
  - CRUD completo de reservas
  - Validación de disponibilidad
  - Control de capacidad de clases
  - **Filtrado**: Por usuario, clase y fechas
  - **Paginación**: Soporte completo

### 🔍 Filtrado y Paginación
- **Archivo**: [FILTERING_AND_PAGINATION.md](./FILTERING_AND_PAGINATION.md)
- **Funcionalidades**:
  - Sistema unificado de filtrado
  - Paginación con metadatos
  - Búsqueda textual
  - Filtros por fechas y rangos
  - Combinación de múltiples filtros

## 🔧 Configuración y Desarrollo

### Requisitos
- Ruby 3.x
- Rails 7.x
- PostgreSQL
- Redis (para Sidekiq)

### Instalación
```bash
# Clonar el repositorio
git clone <repository-url>
cd pilates-backend

# Instalar dependencias
bundle install

# Configurar base de datos
rails db:create
rails db:migrate
rails db:seed

# Iniciar servidor
rails server
```

### Variables de Entorno
```bash
# JWT
JWT_SECRET_KEY=your-secret-key

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Email (para recuperación de contraseña)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

## 📊 Estadísticas de la API

| Métrica | Valor |
|---------|-------|
| **Total de Endpoints** | 30 |
| **Cobertura de Documentación** | 100% |
| **Autenticación** | JWT + OAuth |
| **Base de Datos** | PostgreSQL |
| **Cache** | Redis |
| **Jobs** | Sidekiq |
| **Filtrado y Paginación** | ✅ Implementado |
| **Recursos con Filtrado** | 4 (Usuarios, Lesiones, Clases, Reservas) |

## 🛠️ Herramientas de Desarrollo

### Testing
```bash
# Ejecutar tests
rails test

# Tests con coverage
COVERAGE=true rails test
```

### Linting
```bash
# RuboCop
bundle exec rubocop

# Brakeman (seguridad)
bundle exec brakeman
```

### Base de Datos
```bash
# Ver estado de migraciones
rails db:migrate:status

# Rollback
rails db:rollback

# Reset completo
rails db:reset
```

## 📝 Convenciones de la API

### Nomenclatura
- **Endpoints**: snake_case (`/api/v1/injuries`)
- **Campos**: snake_case (`user_id`, `injury_type`)
- **Respuestas**: camelCase para el frontend (si es necesario)

### Códigos de Estado HTTP
- **200**: OK
- **201**: Created
- **204**: No Content
- **400**: Bad Request
- **401**: Unauthorized
- **403**: Forbidden
- **404**: Not Found
- **422**: Unprocessable Entity
- **500**: Internal Server Error

### Paginación
```json
{
  "users": [...], // o reservations, injuries, class_sessions
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 47,
    "per_page": 10,
    "has_next_page": true,
    "has_prev_page": false
  }
}
```

### Filtrado
Todos los endpoints de listado soportan filtrado mediante parámetros de query:
```bash
# Ejemplos de filtrado
GET /api/v1/users?search=Juan&role=instructor&page=1&per_page=20
GET /api/v1/injuries?severity=grave&recovered=false&page=1&per_page=25
GET /api/v1/class_sessions?instructor_id=3&date_from=2024-01-01
GET /api/v1/reservations?user_id=1&date_from=2024-01-01&date_to=2024-01-31
```

## 🔄 Próximas Funcionalidades

### Completadas ✅
- [x] Sistema de clases de pilates
- [x] Reservas de clases
- [x] Sistema de filtrado y paginación
- [x] Documentación completa de API

### En Desarrollo
- [ ] Gestión avanzada de instructores
- [ ] Sistema de pagos
- [ ] Notificaciones push

### Planificadas
- [ ] Dashboard de administración
- [ ] Reportes y analytics
- [ ] Integración con calendarios
- [ ] Sistema de membresías
- [ ] App móvil

## 📞 Soporte

Para reportar bugs, solicitar funcionalidades o hacer preguntas:

1. **Issues**: Crear un issue en el repositorio
2. **Documentación**: Revisar la documentación específica de cada recurso
3. **Desarrollo**: Contactar al equipo de desarrollo

## 📄 Licencia

Este proyecto está bajo la licencia [MIT](LICENSE).

---

**Última actualización**: Enero 2024  
**Versión de la API**: v1  
**Estado**: En desarrollo activo
