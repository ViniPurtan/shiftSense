import 'package:shiftsense/models/employee.dart';
import 'package:shiftsense/services/data_service.dart';

class ShiftService {
  static final ShiftService _instance = ShiftService._();
  factory ShiftService() => _instance;
  ShiftService._();

  late DataService _dataService;

  Future<void> initialize() async {
    _dataService = await DataService.getInstance();
  }

  DateTime _getWeekStart(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  Future<WeeklyShift> generateShiftForWeek(DateTime weekStart) async {
    final employees = await _dataService.getEmployees();
    final vacations = await _dataService.getActiveVacationsForWeek(weekStart);
    final existingShifts = await _dataService.getShifts();
    
    // Get employees on vacation this week
    final vacationEmployeeIds = vacations.map((v) => v.employeeId).toSet();
    final availableEmployees = employees
        .where((e) => !vacationEmployeeIds.contains(e.id))
        .toList();

    if (availableEmployees.length < 9) {
      throw Exception('No hay suficientes empleados disponibles esta semana');
    }

    // Calculate rotation offset based on week number since epoch
    final weeksSinceEpoch = weekStart.difference(DateTime(2024, 1, 1)).inDays ~/ 7;
    final rotationOffset = weeksSinceEpoch % 9;

    // Create rotated assignment
    final rotatedIds = <String>[];
    for (int i = 0; i < 9; i++) {
      final index = (i + rotationOffset) % availableEmployees.length;
      rotatedIds.add(availableEmployees[index].id);
    }

    // Assign shifts: T1 gets first 7, T2 gets last 2
    final t1Members = rotatedIds.take(7).toList();
    final t2Members = rotatedIds.skip(7).take(2).toList();

    // Captain rotation: alternate between T2 members based on week
    final captainIndex = (weeksSinceEpoch ~/ 2) % t2Members.length;
    final captainId = t2Members[captainIndex];

    final shift = WeeklyShift(
      weekStart: _getWeekStart(weekStart),
      t1Members: t1Members,
      t2Members: t2Members,
      captainId: captainId,
    );

    // Save the shift
    existingShifts.removeWhere((s) => 
        s.weekStart.isAtSameMomentAs(_getWeekStart(weekStart)));
    existingShifts.add(shift);
    await _dataService.saveShifts(existingShifts);

    // Update employee statistics
    await _updateEmployeeStats(shift);

    return shift;
  }

  Future<void> _updateEmployeeStats(WeeklyShift shift) async {
    final employees = await _dataService.getEmployees();
    final updatedEmployees = <Employee>[];

    for (final employee in employees) {
      int newT1Weeks = employee.totalWeeksAsT1;
      int newT2Weeks = employee.totalWeeksAsT2;
      int newCaptainWeeks = employee.totalWeeksAsCaptain;

      if (shift.t1Members.contains(employee.id)) {
        newT1Weeks++;
      } else if (shift.t2Members.contains(employee.id)) {
        newT2Weeks++;
        if (shift.captainId == employee.id) {
          newCaptainWeeks++;
        }
      }

      updatedEmployees.add(employee.copyWith(
        totalWeeksAsT1: newT1Weeks,
        totalWeeksAsT2: newT2Weeks,
        totalWeeksAsCaptain: newCaptainWeeks,
      ));
    }

    await _dataService.saveEmployees(updatedEmployees);
  }

  Future<WeeklyShift?> getShiftForWeek(DateTime weekStart) async {
    final shifts = await _dataService.getShifts();
    final normalizedWeekStart = _getWeekStart(weekStart);
    
    try {
      return shifts.firstWhere((s) => 
          s.weekStart.isAtSameMomentAs(normalizedWeekStart));
    } catch (e) {
      return null;
    }
  }

  Future<WeeklyShift> getCurrentShift() async {
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    
    var shift = await getShiftForWeek(weekStart);
    shift ??= await generateShiftForWeek(weekStart);
    
    return shift;
  }

  Future<List<WeeklyShift>> getShiftsForYear(int year) async {
    final shifts = <WeeklyShift>[];
    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year, 12, 31);
    
    var currentWeek = _getWeekStart(startOfYear);
    
    while (currentWeek.isBefore(endOfYear)) {
      try {
        var shift = await getShiftForWeek(currentWeek);
        shift ??= await generateShiftForWeek(currentWeek);
        shifts.add(shift);
      } catch (e) {
        // Skip weeks with insufficient employees
        print('Error generating shift for week $currentWeek: $e');
      }
      
      currentWeek = currentWeek.add(const Duration(days: 7));
    }
    
    return shifts;
  }

  Future<Map<String, int>> getCaptainDistribution() async {
    final shifts = await _dataService.getShifts();
    final distribution = <String, int>{};
    
    for (final shift in shifts) {
      distribution[shift.captainId] = (distribution[shift.captainId] ?? 0) + 1;
    }
    
    return distribution;
  }

  Future<bool> canEmployeeTakeVacation(
    String employeeId, 
    DateTime startDate, 
    DateTime endDate,
    VacationType type,
  ) async {
    // Permitir siempre bajas médicas y emergencias
    if (type == VacationType.sick || type == VacationType.emergency) {
      return true;
    }
    final weekStart = _getWeekStart(startDate);
    final weekEnd = _getWeekStart(endDate);
    var currentWeek = weekStart;
    while (currentWeek.isBefore(weekEnd.add(const Duration(days: 1)))) {
      final activeVacations = await _dataService.getActiveVacationsForWeek(currentWeek);
      final vacationEmployeeIds = activeVacations.map((v) => v.employeeId).toSet();
      vacationEmployeeIds.add(employeeId); // Add this employee to vacation list
      final employees = await _dataService.getEmployees();
      final availableEmployees = employees
          .where((e) => !vacationEmployeeIds.contains(e.id))
          .length;
      // Nuevo criterio: mínimo 4 empleados disponibles (2 en T1 y 2 en T2)
      if (availableEmployees < 4) {
        return false;
      }
      currentWeek = currentWeek.add(const Duration(days: 7));
    }
    return true;
  }

  Future<List<Employee>> getAvailableEmployeesForWeek(DateTime weekStart) async {
    final employees = await _dataService.getEmployees();
    final vacations = await _dataService.getActiveVacationsForWeek(weekStart);
    final vacationEmployeeIds = vacations.map((v) => v.employeeId).toSet();
    
    return employees
        .where((e) => !vacationEmployeeIds.contains(e.id))
        .toList();
  }

  Future<void> regenerateShiftsFromWeek(DateTime weekStart) async {
    final shifts = await _dataService.getShifts();
    final normalizedWeekStart = _getWeekStart(weekStart);
    
    // Remove all shifts from this week onwards
    shifts.removeWhere((s) => 
        s.weekStart.isAtSameMomentAs(normalizedWeekStart) ||
        s.weekStart.isAfter(normalizedWeekStart));
    
    await _dataService.saveShifts(shifts);
    
    // Regenerate current week shift
    await generateShiftForWeek(normalizedWeekStart);
  }

  Future<void> regenerateShiftsForVacation(DateTime startDate, DateTime endDate) async {
    var currentWeek = _getWeekStart(startDate);
    final lastWeek = _getWeekStart(endDate);
    while (!currentWeek.isAfter(lastWeek)) {
      await regenerateShiftsFromWeek(currentWeek);
      currentWeek = currentWeek.add(const Duration(days: 7));
    }
  }
}
