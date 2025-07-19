# 🔒 Guía de Seguridad - ShiftSense

## ⚠️ INCIDENTE DE SEGURIDAD RESUELTO

**Fecha:** 19 de Julio, 2025  
**Problema:** Service Role JWT de Supabase expuesto en repositorio público  
**Estado:** ✅ RESUELTO

### Qué pasó
- Las claves de Supabase (Service Role JWT y Anon Key) estaban hardcodeadas en `lib/config/supabase_config.dart`
- GitGuardian detectó la exposición automáticamente
- Las claves fueron removidas del código inmediatamente

### Acciones tomadas
1. ✅ Claves removidas del código
2. ✅ Archivo `.gitignore` actualizado
3. ⚠️ **PENDIENTE: Regenerar claves en Supabase Dashboard**

## 🚨 ACCIONES REQUERIDAS INMEDIATAMENTE

### 1. Regenerar todas las claves de Supabase
```bash
# Ve a: https://supabase.com/dashboard/project/[tu-proyecto]/settings/api
# 1. Regenera el "anon public" key
# 2. Regenera el "service_role" key
```

### 2. Actualizar el código con las nuevas claves
```dart
// En lib/config/supabase_config.dart
static const String supabaseAnonKey = 'TU_NUEVA_CLAVE_ANON_AQUI';
// NO incluir la service_role key en el código del cliente
```

### 3. Revisar el código para operaciones administrativas
Si tu app necesita operaciones que requieren la service_role key:
- Muévelas a Supabase Edge Functions
- Implementa Row Level Security (RLS)
- Crea un backend separado si es necesario

## 🛡️ Mejores Prácticas de Seguridad

### ❌ NUNCA hacer:
- Hardcodear service_role keys en el código del cliente
- Commitear archivos `.env` con secrets
- Compartir claves por email/chat/screenshots
- Usar service_role keys en aplicaciones móviles/web

### ✅ SÍ hacer:
- Usar solo anon keys en el cliente
- Configurar Row Level Security (RLS) en Supabase
- Usar variables de entorno para secrets en el servidor
- Rotar claves regularmente
- Monitorear con herramientas como GitGuardian

### Configuración segura recomendada:

```dart
// ✅ CORRECTO: Solo anon key en el cliente
class SupabaseConfig {
  static const String supabaseUrl = 'https://tu-proyecto.supabase.co';
  static const String supabaseAnonKey = 'eyJ...'; // Solo anon key
  
  // Service role operations moved to Edge Functions
}
```

```sql
-- ✅ CORRECTO: Usar RLS para seguridad
ALTER TABLE turnos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only see their own shifts" ON turnos
  FOR SELECT USING (auth.uid() = user_id);
```

### Estructura recomendada para secrets:

```
proyecto/
├── lib/config/
│   ├── supabase_config.dart          # Solo anon key
│   └── app_config.dart               # Configuración pública
├── supabase/functions/               # Edge Functions para operaciones admin
│   ├── admin-operations/
│   └── .env                         # Service role key (gitignored)
└── .env.example                     # Template sin valores reales
```

## 📋 Checklist de Seguridad Post-Incidente

- [ ] Regenerar anon key en Supabase
- [ ] Regenerar service_role key en Supabase  
- [ ] Actualizar `supabase_config.dart` con nueva anon key
- [ ] Revisar todas las operaciones que usaban service_role key
- [ ] Mover operaciones administrativas a Edge Functions
- [ ] Configurar RLS en todas las tablas
- [ ] Testear que la app funciona con solo anon key
- [ ] Documentar el proceso para el equipo

## 🔗 Recursos útiles

- [Supabase RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [GitGuardian](https://gitguardian.com/) - Para monitoreo continuo
- [OWASP Security Guide](https://owasp.org/www-project-mobile-top-10/)

---

**Contacto de emergencia de seguridad:** [tu-email@empresa.com]  
**Última actualización:** 19 de Julio, 2025
