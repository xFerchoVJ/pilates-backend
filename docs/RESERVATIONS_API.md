# API de Reservaciones (Reservations) - Pilates Backend

Esta documentación describe todos los endpoints disponibles para la gestión de reservaciones de clases en el sistema de Pilates.

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

## Endpoints de Reservaciones

### 1. Listar Todas las Reservaciones
**GET** `/reservations`

Obtiene la lista de todas las reservaciones con filtrado y paginación.

**Headers:** `Authorization: Bearer <access_token>`

**Parámetros de Filtrado:**
- `user_id`: Filtrar por ID de usuario
- `class_session_id`: Filtrar por ID de clase
- `date_from`: Fecha de la clase desde (YYYY-MM-DD)
- `date_to`: Fecha de la clase hasta (YYYY-MM-DD)
- `page`: Número de página (por defecto: 1)
- `per_page`: Elementos por página (por defecto: 10, máximo: 100)

**Response (200 OK):**
```json
{
  "reservations": [
    {
      "id": 1,
      "user": {
        "id": 1,
        "email": "usuario@ejemplo.com",
        "name": "Juan",
        "last_name": "Pérez",
        "role": "user",
        "gender": "hombre",
        "birthdate": "1990-01-01",
        "profile_picture_url": null
      },
      "class_session": {
        "id": 1,
        "name": "Pilates Mat",
        "description": "Clase de pilates en colchoneta",
        "start_time": "2024-01-20T09:00:00.000-06:00",
        "end_time": "2024-01-20T10:00:00.000-06:00",
        "spots_left": 7,
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
      },
      "class_space": {
        "id": 10,
        "label": "Silla A1",
        "status": "reserved"
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

**Nota:** Este endpoint utiliza el formato de respuesta estandarizado con datos serializados usando ActiveModelSerializers y metadatos de paginación consistentes.

### 2. Obtener Reservación Específica
**GET** `/reservations/:id`

Obtiene los datos de una reservación específica.

**Headers:** `Authorization: Bearer <access_token>`

**Response (200 OK):**
```json
{
  "id": 1,
  "user": {
    "id": 1,
    "email": "usuario@ejemplo.com",
    "name": "Juan",
    "last_name": "Pérez",
    "role": "user",
    "gender": "hombre",
    "birthdate": "1990-01-01",
    "profile_picture_url": null
  },
  "class_session": {
    "id": 1,
    "name": "Pilates Mat",
    "description": "Clase de pilates en colchoneta",
    "start_time": "2024-01-20T09:00:00.000-06:00",
    "end_time": "2024-01-20T10:00:00.000-06:00",
    "spots_left": 7,
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
  },
  "class_space": {
    "id": 10,
    "label": "Silla A1",
    "status": "reserved"
  }
}
```

**Response (404 Not Found):**
```json
{
  "status": 404,
  "error": "Not Found",
  "exception": "#<ActiveRecord::RecordNotFound: Couldn't find Reservation with 'id'=\"1\">"
}
```

### 3. Crear Nueva Reservación
**POST** `/reservations`

Crea una nueva reservación para una clase.

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "reservation": {
    "user_id": 1,
    "class_session_id": 1,
    "class_space_id": 10
  }
}
```

**Response (201 Created):**
```json
{
  "id": 2,
  "user": {
    "id": 1,
    "email": "usuario@ejemplo.com",
    "name": "Juan",
    "last_name": "Pérez",
    "role": "user",
    "gender": "hombre",
    "birthdate": "1990-01-01",
    "profile_picture_url": null
  },
  "class_session": {
    "id": 1,
    "name": "Pilates Mat",
    "description": "Clase de pilates en colchoneta",
    "start_time": "2024-01-20T09:00:00.000-06:00",
    "end_time": "2024-01-20T10:00:00.000-06:00",
    "spots_left": 6,
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
  },
  "class_space": {
    "id": 10,
    "label": "Silla A1",
    "status": "reserved"
  }
}
```

**Response (422 Unprocessable Entity):**
```json
{
  "user_id": ["can't be blank"],
  "class_session": ["La clase está llena"],
  "class_space": [
    "no pertenece a esta clase",
    "ya está ocupado",
    "no existe"
  ]
}
```

### 4. Actualizar Reservación
**PATCH/PUT** `/reservations/:id`

Actualiza los datos de una reservación existente (generalmente para cambiar la clase).

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "reservation": {
    "class_session_id": 2
  }
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "user": {
    "id": 1,
    "email": "usuario@ejemplo.com",
    "name": "Juan",
    "last_name": "Pérez",
    "role": "user",
    "gender": "hombre",
    "birthdate": "1990-01-01",
    "profile_picture_url": null
  },
  "class_session": {
    "id": 2,
    "name": "Pilates Reformer",
    "description": "Clase de pilates con máquina reformer",
    "start_time": "2024-01-20T11:00:00.000-06:00",
    "end_time": "2024-01-20T12:00:00.000-06:00",
    "capacity": 8,
    "spots_left": 7,
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
}
```

### 5. Eliminar Reservación
**DELETE** `/reservations/:id`

Elimina una reservación del sistema.

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
  "exception": "#<ActiveRecord::RecordNotFound: Couldn't find Reservation with 'id'=\"1\">"
}
```

## Modelo de Datos

### Reservación (Reservation)
```json
{
  "id": "integer (auto-incremento)",
  "user_id": "integer (requerido, referencia a User)",
  "class_session_id": "integer (requerido, referencia a ClassSession)",
  "class_space_id": "integer (requerido, referencia a ClassSpace)",
  "created_at": "datetime (timestamp de creación)",
  "updated_at": "datetime (timestamp de última actualización)"
}
```

### Relaciones
- `user_id`: Referencia al usuario que hace la reservación
- `class_session_id`: Referencia a la clase reservada
- `class_space_id`: Referencia al espacio específico reservado dentro de la clase
- La reservación pertenece a un usuario (`belongs_to :user`)
- La reservación pertenece a una clase (`belongs_to :class_session`)
- La reservación pertenece a un espacio de clase (`belongs_to :class_space`)

## Validaciones

### Campos Requeridos
- `user_id`: Debe estar presente
- `class_session_id`: Debe estar presente
- `class_space_id`: Debe estar presente

### Validaciones de Negocio
- **Unicidad**: Un usuario no puede tener múltiples reservaciones para la misma clase
- **Capacidad**: No se puede reservar una clase que esté llena
- **Existencia**: Tanto el usuario como la clase deben existir
- **Espacio**: El `class_space_id` debe existir, pertenecer a la `class_session` indicada y estar disponible

### Mensajes de Error
- `"ya tiene una reserva para esta clase"`: Cuando un usuario intenta reservar la misma clase dos veces
- `"La clase está llena"`: Cuando la clase ha alcanzado su capacidad máxima
- `"no pertenece a esta clase"`: Cuando el `class_space` no corresponde a la `class_session` de la reservación
- `"ya está ocupado"`: Cuando el `class_space` ya está reservado
- `"no existe"`: Cuando el `class_space_id` no corresponde a un `ClassSpace` existente

## Códigos de Estado HTTP

- **200 OK**: Solicitud exitosa
- **201 Created**: Reservación creada exitosamente
- **204 No Content**: Reservación eliminada exitosamente
- **401 Unauthorized**: No autenticado
- **403 Forbidden**: No autorizado para la acción
- **404 Not Found**: Reservación no encontrada
- **422 Unprocessable Entity**: Error de validación

## Permisos y Autorización

### Políticas de Acceso
- **Usuarios regulares**: Pueden ver, crear y eliminar sus propias reservaciones
- **Instructores**: Pueden ver las reservaciones de sus clases
- **Administradores**: Pueden gestionar todas las reservaciones

### Validaciones de Acceso
- Los usuarios solo pueden ver sus propias reservaciones (excepto administradores)
- Los instructores pueden ver las reservaciones de sus clases
- Solo el propietario de la reservación puede eliminarla (excepto administradores)

## Filtrado y Paginación

### Filtros Disponibles
| Filtro | Tipo | Descripción | Ejemplo |
|--------|------|-------------|---------|
| `user_id` | integer | Filtrar por ID de usuario | `user_id=1` |
| `class_session_id` | integer | Filtrar por ID de clase | `class_session_id=5` |
| `date_from` | date | Fecha de la clase desde (YYYY-MM-DD) | `date_from=2024-01-01` |
| `date_to` | date | Fecha de la clase hasta (YYYY-MM-DD) | `date_to=2024-01-31` |

### Ejemplos de Filtrado
```bash
# Reservaciones de un usuario específico
GET /api/v1/reservations?user_id=1&page=1&per_page=15

# Reservaciones de una clase específica
GET /api/v1/reservations?class_session_id=5&date_from=2024-01-01

# Reservaciones en un rango de fechas
GET /api/v1/reservations?date_from=2024-01-01&date_to=2024-01-31

# Combinación de filtros
GET /api/v1/reservations?user_id=1&date_from=2024-01-01&date_to=2024-01-31
```

## Notas Importantes

1. **Autenticación**: Todos los endpoints requieren un token JWT válido
2. **Autorización**: Se utiliza Pundit para controlar el acceso a los recursos
3. **Validaciones**: Se valida la unicidad y la capacidad de la clase
4. **Relaciones**: Las reservaciones incluyen información completa del usuario y la clase
5. **Capacidad**: Se actualiza automáticamente el número de lugares disponibles en la clase

## Casos de Uso Comunes

### Reservar una clase
```bash
curl -X POST http://localhost:3000/api/v1/reservations \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "reservation": {
      "user_id": 1,
      "class_session_id": 1,
      "class_space_id": 10
    }
  }'
```

### Ver mis reservaciones
```bash
curl -X GET "http://localhost:3000/api/v1/reservations?user_id=1" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Ver reservaciones de una clase específica
```bash
curl -X GET "http://localhost:3000/api/v1/reservations?class_session_id=1" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Cancelar una reservación
```bash
curl -X DELETE http://localhost:3000/api/v1/reservations/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Cambiar de clase
```bash
curl -X PATCH http://localhost:3000/api/v1/reservations/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "reservation": {
      "class_session_id": 2
    }
  }'
```

## Flujo de Reservación

1. **Verificar disponibilidad**: El usuario consulta las clases disponibles
2. **Crear reservación**: Se envía una solicitud POST con `user_id`, `class_session_id` y `class_space_id`
3. **Validar espacio**: El sistema valida que el `class_space` exista, pertenezca a la clase y esté disponible
4. **Validar capacidad**: El sistema verifica que la clase no esté llena
5. **Validar unicidad**: Se asegura que el usuario no tenga ya una reservación para esa clase
6. **Crear reservación**: Si todo es válido, se crea la reservación y se marca el `class_space` como `reserved`

## Consideraciones de Rendimiento

- Las consultas incluyen las relaciones (`includes`) para evitar N+1 queries
- Los filtros se aplican a nivel de base de datos
- Se recomienda usar índices en `user_id` y `class_session_id`
- La paginación limita el número de resultados por consulta
