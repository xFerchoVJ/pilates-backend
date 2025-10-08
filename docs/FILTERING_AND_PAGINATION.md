# Filtrado y Paginación API

Este documento describe cómo usar las funcionalidades de filtrado y paginación implementadas en la API del sistema de Pilates.

## 📋 Endpoints con Filtrado y Paginación

Todos los siguientes endpoints soportan filtrado y paginación:

| Endpoint | Recurso | Filtros Disponibles | Documentación |
|----------|---------|-------------------|---------------|
| `GET /api/v1/users` | Usuarios | search, role, gender, date_from, date_to | [Ver detalles](#usuarios) |
| `GET /api/v1/reservations` | Reservaciones | user_id, class_session_id, date_from, date_to | [Ver detalles](#reservaciones) |
| `GET /api/v1/injuries` | Lesiones | user_id, injury_type, severity, recovered, date_from, date_to, search | [Ver detalles](#lesiones) |
| `GET /api/v1/class_sessions` | Clases | instructor_id, capacity_min, capacity_max, date_from, date_to, start_time_from, start_time_to, search | [Ver detalles](#clases) |
| `GET /api/v1/injuries/user/:user_id` | Lesiones por Usuario | user_id, injury_type, severity, recovered, date_from, date_to, search | [Ver detalles](#lesiones-por-usuario) |

## 🔧 Parámetros de Paginación

### Parámetros Disponibles:
- `page`: Número de página (por defecto: 1)
- `per_page`: Elementos por página (por defecto: 10, máximo: 100)

### Ejemplo:
```bash
GET /api/v1/users?page=2&per_page=20
```

## 📊 Formato de Respuesta

Todas las respuestas incluyen metadatos de paginación:

```json
{
  "users": [
    {
      "id": 1,
      "name": "Juan",
      "last_name": "Pérez",
      "email": "juan@example.com",
      "role": "instructor",
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

## 🔍 Filtros por Recurso

### 👥 Usuarios (`/api/v1/users`)

#### Filtros Disponibles:
| Filtro | Tipo | Descripción | Ejemplo |
|--------|------|-------------|---------|
| `search` | string | Búsqueda en nombre, apellido y email | `search=Juan` |
| `role` | enum | Filtrar por rol (user, instructor, admin) | `role=instructor` |
| `gender` | enum | Filtrar por género (hombre, mujer, otro) | `gender=mujer` |
| `date_from` | date | Fecha de creación desde (YYYY-MM-DD) | `date_from=2024-01-01` |
| `date_to` | date | Fecha de creación hasta (YYYY-MM-DD) | `date_to=2024-12-31` |

#### Ejemplos de Uso:
```bash
# Buscar instructores
GET /api/v1/users?search=Juan&role=instructor&page=1&per_page=10

# Filtrar por género y rango de fechas
GET /api/v1/users?gender=mujer&date_from=2024-01-01&date_to=2024-12-31

# Búsqueda textual
GET /api/v1/users?search=María&page=1&per_page=15
```

### 📅 Reservaciones (`/api/v1/reservations`)

#### Filtros Disponibles:
| Filtro | Tipo | Descripción | Ejemplo |
|--------|------|-------------|---------|
| `user_id` | integer | Filtrar por ID de usuario | `user_id=1` |
| `class_session_id` | integer | Filtrar por ID de clase | `class_session_id=5` |
| `date_from` | date | Fecha de la clase desde (YYYY-MM-DD) | `date_from=2024-01-01` |
| `date_to` | date | Fecha de la clase hasta (YYYY-MM-DD) | `date_to=2024-01-31` |

#### Ejemplos de Uso:
```bash
# Reservaciones de un usuario específico
GET /api/v1/reservations?user_id=1&page=1&per_page=15

# Reservaciones de una clase específica
GET /api/v1/reservations?class_session_id=5&date_from=2024-01-01

# Reservaciones en un rango de fechas
GET /api/v1/reservations?date_from=2024-01-01&date_to=2024-01-31
```

### 🩹 Lesiones (`/api/v1/injuries`)

#### Filtros Disponibles:
| Filtro | Tipo | Descripción | Ejemplo |
|--------|------|-------------|---------|
| `user_id` | integer | Filtrar por ID de usuario | `user_id=1` |
| `injury_type` | string | Filtrar por tipo de lesión | `injury_type=rodilla` |
| `severity` | enum | Filtrar por severidad (leve, moderada, grave) | `severity=grave` |
| `recovered` | boolean | Filtrar por estado de recuperación | `recovered=false` |
| `date_from` | date | Fecha de ocurrencia desde (YYYY-MM-DD) | `date_from=2024-01-01` |
| `date_to` | date | Fecha de ocurrencia hasta (YYYY-MM-DD) | `date_to=2024-12-31` |
| `search` | string | Búsqueda en tipo de lesión y descripción | `search=rodilla` |

#### Ejemplos de Uso:
```bash
# Lesiones no recuperadas de severidad grave
GET /api/v1/injuries?severity=grave&recovered=false&page=1&per_page=20

# Búsqueda por tipo de lesión
GET /api/v1/injuries?user_id=1&search=rodilla

# Lesiones en un rango de fechas
GET /api/v1/injuries?date_from=2024-01-01&date_to=2024-06-30
```

### 🏃‍♀️ Clases (`/api/v1/class_sessions`)

#### Filtros Disponibles:
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

#### Ejemplos de Uso:
```bash
# Clases de un instructor específico con capacidad mínima
GET /api/v1/class_sessions?instructor_id=2&capacity_min=5&capacity_max=15

# Clases en un rango de fechas y horarios
GET /api/v1/class_sessions?date_from=2024-01-01&start_time_from=09:00:00

# Búsqueda por nombre de clase
GET /api/v1/class_sessions?search=pilates&page=1&per_page=20
```

### 👤 Lesiones por Usuario (`/api/v1/injuries/user/:user_id`)

Este endpoint soporta los mismos filtros que el endpoint general de lesiones, pero está limitado a un usuario específico.

#### Ejemplos de Uso:
```bash
# Lesiones de un usuario con filtros específicos
GET /api/v1/injuries/user/1?severity=grave&recovered=false&page=1&per_page=10

# Búsqueda en lesiones de un usuario
GET /api/v1/injuries/user/1?search=espalda&date_from=2024-01-01
```

## 🔗 Combinación de Filtros

Puedes combinar múltiples filtros en una sola consulta:

```bash
# Ejemplo complejo: Usuarios instructores mujeres creados en 2024
GET /api/v1/users?search=María&role=instructor&gender=mujer&date_from=2024-01-01&date_to=2024-12-31&page=1&per_page=15

# Ejemplo complejo: Clases de un instructor en horario matutino con capacidad específica
GET /api/v1/class_sessions?instructor_id=3&capacity_min=8&capacity_max=12&start_time_from=08:00:00&start_time_to=12:00:00&date_from=2024-01-01
```

## 📝 Notas Importantes

### Límites y Restricciones
1. **Límites de Paginación**: El máximo de elementos por página es 100
2. **Fechas**: Usar formato ISO 8601 (YYYY-MM-DD) para filtros de fecha
3. **Horarios**: Usar formato HH:MM:SS para filtros de tiempo
4. **Búsqueda**: La búsqueda es case-insensitive y busca en múltiples campos
5. **Ordenamiento**: Los resultados se ordenan por fecha de creación (o fecha de inicio para clases)

### Autorización
- Todos los filtros respetan las políticas de autorización existentes
- Los usuarios solo pueden ver sus propios datos (excepto administradores)
- Los instructores pueden ver datos de sus estudiantes según las políticas

### Rendimiento
- Se utilizan `includes()` para evitar consultas N+1
- Los filtros se aplican a nivel de base de datos para optimizar el rendimiento
- Se recomienda usar índices en los campos de filtrado más comunes

## 🚀 Ejemplos de Uso Completo

### Obtener usuarios instructores con paginación:
```bash
curl -X GET "http://localhost:3000/api/v1/users?role=instructor&page=1&per_page=20" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Buscar clases de un instructor específico en un rango de fechas:
```bash
curl -X GET "http://localhost:3000/api/v1/class_sessions?instructor_id=3&date_from=2024-01-01&date_to=2024-01-31" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Obtener lesiones no recuperadas de severidad grave:
```bash
curl -X GET "http://localhost:3000/api/v1/injuries?severity=grave&recovered=false&page=1&per_page=25" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Reservaciones de un usuario en un mes específico:
```bash
curl -X GET "http://localhost:3000/api/v1/reservations?user_id=1&date_from=2024-01-01&date_to=2024-01-31&page=1&per_page=10" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## 🔧 Implementación Técnica

### Concern Filterable
El sistema utiliza un concern reutilizable (`Filterable`) que proporciona:
- Métodos para aplicar filtros de manera consistente
- Paginación con metadatos completos
- Validación de parámetros
- Optimización de consultas

### Gemas Utilizadas
- **Kaminari**: Para paginación eficiente
- **ActiveRecord**: Para filtros a nivel de base de datos
- **Pundit**: Para autorización de filtros

### Estructura de Respuesta
```json
{
  "resource_name": [...], // Array de recursos
  "pagination": {
    "current_page": 1,      // Página actual
    "total_pages": 5,       // Total de páginas
    "total_count": 47,      // Total de elementos
    "per_page": 10,         // Elementos por página
    "has_next_page": true,  // Tiene página siguiente
    "has_prev_page": false  // Tiene página anterior
  }
}
```

---

**Última actualización**: Enero 2024  
**Versión**: v1  
**Estado**: ✅ Implementado y documentado
