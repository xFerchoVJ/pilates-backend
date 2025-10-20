# API de Clases de Pilates (Class Sessions) - Pilates Backend

Esta documentación describe todos los endpoints disponibles para la gestión de clases de pilates en el sistema.

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

## Endpoints de Clases de Pilates

### 1. Listar Todas las Clases
**GET** `/class_sessions`

Obtiene la lista de todas las clases de pilates con filtrado y paginación.

**Headers:** `Authorization: Bearer <access_token>`

**Parámetros de Filtrado:**
- `instructor_id`: Filtrar por ID de instructor
- `capacity_min`: Capacidad mínima
- `capacity_max`: Capacidad máxima
- `date_from`: Fecha de inicio desde (YYYY-MM-DD)
- `date_to`: Fecha de inicio hasta (YYYY-MM-DD)
- `start_time_from`: Hora de inicio desde (HH:MM:SS)
- `start_time_to`: Hora de inicio hasta (HH:MM:SS)
- `search`: Búsqueda en nombre y descripción
- `page`: Número de página (por defecto: 1)
- `per_page`: Elementos por página (por defecto: 10, máximo: 100)

**Response (200 OK):**
```json
{
  "class_sessions": [
    {
      "id": 1,
      "name": "Pilates Mat",
      "description": "Clase de pilates en colchoneta",
      "start_time": "2024-01-20T09:00:00.000-06:00",
      "end_time": "2024-01-20T10:00:00.000-06:00",
      "capacity": 12,
      "spots_left": 8,
      "instructor": {
        "id": 2,
        "email": "instructor@ejemplo.com",
        "name": "María",
        "last_name": "García",
        "role": "instructor",
        "gender": "mujer",
        "birthdate": "1985-03-15",
        "profile_picture_url": null
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

### 2. Obtener Clase Específica
**GET** `/class_sessions/:id`

Obtiene los datos de una clase específica.

**Headers:** `Authorization: Bearer <access_token>`

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Pilates Mat",
  "description": "Clase de pilates en colchoneta",
  "start_time": "2024-01-20T09:00:00.000-06:00",
  "end_time": "2024-01-20T10:00:00.000-06:00",
  "capacity": 12,
  "spots_left": 8,
  "instructor": {
    "id": 2,
    "email": "instructor@ejemplo.com",
    "name": "María",
    "last_name": "García",
    "role": "instructor",
    "gender": "mujer",
    "birthdate": "1985-03-15",
    "profile_picture_url": null
  }
}
```

**Response (404 Not Found):**
```json
{
  "status": 404,
  "error": "Not Found",
  "exception": "#<ActiveRecord::RecordNotFound: Couldn't find ClassSession with 'id'=\"1\">"
}
```

### 3. Crear Nueva Clase
**POST** `/class_sessions`

Crea una nueva clase de pilates.

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "class_session": {
    "name": "Yoga para principiantes",
    "description": "Clase de yoga enfocada en estiramiento y respiración.",
    "start_time": "2025-10-10T10:00:00-06:00",
    "end_time": "2025-10-10T11:00:00-06:00",
    "instructor_id": 7,
    "lounge_id": 1
  }
}

```

**Response (201 Created):**
```json
{
    "class_sessions": [
        {
            "id": 2,
            "name": "Yoga para principiantes",
            "description": "Clase de yoga enfocada en estiramiento y respiración.",
            "start_time": "2025-10-10T10:00:00-06:00",
            "end_time": "2025-10-10T11:00:00-06:00",
            "spots_left": 4,
            "instructor": {
                "id": 7,
                "email": "instructor@example.com",
                "name": "Instructor",
                "last_name": "Instructor",
                "phone": "1234567890",
                "role": "instructor",
                "gender": "male",
                "birthdate": "1990-01-01",
                "profile_picture_url": null,
                "has_injuries": "Pending"
            },
            "lounge": {
                "id": 1,
                "name": "Salon de pilates",
                "description": "Aquí se hacen usualmente las clases de pilates, etc"
            },
            "class_spaces": [
                {
                    "id": 1,
                    "class_session_id": 2,
                    "label": "1",
                    "x": 50,
                    "y": 300,
                    "status": "available",
                    "created_at": "2025-10-19T20:16:19.831-06:00",
                    "updated_at": "2025-10-19T20:16:19.831-06:00"
                },
                {
                    "id": 2,
                    "class_session_id": 2,
                    "label": "2",
                    "x": 200,
                    "y": 100,
                    "status": "available",
                    "created_at": "2025-10-19T20:16:19.832-06:00",
                    "updated_at": "2025-10-19T20:16:19.832-06:00"
                },
                {
                    "id": 3,
                    "class_session_id": 2,
                    "label": "3",
                    "x": 400,
                    "y": 500,
                    "status": "reserved",
                    "created_at": "2025-10-19T20:16:19.833-06:00",
                    "updated_at": "2025-10-19T20:22:30.798-06:00"
                },
                {
                    "id": 4,
                    "class_session_id": 2,
                    "label": "4",
                    "x": 350,
                    "y": 300,
                    "status": "available",
                    "created_at": "2025-10-19T20:16:19.833-06:00",
                    "updated_at": "2025-10-19T20:16:19.833-06:00"
                },
                {
                    "id": 5,
                    "class_session_id": 2,
                    "label": "5",
                    "x": 400,
                    "y": 100,
                    "status": "available",
                    "created_at": "2025-10-19T20:16:19.833-06:00",
                    "updated_at": "2025-10-19T20:16:19.833-06:00"
                }
            ]
        }
    ],
    "pagination": {
        "current_page": 1,
        "total_pages": 1,
        "total_count": 1,
        "per_page": 1,
        "has_next_page": false,
        "has_prev_page": false
    }
}
```

**Response (422 Unprocessable Entity):**
```json
{
  "name": ["can't be blank"],
  "start_time": ["can't be blank"],
  "end_time": ["can't be blank"],
  "capacity": ["must be greater than 0"],
  "instructor": ["debe ser instructor"]
}
```

### 4. Actualizar Clase
**PATCH/PUT** `/class_sessions/:id`

Actualiza los datos de una clase existente.

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "class_session": {
    "name": "Pilates Mat Avanzado",
    "description": "Clase de pilates en colchoneta para nivel avanzado",
  }
}
```

**Response (200 OK):**
```json
{
    "id": 2,
    "name": "Pilates Mat Avanzado",
    "description": "Clase de pilates en colchoneta para nivel avanzado",
    "start_time": "2025-10-10T10:00:00-06:00",
    "end_time": "2025-10-10T11:00:00-06:00",
    "spots_left": 4,
    "instructor": {
        "id": 7,
        "email": "instructor@example.com",
        "name": "Instructor",
        "last_name": "Instructor",
        "phone": "1234567890",
        "role": "instructor",
        "gender": "male",
        "birthdate": "1990-01-01",
        "profile_picture_url": null,
        "has_injuries": "Pending"
    },
    "lounge": {
        "id": 1,
        "name": "Salon de pilates",
        "description": "Aquí se hacen usualmente las clases de pilates, etc"
    },
    "class_spaces": [
        {
            "id": 1,
            "class_session_id": 2,
            "label": "1",
            "x": 50,
            "y": 300,
            "status": "available",
            "created_at": "2025-10-19T20:16:19.831-06:00",
            "updated_at": "2025-10-19T20:16:19.831-06:00"
        },
        {
            "id": 2,
            "class_session_id": 2,
            "label": "2",
            "x": 200,
            "y": 100,
            "status": "available",
            "created_at": "2025-10-19T20:16:19.832-06:00",
            "updated_at": "2025-10-19T20:16:19.832-06:00"
        },
        {
            "id": 3,
            "class_session_id": 2,
            "label": "3",
            "x": 400,
            "y": 500,
            "status": "reserved",
            "created_at": "2025-10-19T20:16:19.833-06:00",
            "updated_at": "2025-10-19T20:22:30.798-06:00"
        },
        {
            "id": 4,
            "class_session_id": 2,
            "label": "4",
            "x": 350,
            "y": 300,
            "status": "available",
            "created_at": "2025-10-19T20:16:19.833-06:00",
            "updated_at": "2025-10-19T20:16:19.833-06:00"
        },
        {
            "id": 5,
            "class_session_id": 2,
            "label": "5",
            "x": 400,
            "y": 100,
            "status": "available",
            "created_at": "2025-10-19T20:16:19.833-06:00",
            "updated_at": "2025-10-19T20:16:19.833-06:00"
        }
    ]
}
```

### 5. Eliminar Clase
**DELETE** `/class_sessions/:id`

Elimina una clase del sistema.

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
  "exception": "#<ActiveRecord::RecordNotFound: Couldn't find ClassSession with 'id'=\"1\">"
}
```

## Modelo de Datos

### Clase de Pilates (ClassSession)
```json
{
  "id": "integer (auto-incremento)",
  "name": "string (requerido, nombre de la clase)",
  "description": "text (opcional, descripción de la clase)",
  "start_time": "datetime (requerido, hora de inicio)",
  "end_time": "datetime (requerido, hora de fin)",
  "capacity": "integer (requerido, capacidad máxima de la clase)",
  "instructor_id": "integer (requerido, referencia a User con rol instructor)",
  "created_at": "datetime (timestamp de creación)",
  "updated_at": "datetime (timestamp de última actualización)"
}
```

### Campos Calculados
- `spots_left`: Capacidad disponible (Número de espacios disponibles (class_spaces))

## Validaciones

### Campos Requeridos
- `name`: Debe estar presente
- `start_time`: Debe estar presente
- `end_time`: Debe estar presente
- `instructor_id`: Debe estar presente y referenciar a un instructor válido
- `lounge_id`: Debe estar presente y referenciar a una sala válida

### Validaciones de Negocio
- `end_time`: Debe ser después de `start_time`
- `instructor_id`: El usuario debe tener rol de instructor

### Relaciones
- `instructor_id`: Debe hacer referencia a un usuario existente con rol instructor
- La clase pertenece a un instructor (`belongs_to :instructor`)
- La clase tiene muchas reservas (`has_many :reservations`)

## Códigos de Estado HTTP

- **200 OK**: Solicitud exitosa
- **201 Created**: Clase creada exitosamente
- **204 No Content**: Clase eliminada exitosamente
- **401 Unauthorized**: No autenticado
- **403 Forbidden**: No autorizado para la acción
- **404 Not Found**: Clase no encontrada
- **422 Unprocessable Entity**: Error de validación

## Permisos y Autorización

### Políticas de Acceso
- **Usuarios regulares**: Pueden ver todas las clases
- **Instructores**: Pueden crear, actualizar y eliminar sus propias clases
- **Administradores**: Pueden gestionar todas las clases

### Validaciones de Instructor
- Solo usuarios con rol `instructor` pueden ser asignados como instructores de clase
- Los instructores solo pueden modificar sus propias clases (excepto administradores)

## Filtrado y Paginación

### Filtros Disponibles
| Filtro | Tipo | Descripción | Ejemplo |
|--------|------|-------------|---------|
| `instructor_id` | integer | Filtrar por ID de instructor | `instructor_id=2` |
| `capacity_min` | integer | Capacidad mínima | `capacity_min=5` |
| `capacity_max` | integer | Capacidad máxima | `capacity_max=15` |
| `date_from` | date | Fecha de inicio desde (YYYY-MM-DD) | `date_from=2024-01-01` |
| `date_to` | date | Fecha de inicio hasta (YYYY-MM-DD) | `date_to=2024-01-31` |
| `start_time_from` | time | Hora de inicio desde (HH:MM:SS) | `start_time_from=09:00:00` |
| `start_time_to` | time | Hora de inicio hasta (HH:MM:SS) | `start_time_to=18:00:00` |
| `search` | string | Búsqueda en nombre y descripción | `search=pilates` |

### Ejemplos de Filtrado
```bash
# Clases de un instructor específico
GET /api/v1/class_sessions?instructor_id=2&page=1&per_page=10

# Clases con capacidad específica
GET /api/v1/class_sessions?capacity_min=8&capacity_max=12

# Clases en un rango de fechas
GET /api/v1/class_sessions?date_from=2024-01-01&date_to=2024-01-31

# Clases en horario matutino
GET /api/v1/class_sessions?start_time_from=08:00:00&start_time_to=12:00:00

# Búsqueda por nombre
GET /api/v1/class_sessions?search=pilates&page=1&per_page=20
```

## Notas Importantes

1. **Autenticación**: Todos los endpoints requieren un token JWT válido
2. **Autorización**: Se utiliza Pundit para controlar el acceso a los recursos
3. **Validaciones**: Todos los campos requeridos deben estar presentes
4. **Horarios**: Los horarios se manejan en zona horaria de México (America/Mexico_City)
5. **Capacidad**: Se calcula automáticamente el número de lugares disponibles
6. **Instructores**: Solo usuarios con rol instructor pueden ser asignados

## Ejemplos de Uso

### Crear una nueva clase
```bash
curl -X POST http://localhost:3000/api/v1/class_sessions \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "class_session": {
      "name": "Pilates Mat",
      "description": "Clase de pilates en colchoneta",
      "start_time": "2024-01-22T09:00:00",
      "end_time": "2024-01-22T10:00:00",
      "capacity": 12,
      "instructor_id": 2
    }
  }'
```

### Obtener clases de un instructor
```bash
curl -X GET "http://localhost:3000/api/v1/class_sessions?instructor_id=2" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Actualizar capacidad de una clase
```bash
curl -X PATCH http://localhost:3000/api/v1/class_sessions/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "class_session": {
      "capacity": 15
    }
  }'
```

### Buscar clases por nombre
```bash
curl -X GET "http://localhost:3000/api/v1/class_sessions?search=pilates&page=1&per_page=10" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```
