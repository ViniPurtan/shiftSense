class SupabaseConfig {
  static const String supabaseUrl = 'https://jqyvdhqirhdfpztaudep.supabase.co';
  
  // Usa la "Publishable key" aquí - Segura para aplicaciones cliente
  // NOTA: Esta es una clave de ejemplo. Reemplaza con tu clave real de Supabase
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxeXZkaHFpcmhkZnB6dGF1ZGVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE0MDcwMzIsImV4cCI6MjAzNjk4MzAzMn0.PLACEHOLDER_REPLACE_WITH_REAL_KEY';
  
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
