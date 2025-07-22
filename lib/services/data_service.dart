import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiftsense/models/employee.dart';
import 'package:shiftsense/services/shift_service.dart';

class DataService {
  static const String _employeesKey = 'employees';
  static const String _vacationsKey = 'vacations';
  static const String _shiftsKey = 'shifts';
  static const String _lastRotationWeekKey = 'lastRotationWeek';

  static DataService? _instance;
  late SharedPreferences _prefs;

  DataService._();

  static Future<DataService> getInstance() async {
    _instance ??= DataService._();
    _instance!._prefs = await SharedPreferences.getInstance();
    await _instance!._initializeDefaultData();
    return _instance!;
  }

  Future<void> _initializeDefaultData() async {
    if (_prefs.getString(_employeesKey) == null) {
      await _initializeEmployees();
    }
  }

  Future<void> _initializeEmployees() async {
    final employees = [
      Employee(
        id: '1',
        name: 'Ana García',
        position: 'Senior Developer',
        avatar: '👩‍💻',
      ),
      Employee(
        id: '2',
        name: 'Carlos Ruiz',
        position: 'Team Lead',
        avatar: '👨‍💼',
      ),
      Employee(
        id: '3',
        name: 'Maria López',
        position: 'DevOps Engineer',
        avatar: '👩‍🔧',
      ),
      Employee(
        id: '4',
        name: 'José Martín',
        position: 'Backend Developer',
        avatar: '👨‍💻',
      ),
      Employee(
        id: '5',
        name: 'Elena Fernández',
        position: 'Frontend Developer',
        avatar: '👩‍🎨',
      ),
      Employee(
        id: '6',
        name: 'David Silva',
        position: 'QA Engineer',
        avatar: '👨‍🔬',
      ),
      Employee(
        id: '7',
        name: 'Laura Torres',
        position: 'Product Manager',
        avatar: '👩‍📊',
      ),
      Employee(
        id: '8',
        name: 'Roberto Vega',
        position: 'System Admin',
        avatar: '👨‍🔧',
      ),
      Employee(
        id: '9',
        name: 'Carmen Jiménez',
        position: 'UX Designer',
        avatar: '👩‍🎨',
      ),
    ];
    await saveEmployees(employees);
  }

  Future<List<Employee>> getEmployees() async {
    final jsonString = _prefs.getString(_employeesKey) ?? '[]';
    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((json) => Employee.fromJson(json)).toList();
  }

  Future<void> saveEmployees(List<Employee> employees) async {
    final jsonList = employees.map((e) => e.toJson()).toList();
    await _prefs.setString(_employeesKey, json.encode(jsonList));
  }

  Future<List<Vacation>> getVacations() async {
    final jsonString = _prefs.getString(_vacationsKey) ?? '[]';
    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((json) => Vacation.fromJson(json)).toList();
  }

  Future<void> saveVacations(List<Vacation> vacations) async {
    final jsonList = vacations.map((v) => v.toJson()).toList();
    await _prefs.setString(_vacationsKey, json.encode(jsonList));
  }

  Future<List<WeeklyShift>> getShifts() async {
    final jsonString = _prefs.getString(_shiftsKey) ?? '[]';
    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((json) => WeeklyShift.fromJson(json)).toList();
  }

  Future<void> saveShifts(List<WeeklyShift> shifts) async {
    final jsonList = shifts.map((s) => s.toJson()).toList();
    await _prefs.setString(_shiftsKey, json.encode(jsonList));
  }

  Future<DateTime?> getLastRotationWeek() async {
    final dateString = _prefs.getString(_lastRotationWeekKey);
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  Future<void> saveLastRotationWeek(DateTime date) async {
    await _prefs.setString(_lastRotationWeekKey, date.toIso8601String());
  }

  Future<void> addVacation(Vacation vacation) async {
    final vacations = await getVacations();
    Vacation toAdd = vacation;

    // Aprobar automáticamente bajas médicas y urgencias
    if (vacation.type == VacationType.sick || vacation.type == VacationType.emergency) {
      toAdd = Vacation(
        id: vacation.id,
        employeeId: vacation.employeeId,
        startDate: vacation.startDate,
        endDate: vacation.endDate,
        type: vacation.type,
        status: VacationStatus.approved,
        notes: vacation.notes,
        requestDate: vacation.requestDate,
      );
    }
    // Aprobar automáticamente asuntos personales si hay 48h de antelación
    else if (vacation.type == VacationType.personal) {
      final now = DateTime.now();
      if (vacation.startDate.difference(now).inHours >= 48) {
        toAdd = Vacation(
          id: vacation.id,
          employeeId: vacation.employeeId,
          startDate: vacation.startDate,
          endDate: vacation.endDate,
          type: vacation.type,
          status: VacationStatus.approved,
          notes: vacation.notes,
          requestDate: vacation.requestDate,
        );
      }
    }
    vacations.add(toAdd);
    await saveVacations(vacations);

    // Lógica automática para vacaciones anuales
    if (toAdd.type == VacationType.annual) {
      await _processAnnualVacationApprovals();
    }
  }

  Future<void> _processAnnualVacationApprovals() async {
    var vacations = await getVacations();
    final shiftService = ShiftService();
    await shiftService.initialize();
    // Ordenar por fecha de solicitud
    final annualPendingIds = vacations
      .where((v) => v.type == VacationType.annual && v.status == VacationStatus.pending)
      .map((v) => v.id)
      .toList();
    bool changed = false;
    var keepTrying = true;
    while (keepTrying) {
      keepTrying = false;
      for (final id in annualPendingIds) {
        final idx = vacations.indexWhere((vv) => vv.id == id);
        if (idx == -1 || vacations[idx].status != VacationStatus.pending) continue;
        final v = vacations[idx];
        final canApprove = await shiftService.canEmployeeTakeVacation(
          v.employeeId, v.startDate, v.endDate, v.type,
        );
        if (canApprove) {
          vacations[idx] = Vacation(
            id: v.id,
            employeeId: v.employeeId,
            startDate: v.startDate,
            endDate: v.endDate,
            type: v.type,
            status: VacationStatus.approved,
            notes: v.notes,
            requestDate: v.requestDate,
          );
          changed = true;
          keepTrying = true;
          await saveVacations(vacations); // Actualizar almacenamiento y memoria
          await shiftService.regenerateShiftsForVacation(v.startDate, v.endDate); // Regenerar todas las semanas afectadas
          vacations = await getVacations(); // Recargar lista actualizada
        }
      }
    }
    // Rechazar las que sigan pendientes y no se puedan aprobar
    for (final id in annualPendingIds) {
      final idx = vacations.indexWhere((vv) => vv.id == id);
      if (idx != -1 && vacations[idx].status == VacationStatus.pending) {
        final v = vacations[idx];
        vacations[idx] = Vacation(
          id: v.id,
          employeeId: v.employeeId,
          startDate: v.startDate,
          endDate: v.endDate,
          type: v.type,
          status: VacationStatus.rejected,
          notes: v.notes,
          requestDate: v.requestDate,
        );
        changed = true;
        await shiftService.regenerateShiftsForVacation(v.startDate, v.endDate); // También regenerar si se rechaza
      }
    }
    if (changed) {
      await saveVacations(vacations);
    }
  }

  Future<void> updateVacation(Vacation vacation) async {
    final vacations = await getVacations();
    final index = vacations.indexWhere((v) => v.id == vacation.id);
    if (index >= 0) {
      vacations[index] = vacation;
      await saveVacations(vacations);
    }
  }

  Future<void> deleteVacation(String vacationId) async {
    final vacations = await getVacations();
    vacations.removeWhere((v) => v.id == vacationId);
    await saveVacations(vacations);
  }

  Future<Employee?> getEmployeeById(String id) async {
    final employees = await getEmployees();
    try {
      return employees.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Vacation>> getVacationsForEmployee(String employeeId) async {
    final vacations = await getVacations();
    return vacations.where((v) => v.employeeId == employeeId).toList();
  }

  Future<List<Vacation>> getActiveVacationsForWeek(DateTime weekStart) async {
    final vacations = await getVacations();
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return vacations.where((vacation) {
      if (vacation.status != VacationStatus.approved) return false;
      
      return !(vacation.endDate.isBefore(weekStart) || 
               vacation.startDate.isAfter(weekEnd));
    }).toList();
  }

  Future<void> clearAllData() async {
    await _prefs.clear();
    await _initializeDefaultData();
  }
}
