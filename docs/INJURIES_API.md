# API de Lesiones (Injuries) - Pilates Backend

Esta documentación describe todos los endpoints disponibles para la gestión de lesiones en el sistema de Pilates.

## Base URL
```
http://localhost:3000/api/v1
```

## Autenticación

Todos los endpoints requieren autenticación JWT.

### Headers requeridos
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

## Endpoints de Lesiones

### 1. Listar Todas las Lesiones
**GET** `/injuries`

Obtiene la lista de todas las lesiones en el sistema con filtrado y paginación.

**Headers:** `Authorization: Bearer <access_token>`

**Parámetros de Filtrado:**
- `user_id`: Filtrar por ID de usuario
- `injury_type`: Filtrar por tipo de lesión
- `severity`: Filtrar por severidad (leve, moderada, grave)
- `recovered`: Filtrar por estado de recuperación (true/false)
- `date_from`: Fecha de ocurrencia desde (YYYY-MM-DD)
- `date_to`: Fecha de ocurrencia hasta (YYYY-MM-DD)
- `search`: Búsqueda en tipo de lesión y descripción
- `page`: Número de página (por defecto: 1)
- `per_page`: Elementos por página (por defecto: 10, máximo: 100)

**Response (200 OK):**
```json
{
  "injuries": [
    {
      "id": 1,
      "injury_type": "Lesión de rodilla",
      "description": "Dolor en la rodilla izquierda durante ejercicios de flexión",
      "severity": "moderada",
      "date_ocurred": "2024-01-15",
      "recovered": false,
      "created_at": "2024-01-20T10:30:00.000Z",
      "updated_at": "2024-01-20T10:30:00.000Z",
      "user": {
        "id": 1,
        "email": "usuario@ejemplo.com",
        "name": "Juan",
        "last_name": "Pérez"
      }
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 25,
    "per_page": 10,
    "has_next_page": true,
    "has_prev_page": false
  }
}
```

**Nota:** Este endpoint utiliza el formato de respuesta estandarizado con datos serializados usando ActiveModelSerializers y metadatos de paginación consistentes.

**Ejemplos de Filtrado:**
```bash
# Lesiones no recuperadas de severidad grave
GET /api/v1/injuries?severity=grave&recovered=false&page=1&per_page=20

# Búsqueda por tipo de lesión
GET /api/v1/injuries?user_id=1&search=rodilla

# Lesiones en un rango de fechas
GET /api/v1/injuries?date_from=2024-01-01&date_to=2024-06-30
```

### 2. Obtener Lesión Específica
**GET** `/injuries/:id`

Obtiene los datos de una lesión específica.

**Headers:** `Authorization: Bearer <access_token>`

**Response (200 OK):**
```json
{
  "id": 1,
  "injury_type": "Lesión de rodilla",
  "description": "Dolor en la rodilla izquierda durante ejercicios de flexión",
  "severity": "moderada",
  "date_ocurred": "2024-01-15",
  "recovered": false,
  "created_at": "2024-01-20T10:30:00.000Z",
  "updated_at": "2024-01-20T10:30:00.000Z",
  "user": {
    "id": 1,
    "email": "usuario@ejemplo.com",
    "name": "Juan",
    "last_name": "Pérez"
  }
}
```

**Response (404 Not Found):**
```json
{
  "status": 404,
  "error": "Not Found",
  "exception": "#<ActiveRecord::RecordNotFound: Couldn't find Injury with 'id'=\"1\">"
}
```

### 3. Crear Nueva Lesión
**POST** `/injuries`

Crea una nueva lesión en el sistema.

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "injury": {
    "user_id": 1,
    "injury_type": "Lesión de espalda",
    "description": "Dolor lumbar después de ejercicios de flexión",
    "severity": "leve",
    "date_ocurred": "2024-01-20",
    "recovered": false
  }
}
```

**Response (201 Created):**
```json
{
  "id": 2,
  "injury_type": "Lesión de espalda",
  "description": "Dolor lumbar después de ejercicios de flexión",
  "severity": "leve",
  "date_ocurred": "2024-01-20",
  "recovered": false,
  "created_at": "2024-01-20T11:00:00.000Z",
  "updated_at": "2024-01-20T11:00:00.000Z",
  "user": {
    "id": 1,
    "email": "usuario@ejemplo.com",
    "name": "Juan",
    "last_name": "Pérez"
  }
}
```

**Response (422 Unprocessable Entity):**
```json
{
  "injury_type": ["can't be blank"],
  "severity": ["leve no es una severidad válida, debe ser leve, moderada o grave"]
}
```

### 4. Actualizar Lesión
**PATCH/PUT** `/injuries/:id`

Actualiza los datos de una lesión existente.

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "injury": {
    "description": "Dolor lumbar mejorado después de tratamiento",
    "severity": "leve",
    "recovered": true
  }
}
```

**Response (200 OK):**
```json
{
  "id": 2,
  "injury_type": "Lesión de espalda",
  "description": "Dolor lumbar mejorado después de tratamiento",
  "severity": "leve",
  "date_ocurred": "2024-01-20",
  "recovered": true,
  "created_at": "2024-01-20T11:00:00.000Z",
  "updated_at": "2024-01-20T11:30:00.000Z",
  "user": {
    "id": 1,
    "email": "usuario@ejemplo.com",
    "name": "Juan",
    "last_name": "Pérez"
  }
}
```

**Response (422 Unprocessable Entity):**
```json
{
  "severity": ["grave no es una severidad válida, debe ser leve, moderada o grave"]
}
```

### 5. Eliminar Lesión
**DELETE** `/injuries/:id`

Elimina una lesión del sistema.

**Headers:** `Authorization: Bearer <access_token>`

**Response (204 No Content):**
```
(No content)
```

**Response (404 Not Found):**
```json
{
  "status": 404,
  "error": "Not Found",
  "exception": "#<ActiveRecord::RecordNotFound: Couldn't find Injury with 'id'=\"1\">"
}
```

### 6. Obtener Lesiones por Usuario
**GET** `/injuries/user/:user_id`

Obtiene todas las lesiones de un usuario específico con filtrado y paginación. Solo el propio usuario o un administrador pueden acceder a esta información.

**Headers:** `Authorization: Bearer <access_token>`

**Parámetros de Filtrado:**
- `injury_type`: Filtrar por tipo de lesión
- `severity`: Filtrar por severidad (leve, moderada, grave)
- `recovered`: Filtrar por estado de recuperación (true/false)
- `date_from`: Fecha de ocurrencia desde (YYYY-MM-DD)
- `date_to`: Fecha de ocurrencia hasta (YYYY-MM-DD)
- `search`: Búsqueda en tipo de lesión y descripción
- `page`: Número de página (por defecto: 1)
- `per_page`: Elementos por página (por defecto: 10, máximo: 100)

**Response (200 OK):**
```json
{
  "injuries": [
    {
      "id": 1,
      "injury_type": "Lesión de rodilla",
      "description": "Dolor en la rodilla izquierda durante ejercicios de flexión",
      "severity": "moderada",
      "date_ocurred": "2024-01-15",
      "recovered": false,
      "created_at": "2024-01-20T10:30:00.000Z",
      "updated_at": "2024-01-20T10:30:00.000Z",
      "user": {
        "id": 1,
        "email": "usuario@ejemplo.com",
        "name": "Juan",
        "last_name": "Pérez"
      }
    },
    {
      "id": 2,
      "injury_type": "Lesión de espalda",
      "description": "Dolor lumbar después de ejercicios de flexión",
      "severity": "leve",
      "date_ocurred": "2024-01-20",
      "recovered": true,
      "created_at": "2024-01-20T11:00:00.000Z",
      "updated_at": "2024-01-20T11:30:00.000Z",
      "user": {
        "id": 1,
        "email": "usuario@ejemplo.com",
        "name": "Juan",
        "last_name": "Pérez"
      }
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 2,
    "total_count": 15,
    "per_page": 10,
    "has_next_page": true,
    "has_prev_page": false
  }
}
```

**Nota:** Este endpoint también utiliza el formato de respuesta estandarizado con datos serializados usando ActiveModelSerializers y metadatos de paginación consistentes.

**Ejemplos de Filtrado:**
```bash
# Lesiones de un usuario con filtros específicos
GET /api/v1/injuries/user/1?severity=grave&recovered=false&page=1&per_page=10

# Búsqueda en lesiones de un usuario
GET /api/v1/injuries/user/1?search=espalda&date_from=2024-01-01
```

**Response (401 Unauthorized):**
```json
{
  "error": "No autorizado"
}
```

## Modelo de Datos

### Lesión (Injury)
```json
{
  "id": "integer (auto-incremento)",
  "user_id": "integer (requerido, referencia a User)",
  "injury_type": "string (requerido, tipo de lesión)",
  "description": "text (opcional, descripción detallada)",
  "severity": "enum (opcional: 'leve', 'moderada', 'grave')",
  "date_ocurred": "date (opcional, fecha cuando ocurrió la lesión)",
  "recovered": "boolean (opcional, si la lesión está recuperada)",
  "created_at": "datetime (timestamp de creación)",
  "updated_at": "datetime (timestamp de última actualización)"
}
```

## Validaciones

### Campos Requeridos
- `injury_type`: Debe estar presente

### Validaciones de Severidad
- `severity`: Solo acepta los valores: `"leve"`, `"moderada"`, `"grave"`
- Si se proporciona un valor inválido, retorna error 422

### Relaciones
- `user_id`: Debe hacer referencia a un usuario existente
- La lesión pertenece a un usuario (`belongs_to :user`)

## Códigos de Estado HTTP

- **200 OK**: Solicitud exitosa
- **201 Created**: Lesión creada exitosamente
- **204 No Content**: Lesión eliminada exitosamente
- **401 Unauthorized**: No autenticado o no autorizado
- **404 Not Found**: Lesión no encontrada
- **422 Unprocessable Entity**: Error de validación

## Permisos y Autorización

### Políticas de Acceso
- **Usuarios regulares**: Solo pueden ver y gestionar sus propias lesiones
- **Administradores**: Pueden ver y gestionar todas las lesiones
- **Instructores**: Pueden ver las lesiones de sus estudiantes (si se implementa esta funcionalidad)

### Endpoint de Lesiones por Usuario
- Solo el propio usuario puede ver sus lesiones
- Los administradores pueden ver las lesiones de cualquier usuario
- Otros usuarios reciben error 401 Unauthorized

## Notas Importantes

1. **Autenticación**: Todos los endpoints requieren un token JWT válido
2. **Autorización**: Se utiliza Pundit para controlar el acceso a los recursos
3. **Validaciones**: El campo `injury_type` es obligatorio
4. **Severidad**: Solo acepta valores predefinidos (leve, moderada, grave)
5. **Relaciones**: Cada lesión debe estar asociada a un usuario existente
6. **Timestamps**: Se registran automáticamente las fechas de creación y actualización

## Ejemplos de Uso

### Crear una lesión para un usuario
```bash
curl -X POST http://localhost:3000/api/v1/injuries \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "injury": {
      "user_id": 1,
      "injury_type": "Lesión de hombro",
      "description": "Dolor al levantar el brazo",
      "severity": "moderada",
      "date_ocurred": "2024-01-18",
      "recovered": false
    }
  }'
```

### Obtener lesiones de un usuario específico
```bash
curl -X GET http://localhost:3000/api/v1/injuries/user/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Actualizar el estado de recuperación
```bash
curl -X PATCH http://localhost:3000/api/v1/injuries/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "injury": {
      "recovered": true
    }
  }'
```

## Filtrado y Paginación

### Filtros Disponibles
| Filtro | Tipo | Descripción | Ejemplo |
|--------|------|-------------|---------|
| `user_id` | integer | Filtrar por ID de usuario | `user_id=1` |
| `injury_type` | string | Filtrar por tipo de lesión | `injury_type=rodilla` |
| `severity` | enum | Filtrar por severidad (leve, moderada, grave) | `severity=grave` |
| `recovered` | boolean | Filtrar por estado de recuperación | `recovered=false` |
| `date_from` | date | Fecha de ocurrencia desde (YYYY-MM-DD) | `date_from=2024-01-01` |
| `date_to` | date | Fecha de ocurrencia hasta (YYYY-MM-DD) | `date_to=2024-12-31` |
| `search` | string | Búsqueda en tipo de lesión y descripción | `search=rodilla` |

### Ejemplos de Filtrado Avanzado
```bash
# Lesiones no recuperadas de severidad grave
GET /api/v1/injuries?severity=grave&recovered=false&page=1&per_page=20

# Búsqueda por tipo de lesión
GET /api/v1/injuries?user_id=1&search=rodilla

# Lesiones en un rango de fechas
GET /api/v1/injuries?date_from=2024-01-01&date_to=2024-06-30

# Combinación de filtros
GET /api/v1/injuries?severity=moderada&recovered=false&date_from=2024-01-01&page=1&per_page=15
```

### Formato de Respuesta con Paginación
```json
{
  "injuries": [...],
  "pagination": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 25,
    "per_page": 10,
    "has_next_page": true,
    "has_prev_page": false
  }
}
```
