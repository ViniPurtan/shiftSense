import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiftsense/models/employee.dart';

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
    vacations.add(vacation);
    await saveVacations(vacations);
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