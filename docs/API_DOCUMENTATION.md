# API Documentation - Pilates Backend

Esta documentación describe todas las rutas disponibles en el backend de Pilates para que el frontend pueda integrarse correctamente.

## Base URL
```
http://localhost:3000/api/v1
```

## Autenticación

La API utiliza JWT (JSON Web Tokens) para la autenticación. Los tokens de acceso tienen una duración limitada y se pueden renovar usando refresh tokens.

### Headers requeridos
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

## Estructura de Respuesta

### Respuesta exitosa
```json
{
  "success": true,
  "data": { ... },
  "message": "Mensaje opcional"
}
```

### Respuesta de error
```json
{
  "success": false,
  "error": "Mensaje de error",
  "errors": ["Lista de errores de validación"]
}
```

## Endpoints de Autenticación

### 1. Registro de Usuario
**POST** `/signup`

Registra un nuevo usuario en el sistema.

**Request Body:**
```json
{
  "user": {
    "email": "usuario@ejemplo.com",
    "password": "contraseña123",
    "name": "Juan",
    "last_name": "Pérez",
    "phone": "+1234567890",
    "gender": "hombre",
    "birthdate": "1990-01-01",
    "role": "user"
  }
}
```

**Response (201 Created):**
```json
{
  "user": {
    "id": 1,
    "email": "usuario@ejemplo.com",
    "name": "Juan",
    "last_name": "Pérez",
    "phone": "+1234567890",
    "role": "user",
    "gender": "hombre",
    "birthdate": "1990-01-01",
    "profile_picture_url": null
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "refresh_token": "uuid-refresh-token"
}
```

**Response (422 Unprocessable Entity):**
```json
{
  "errors": ["El email ya está en uso", "La contraseña es muy corta"]
}
```

### 2. Inicio de Sesión
**POST** `/login`

Inicia sesión con email y contraseña.

**Request Body:**
```json
{
  "email": "usuario@ejemplo.com",
  "password": "contraseña123"
}
```

**Response (200 OK):**
```json
{
  "user": {
    "id": 1,
    "email": "usuario@ejemplo.com",
    "name": "Juan",
    "last_name": "Pérez",
    "phone": "+1234567890",
    "role": "user",
    "gender": "hombre",
    "birthdate": "1990-01-01",
    "profile_picture_url": null
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "refresh_token": "uuid-refresh-token"
}
```

**Response (401 Unauthorized):**
```json
{
  "error": "email o contraseña inválidos"
}
```

### 3. Inicio de Sesión con Google
**POST** `/google`

Inicia sesión usando Google OAuth con ID token.

**Request Body:**
```json
{
  "id_token": "google-id-token"
}
```

**Response (200 OK):**
```json
{
  "user": {
    "id": 1,
    "email": "usuario@gmail.com",
    "name": "Juan",
    "last_name": "Pérez",
    "phone": null,
    "role": "user",
    "gender": "hombre",
    "birthdate": "1990-01-01",
    "profile_picture_url": null
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "refresh_token": "uuid-refresh-token"
}
```

**Response (401 Unauthorized):**
```json
{
  "error": "token inválido"
}
```

### 4. Renovar Token
**POST** `/refresh`

Renueva el access token usando el refresh token.

**Request Body:**
```json
{
  "refresh_token": "uuid-refresh-token"
}
```

**Response (200 OK):**
```json
{
  "user": {
    "id": 1,
    "email": "usuario@ejemplo.com",
    "name": "Juan",
    "last_name": "Pérez",
    "phone": "+1234567890",
    "role": "user",
    "gender": "hombre",
    "birthdate": "1990-01-01",
    "profile_picture_url": null
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "refresh_token": "new-uuid-refresh-token"
}
```

**Response (401 Unauthorized):**
```json
{
  "error": "refresh inválido"
}
```

### 5. Cerrar Sesión
**POST** `/logout`

Cierra la sesión del usuario actual.

**Headers:** `Authorization: Bearer <access_token>`

**Request Body (opcional):**
```json
{
  "refresh_token": "uuid-refresh-token"
}
```

**Response (200 OK):**
```json
{
  "message": "Logout exitoso"
}
```

### 6. Cerrar Sesión en Todos los Dispositivos
**POST** `/logout_all`

Cierra la sesión en todos los dispositivos del usuario.

**Headers:** `Authorization: Bearer <access_token>`

**Response (200 OK):**
```json
{
  "message": "Logout de todos los dispositivos exitoso"
}
```

**Response (401 Unauthorized):**
```json
{
  "error": "No autorizado"
}
```

### 7. Limpiar Tokens Expirados (Solo Admin)
**POST** `/cleanup_tokens`

Limpia todos los tokens expirados del sistema. Solo disponible para administradores.

**Headers:** `Authorization: Bearer <access_token>`

**Response (200 OK):**
```json
{
  "message": "Limpieza de tokens programada"
}
```

**Response (403 Forbidden):**
```json
{
  "error": "Solo administradores"
}
```

## Endpoints de Usuarios

### 1. Listar Usuarios
**GET** `/users`

Obtiene la lista de todos los usuarios con filtrado y paginación.

**Headers:** `Authorization: Bearer <access_token>`

**Parámetros de Filtrado:**
- `search`: Búsqueda en nombre, apellido y email
- `role`: Filtrar por rol (user, instructor, admin)
- `gender`: Filtrar por género (hombre, mujer, otro)
- `date_from`: Fecha de creación desde (YYYY-MM-DD)
- `date_to`: Fecha de creación hasta (YYYY-MM-DD)
- `page`: Número de página (por defecto: 1)
- `per_page`: Elementos por página (por defecto: 10, máximo: 100)

**Response (200 OK):**
```json
{
  "users": [
    {
      "id": 1,
      "email": "usuario@ejemplo.com",
      "name": "Juan",
      "last_name": "Pérez",
      "phone": "+1234567890",
      "role": "user",
      "gender": "hombre",
      "birthdate": "1990-01-01",
      "profile_picture_url": null
    }
  ],
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

**Nota:** Todos los endpoints que utilizan paginación y filtros devuelven el mismo formato de respuesta estandarizado con los datos serializados usando ActiveModelSerializers y metadatos de paginación consistentes.

**Ejemplos de Filtrado:**
```bash
# Buscar instructores
GET /api/v1/users?search=Juan&role=instructor&page=1&per_page=10

# Filtrar por género y rango de fechas
GET /api/v1/users?gender=mujer&date_from=2024-01-01&date_to=2024-12-31

# Búsqueda textual
GET /api/v1/users?search=María&page=1&per_page=15
```

### 2. Obtener Usuario
**GET** `/users/:id`

Obtiene los datos de un usuario específico.

**Headers:** `Authorization: Bearer <access_token>`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "usuario@ejemplo.com",
    "name": "Juan",
    "last_name": "Pérez",
    "phone": "+1234567890",
    "role": "user",
    "gender": "hombre",
    "birthdate": "1990-01-01",
    "profile_picture_url": null
  }
}
```

**Response (404 Not Found):**
```json
{
  "success": false,
  "message": "Usuario no encontrado"
}
```

### 3. Crear Usuario
**POST** `/users`

Crea un nuevo usuario.

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "user": {
    "email": "nuevo@ejemplo.com",
    "password": "contraseña123",
    "name": "María",
    "last_name": "García",
    "phone": "+1234567891",
    "gender": "mujer",
    "birthdate": "1992-05-15",
    "role": "user"
  }
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Usuario creado exitosamente",
  "data": {
    "id": 2,
    "email": "nuevo@ejemplo.com",
    "name": "María",
    "last_name": "García",
    "phone": "+1234567891",
    "role": "user",
    "gender": "mujer",
    "birthdate": "1992-05-15",
    "profile_picture_url": null
  }
}
```

### 4. Actualizar Usuario
**PATCH/PUT** `/users/:id`

Actualiza los datos de un usuario.

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "user": {
    "name": "Juan Carlos",
    "phone": "+1234567892",
    "gender": "hombre"
  }
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Usuario actualizado exitosamente",
  "data": {
    "id": 1,
    "email": "usuario@ejemplo.com",
    "name": "Juan Carlos",
    "last_name": "Pérez",
    "phone": "+1234567892",
    "role": "user",
    "gender": "hombre",
    "birthdate": "1990-01-01",
    "profile_picture_url": null
  }
}
```

### 5. Eliminar Usuario
**DELETE** `/users/:id`

Elimina un usuario del sistema.

**Headers:** `Authorization: Bearer <access_token>`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Usuario eliminado exitosamente"
}
```

### 6. Enviar Email de Recuperación de Contraseña
**POST** `/users/send_password_reset`

Envía un email con un enlace para recuperar la contraseña.

**Request Body:**
```json
{
  "email": "usuario@ejemplo.com"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Si el correo existe en nuestro sistema, se enviará un enlace de recuperación"
}
```

### 7. Restablecer Contraseña
**PATCH** `/users/reset_password`

Restablece la contraseña usando el token enviado por email.

**Request Body:**
```json
{
  "reset_password_token": "token-del-email",
  "password": "nueva-contraseña123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Contraseña restablecida exitosamente"
}
```

**Response (401 Unauthorized):**
```json
{
  "success": false,
  "message": "Token de restablecimiento de contraseña inválido"
}
```

## Modelos de Datos

### Usuario
```json
{
  "id": "integer",
  "email": "string (único, requerido)",
  "name": "string (requerido)",
  "last_name": "string (requerido)",
  "phone": "string (requerido)",
  "role": "enum (user, instructor, admin)",
  "gender": "enum (hombre, mujer, otro)",
  "birthdate": "date (requerido)",
  "profile_picture_url": "string (URL de la imagen o null)",
  "provider": "string (null para usuarios locales, 'google' para OAuth)",
  "uid": "string (ID del proveedor OAuth)",
  "google_email_verified": "boolean (solo para usuarios Google)"
}
```

## Códigos de Estado HTTP

- **200 OK**: Solicitud exitosa
- **201 Created**: Recurso creado exitosamente
- **400 Bad Request**: Solicitud malformada
- **401 Unauthorized**: No autenticado o token inválido
- **403 Forbidden**: No autorizado para la acción
- **404 Not Found**: Recurso no encontrado
- **422 Unprocessable Entity**: Error de validación
- **500 Internal Server Error**: Error interno del servidor

## Notas Importantes

1. **Autenticación**: Todos los endpoints excepto los de autenticación y recuperación de contraseña requieren el header `Authorization: Bearer <token>`

2. **Roles de Usuario**:
   - `user`: Usuario regular
   - `instructor`: Instructor de pilates
   - `admin`: Administrador del sistema

3. **Tokens**:
   - Los access tokens tienen una duración limitada (1 hora por defecto)
   - Los refresh tokens se rotan en cada renovación
   - Los tokens expirados se pueden limpiar con el endpoint de cleanup

4. **Validaciones**:
   - El email debe ser único y válido
   - La contraseña es requerida solo para usuarios locales (no Google)
   - Todos los campos marcados como requeridos deben estar presentes

5. **Permisos**:
   - Los usuarios solo pueden actualizar su propio perfil
   - Los administradores pueden actualizar cualquier perfil y cambiar roles
   - Solo los administradores pueden limpiar tokens expirados

6. **Recuperación de Contraseña**:
   - Los tokens de recuperación expiran en 2 horas
   - Se envía un email con el enlace de recuperación
   - El token se invalida después de usar

7. **Imágenes de Perfil**:
   - Se manejan con Active Storage
   - La URL se genera automáticamente cuando hay una imagen adjunta
