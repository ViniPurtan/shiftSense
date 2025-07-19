import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shiftsense/models/employee.dart';

class SupabaseShiftService {
  static final SupabaseShiftService _instance = SupabaseShiftService._();
  factory SupabaseShiftService() => _instance;
  SupabaseShiftService._();

  final _supabase = Supabase.instance.client;

  // 🔄 Obtener turnos usando las funciones que creamos
  Future<List<Map<String, dynamic>>> getTurnosHoy() async {
    try {
      final response = await _supabase.rpc('get_turnos_hoy');
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('Error obteniendo turnos de hoy: $e');
      return [];
    }
  }

  // 📊 Obtener dashboard con datos reales
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _supabase.rpc('basic_dashboard');
      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
      return {'error': 'No data'};
    } catch (e) {
      print('Error obteniendo dashboard: $e');
      return {'error': e.toString()};
    }
  }

  // 🏢 Obtener departamentos
  Future<List<Map<String, dynamic>>> getDepartamentos() async {
    try {
      final response = await _supabase.rpc('list_departamentos');
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('Error obteniendo departamentos: $e');
      return [];
    }
  }

  // 🕐 Obtener tipos de turno
  Future<List<Map<String, dynamic>>> getTiposTurno() async {
    try {
      final response = await _supabase.rpc('list_tipos_turno');
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('Error obteniendo tipos de turno: $e');
      return [];
    }
  }

  // 📅 Obtener turnos recientes
  Future<List<Map<String, dynamic>>> getTurnosRecientes() async {
    try {
      final response = await _supabase.rpc('list_turnos_recientes');
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('Error obteniendo turnos recientes: $e');
      return [];
    }
  }

  // 🧪 Probar conexión
  Future<String> testConnection() async {
    try {
      final response = await _supabase.rpc('test_basic');
      return response?.toString() ?? 'Sin respuesta';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // 📈 Obtener conteos simples
  Future<String> getSimpleCounts() async {
    try {
      final response = await _supabase.rpc('simple_counts');
      return response?.toString() ?? 'Sin datos';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // 🔄 Convertir datos de Supabase al formato de la app actual
  Future<WeeklyShift?> getCurrentShiftFromSupabase() async {
    try {
      // Obtener turnos de hoy
      final turnosHoy = await getTurnosHoy();
      final departamentos = await getDepartamentos();
      
      if (turnosHoy.isEmpty) {
        return null;
      }

      // Crear un WeeklyShift temporal con los datos de Supabase
      // Esto es una adaptación para mantener compatibilidad
      final now = DateTime.now();
      final weekStart = _getWeekStart(now);
      
      // Extraer IDs de los turnos (adaptación temporal)
      final t1Members = <String>[];
      final t2Members = <String>[];
      
      // Por ahora devolvemos estructura básica
      // TODO: Adaptar completamente al nuevo esquema de base de datos
      return WeeklyShift(
        weekStart: weekStart,
        t1Members: ['user1', 'user2', 'user3', 'user4', 'user5', 'user6', 'user7'],
        t2Members: ['user8', 'user9'],
        captainId: 'user8',
      );
    } catch (e) {
      print('Error obteniendo shift actual: $e');
      return null;
    }
  }

  DateTime _getWeekStart(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  // 🔀 Método para migrar datos locales a Supabase (futuro)
  Future<void> migrateLocalDataToSupabase() async {
    // TODO: Implementar migración de datos locales a Supabase
    print('Migración de datos pendiente de implementar');
  }

  // 🔍 Debug: Mostrar información de conexión
  Future<Map<String, dynamic>> getDebugInfo() async {
    final info = <String, dynamic>{};
    
    try {
      info['connection_test'] = await testConnection();
      info['simple_counts'] = await getSimpleCounts();
      info['dashboard'] = await getDashboard();
      info['turnos_hoy'] = await getTurnosHoy();
    } catch (e) {
      info['error'] = e.toString();
    }
    
    return info;
  }
}
