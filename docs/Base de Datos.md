# Solución Completa para el Error de Expresiones DEFAULT

El error persiste porque estás intentando usar una columna (`fecha`) en una expresión DEFAULT, lo cual no está permitido en PostgreSQL. Aquí te presento la solución definitiva:

## Script SQL Corregido

```sql
-- Habilitar extensión UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Tabla usuarios (sin dependencias)
CREATE TABLE public.usuarios (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  auth_id uuid,
  email character varying NOT NULL UNIQUE,
  nombre character varying NOT NULL,
  apellido character varying,
  telefono character varying,
  avatar_url text,
  rol character varying DEFAULT 'empleado'::character varying CHECK (rol::text = ANY (ARRAY['admin'::character varying, 'supervisor'::character varying, 'empleado'::character varying]::text[])),
  activo boolean DEFAULT true,
  fecha_ingreso date DEFAULT CURRENT_DATE,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT usuarios_pkey PRIMARY KEY (id)
);

-- 2. Tabla departamentos
CREATE TABLE public.departamentos (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  nombre character varying NOT NULL UNIQUE,
  descripcion text,
  color character varying DEFAULT '#6366f1'::character varying,
  activo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT departamentos_pkey PRIMARY KEY (id)
);

-- 3. Tabla tipos_turno (sin DEFAULT problemático)
CREATE TABLE public.tipos_turno (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  nombre character varying NOT NULL,
  descripcion text,
  hora_inicio time without time zone NOT NULL,
  hora_fin time without time zone NOT NULL,
  duracion_horas numeric,
  color character varying DEFAULT '#8b5cf6'::character varying,
  activo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT tipos_turno_pkey PRIMARY KEY (id)
);

-- 4. Tabla turnos (sin DEFAULTs problemáticos)
CREATE TABLE public.turnos (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  tipo_turno_id uuid,
  departamento_id uuid,
  fecha date NOT NULL,
  semana integer,
  año integer,
  capacidad_maxima integer DEFAULT 10,
  personas_asignadas integer DEFAULT 0,
  notas text,
  estado character varying DEFAULT 'activo'::character varying CHECK (estado::text = ANY (ARRAY['activo'::character varying, 'cancelado'::character varying, 'completo'::character varying]::text[])),
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT turnos_pkey PRIMARY KEY (id),
  CONSTRAINT turnos_departamento_id_fkey FOREIGN KEY (departamento_id) REFERENCES public.departamentos(id),
  CONSTRAINT turnos_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.usuarios(id),
  CONSTRAINT turnos_tipo_turno_id_fkey FOREIGN KEY (tipo_turno_id) REFERENCES public.tipos_turno(id)
);

-- 5. Tabla asignaciones_turno
CREATE TABLE public.asignaciones_turno (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  turno_id uuid,
  usuario_id uuid,
  estado character varying DEFAULT 'asignado'::character varying CHECK (estado::text = ANY (ARRAY['asignado'::character varying, 'presente'::character varying, 'ausente'::character varying, 'tardanza'::character varying]::text[])),
  hora_entrada timestamp with time zone,
  hora_salida timestamp with time zone,
  horas_trabajadas numeric,
  notas text,
  asignado_por uuid,
  fecha_asignacion timestamp with time zone DEFAULT now(),
  CONSTRAINT asignaciones_turno_pkey PRIMARY KEY (id),
  CONSTRAINT asignaciones_turno_asignado_por_fkey FOREIGN KEY (asignado_por) REFERENCES public.usuarios(id),
  CONSTRAINT asignaciones_turno_turno_id_fkey FOREIGN KEY (turno_id) REFERENCES public.turnos(id),
  CONSTRAINT asignaciones_turno_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id)
);

-- 6. Tabla configuracion
CREATE TABLE public.configuracion (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  clave character varying NOT NULL UNIQUE,
  valor text NOT NULL,
  tipo character varying DEFAULT 'string'::character varying CHECK (tipo::text = ANY (ARRAY['string'::character varying, 'number'::character varying, 'boolean'::character varying, 'json'::character varying]::text[])),
  descripcion text,
  updated_by uuid,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT configuracion_pkey PRIMARY KEY (id),
  CONSTRAINT configuracion_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.usuarios(id)
);

-- 7. Tabla solicitudes_cambio
CREATE TABLE public.solicitudes_cambio (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  solicitante_id uuid,
  turno_origen_id uuid,
  turno_destino_id uuid,
  usuario_intercambio_id uuid,
  tipo_solicitud character varying CHECK (tipo_solicitud::text = ANY (ARRAY['cambio'::character varying, 'intercambio'::character varying, 'liberacion'::character varying]::text[])),
  motivo text,
  estado character varying DEFAULT 'pendiente'::character varying CHECK (estado::text = ANY (ARRAY['pendiente'::character varying, 'aprobada'::character varying, 'rechazada'::character varying, 'cancelada'::character varying]::text[])),
  aprobado_por uuid,
  fecha_respuesta timestamp with time zone,
  comentarios_admin text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT solicitudes_cambio_pkey PRIMARY KEY (id),
  CONSTRAINT solicitudes_cambio_turno_destino_id_fkey FOREIGN KEY (turno_destino_id) REFERENCES public.turnos(id),
  CONSTRAINT solicitudes_cambio_aprobado_por_fkey FOREIGN KEY (aprobado_por) REFERENCES public.usuarios(id),
  CONSTRAINT solicitudes_cambio_solicitante_id_fkey FOREIGN KEY (solicitante_id) REFERENCES public.usuarios(id),
  CONSTRAINT solicitudes_cambio_turno_origen_id_fkey FOREIGN KEY (turno_origen_id) REFERENCES public.turnos(id),
  CONSTRAINT solicitudes_cambio_usuario_intercambio_id_fkey FOREIGN KEY (usuario_intercambio_id) REFERENCES public.usuarios(id)
);

-- 8. Tabla vacaciones
CREATE TABLE public.vacaciones (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  usuario_id uuid,
  fecha_inicio date NOT NULL,
  fecha_fin date NOT NULL,
  dias_solicitados integer,
  tipo character varying DEFAULT 'vacaciones'::character varying CHECK (tipo::text = ANY (ARRAY['vacaciones'::character varying, 'permiso'::character varying, 'enfermedad'::character varying, 'personal'::character varying]::text[])),
  estado character varying DEFAULT 'pendiente'::character varying CHECK (estado::text = ANY (ARRAY['pendiente'::character varying, 'aprobada'::character varying, 'rechazada'::character varying]::text[])),
  motivo text,
  aprobado_por uuid,
  fecha_solicitud timestamp with time zone DEFAULT now(),
  fecha_respuesta timestamp with time zone,
  CONSTRAINT vacaciones_pkey PRIMARY KEY (id),
  CONSTRAINT vacaciones_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id),
  CONSTRAINT vacaciones_aprobado_por_fkey FOREIGN KEY (aprobado_por) REFERENCES public.usuarios(id)
);

-- Triggers para calcular valores automáticamente

-- 1. Para calcular duración de turnos
CREATE OR REPLACE FUNCTION calcular_duracion_turno()
RETURNS TRIGGER AS $$
BEGIN
  NEW.duracion_horas := EXTRACT(epoch FROM (NEW.hora_fin - NEW.hora_inicio)) / 3600;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_calcular_duracion_turno
BEFORE INSERT OR UPDATE ON public.tipos_turno
FOR EACH ROW EXECUTE FUNCTION calcular_duracion_turno();

-- 2. Para calcular semana y año en turnos
CREATE OR REPLACE FUNCTION calcular_semana_año_turno()
RETURNS TRIGGER AS $$
BEGIN
  NEW.semana := EXTRACT(week FROM NEW.fecha);
  NEW.año := EXTRACT(year FROM NEW.fecha);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_calcular_semana_año_turno
BEFORE INSERT OR UPDATE ON public.turnos
FOR EACH ROW EXECUTE FUNCTION calcular_semana_año_turno();

-- 3. Para calcular días de vacaciones
CREATE OR REPLACE FUNCTION calcular_dias_vacaciones()
RETURNS TRIGGER AS $$
BEGIN
  NEW.dias_solicitados := (NEW.fecha_fin - NEW.fecha_inicio) + 1;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_calcular_dias_vacaciones
BEFORE INSERT OR UPDATE ON public.vacaciones
FOR EACH ROW EXECUTE FUNCTION calcular_dias_vacaciones();

-- Añadir restricción a auth.users si es necesario
ALTER TABLE public.usuarios 
ADD CONSTRAINT usuarios_auth_id_fkey 
FOREIGN KEY (auth_id) REFERENCES auth.users(id);
```

## Explicación Detallada:

1. **Eliminación de DEFAULT problemáticos**:
   - Quité todos los DEFAULT que hacían referencia a otras columnas
   - Los valores se calcularán mediante triggers

2. **Triggers implementados**:
   - `calcular_duracion_turno`: Calcula horas de diferencia entre hora_inicio y hora_fin
   - `calcular_semana_año_turno`: Calcula semana y año automáticamente al insertar/actualizar fecha
   - `calcular_dias_vacaciones`: Calcula días entre fecha_inicio y fecha_fin

3. **Orden de ejecución**:
   - Primero se crean todas las tablas sin restricciones problemáticas
   - Luego se añaden los triggers
   - Finalmente se añade la restricción a auth.users (si existe)

4. **Ventajas de esta solución**:
   - Elimina todos los errores de referencia a columnas en DEFAULT
   - Mantiene exactamente la misma funcionalidad
   - Los cálculos se realizan automáticamente
   - Es más mantenible y claro

Este script completo resolverá tus problemas de creación de base de datos y te permitirá tener todas las funcionalidades que necesitas.
