// En lib/config/supabase_config.dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://jqyvdhqirhdfpztaudep.supabase.co';
  
  // Usa la "Publishable key" aquí
  static const String supabaseAnonKey = 'sb_publishable_GIW5247CoVnpkgZmom_wPw_1LkfowqA';
}
  
  // ⚠️ IMPORTANTE: Service Role Key removida por seguridad
  // La Service Role Key NUNCA debe estar en el código del cliente
  // Si necesitas operaciones administrativas:
  // 1. Créalas en Edge Functions de Supabase
  // 2. Usa variables de entorno en el servidor
  // 3. O usa Row Level Security (RLS) con la anon key
  
  // Para operaciones administrativas, considera:
  // - Usar Supabase Edge Functions
  // - Implementar RLS (Row Level Security)
  // - Crear un backend separado si es necesario
}
