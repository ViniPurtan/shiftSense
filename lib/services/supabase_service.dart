import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shiftsense/config/supabase_config.dart';
import 'package:shiftsense/models/employee.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  // Verificar conexión a Supabase
  Future<bool> isConnected() async {
    try {
      await client.from('employees').select().limit(1);
      return true;
    } catch (e) {
      print('⚠️ Error de conexión a Supabase: $e');
      return false;
    }
  }

  // Inicializar tablas si no existen
  Future<void> initializeTables() async {
    try {
      // Crear tabla de empleados si no existe
      await client.rpc('create_employees_table_if_not_exists');
      
      // Crear tabla de turnos si no existe
      await client.rpc('create_shifts_table_if_not_exists');
      
      // Crear tabla de vacaciones si no existe
      await client.rpc('create_vacations_table_if_not_exists');
      
      print('✅ Tablas de Supabase inicializadas');
    } catch (e) {
      print('⚠️ Error inicializando tablas: $e');
      throw Exception('Error inicializando base de datos: $e');
    }
  }

  // CRUD para empleados
  Future<List<Employee>> getEmployees() async {
    try {
      final response = await client
          .from('employees')
          .select()
          .order('name');
      
      return (response as List)
          .map((json) => Employee.fromJson(json))
          .toList();
    } catch (e) {
      print('⚠️ Error obteniendo empleados: $e');
      return [];
    }
  }

  Future<void> saveEmployee(Employee employee) async {
    try {
      final data = employee.toJson();
      
      await client
          .from('employees')
          .upsert(data);
      
      print('✅ Empleado guardado: ${employee.name}');
    } catch (e) {
      print('⚠️ Error guardando empleado: $e');
      throw Exception('Error guardando empleado: $e');
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    try {
      await client
          .from('employees')
          .delete()
          .eq('id', employeeId);
      
      print('✅ Empleado eliminado: $employeeId');
    } catch (e) {
      print('⚠️ Error eliminando empleado: $e');
      throw Exception('Error eliminando empleado: $e');
    }
  }

  // CRUD para turnos
  Future<List<WeeklyShift>> getShifts() async {
    try {
      final response = await client
          .from('shifts')
          .select()
          .order('week_start');
      
      return (response as List)
          .map((json) => WeeklyShift.fromJson(json))
          .toList();
    } catch (e) {
      print('⚠️ Error obteniendo turnos: $e');
      return [];
    }
  }

  Future<void> saveShift(WeeklyShift shift) async {
    try {
      final data = shift.toJson();
      
      await client
          .from('shifts')
          .upsert(data);
      
      print('✅ Turno guardado para semana: ${shift.weekStart}');
    } catch (e) {
      print('⚠️ Error guardando turno: $e');
      throw Exception('Error guardando turno: $e');
    }
  }

  // CRUD para vacaciones
  Future<List<Vacation>> getVacations() async {
    try {
      final response = await client
          .from('vacations')
          .select()
          .order('start_date');
      
      return (response as List)
          .map((json) => Vacation.fromJson(json))
          .toList();
    } catch (e) {
      print('⚠️ Error obteniendo vacaciones: $e');
      return [];
    }
  }

  Future<void> saveVacation(Vacation vacation) async {
    try {
      final data = vacation.toJson();
      
      await client
          .from('vacations')
          .upsert(data);
      
      print('✅ Vacación guardada: ${vacation.employeeId}');
    } catch (e) {
      print('⚠️ Error guardando vacación: $e');
      throw Exception('Error guardando vacación: $e');
    }
  }

  Future<void> deleteVacation(String vacationId) async {
    try {
      await client
          .from('vacations')
          .delete()
          .eq('id', vacationId);
      
      print('✅ Vacación eliminada: $vacationId');
    } catch (e) {
      print('⚠️ Error eliminando vacación: $e');
      throw Exception('Error eliminando vacación: $e');
    }
  }

  // Sincronización de datos
  Future<void> syncFromLocal(List<Employee> employees, List<WeeklyShift> shifts, List<Vacation> vacations) async {
    try {
      // Sincronizar empleados
      for (final employee in employees) {
        await saveEmployee(employee);
      }
      
      // Sincronizar turnos
      for (final shift in shifts) {
        await saveShift(shift);
      }
      
      // Sincronizar vacaciones
      for (final vacation in vacations) {
        await saveVacation(vacation);
      }
      
      print('✅ Sincronización completada');
    } catch (e) {
      print('⚠️ Error en sincronización: $e');
      throw Exception('Error sincronizando datos: $e');
    }
  }

  // Backup completo
  Future<Map<String, dynamic>> getFullBackup() async {
    try {
      final employees = await getEmployees();
      final shifts = await getShifts();
      final vacations = await getVacations();
      
      return {
        'employees': employees.map((e) => e.toJson()).toList(),
        'shifts': shifts.map((s) => s.toJson()).toList(),
        'vacations': vacations.map((v) => v.toJson()).toList(),
        'backup_date': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('⚠️ Error creando backup: $e');
      throw Exception('Error creando backup: $e');
    }
  }
}
