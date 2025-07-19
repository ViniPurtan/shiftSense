class SupabaseConfig {
  // URL del proyecto Supabase
  static const String supabaseUrl = 'https://jqyvdhqirhdfpztaudep.supabase.co';
  
  // Clave anónima - Esta es segura para exponer en el cliente
  // NOTA: Regenera esta clave en tu panel de Supabase después de este commit
  static const String supabaseAnonKey = 'TU_NUEVA_ANON_KEY_AQUI';
  
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
