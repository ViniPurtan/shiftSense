## 🎯 Estrategia de Testing

### Filosofía de Testing

ShiftSense implementa una estrategia de testing integral que abarca:

- **Unit Tests**: Validación de lógica de negocio individual
- **Integration Tests**: Verificación de flujos completos
- **Widget Tests**: Pruebas de componentes UI
- **Manual Testing**: Validación de experiencia de usuario
- **Performance Tests**: Optimización y rendimiento

---

## 🔧 Configuración de Testing en FlutterFlow

### Estructura de Testing
```
test/
├── unit/
│   ├── services/
│   │   ├── shift_service_test.dart
│   │   ├── vacation_service_test.dart
│   │   ├── data_service_test.dart
│   │   └── stats_service_test.dart
│   └── models/
│       ├── employee_test.dart
│       ├── vacation_test.dart
│       └── weekly_shift_test.dart
├── integration/
│   ├── shift_flow_test.dart
│   ├── vacation_flow_test.dart
│   └── data_persistence_test.dart
├── widget/
│   ├── employee_card_test.dart
│   ├── vacation_card_test.dart
│   └── shift_info_card_test.dart
└── test_data/
    ├── mock_employees.dart
    ├── mock_vacations.dart
    └── test_helpers.dart
```

### Dependencias de Testing
```yaml
# En pubspec.yaml - dev_dependencies
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.7
  fake_async: ^1.3.1
  integration_test:
    sdk: flutter
```

---

## 🧩 Unit Tests - Servicios

### ShiftService Tests

```dart
// test/unit/services/shift_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shiftsense/services/shift_service.dart';
import 'package:shiftsense/models/employee.dart';
import 'package:shiftsense/models/vacation.dart';
import '../../test_data/test_helpers.dart';

void main() {
  group('ShiftService Tests', () {
    late List<Employee> testEmployees;
    
    setUp(() {
      testEmployees = TestHelpers.createTestEmployees();
    });
    
    group('calculateWeekOffset', () {
      test('should calculate correct week offset for epoch date', () {
        final epoch = DateTime(2024, 1, 1);
        final result = ShiftService.calculateWeekOffset(epoch);
        expect(result, equals(0));
      });
      
      test('should calculate correct week offset for one week later', () {
        final oneWeekLater = DateTime(2024, 1, 8);
        final result = ShiftService.calculateWeekOffset(oneWeekLater);
        expect(result, equals(1));
      });
      
      test('should handle negative dates correctly', () {
        final beforeEpoch = DateTime(2023, 12, 25);
        final result = ShiftService.calculateWeekOffset(beforeEpoch);
        expect(result, isNegative);
      });
    });
    
    group('getWeekStart', () {
      test('should return Monday for week offset 0', () {
        final weekStart = ShiftService.getWeekStart(0);
        expect(weekStart.weekday, equals(DateTime.monday));
        expect(weekStart.year, equals(2024));
        expect(weekStart.month, equals(1));
        expect(weekStart.day, equals(1));
      });
      
      test('should return correct Monday for positive offset', () {
        final weekStart = ShiftService.getWeekStart(5);
        expect(weekStart.weekday, equals(DateTime.monday));
      });
    });
    
    group('generateShiftAssignment', () {
      test('should generate valid shift assignment with all employees available', () {
        final shift = ShiftService.generateShiftAssignment(
          testEmployees,
          [], // no vacations
          0,
        );
        
        expect(shift.t1Members.length, equals(7));
        expect(shift.t2Members.length, equals(2));
        expect(shift.t2Members.contains(shift.captainId), isTrue);
        expect(shift.weekOffset, equals(0));
      });
      
      test('should throw exception when insufficient staff', () {
        final limitedEmployees = testEmployees.take(5).toList();
        
        expect(
          () => ShiftService.generateShiftAssignment(
            limitedEmployees,
            [],
            0,
          ),
          throwsA(isA<InsufficientStaffException>()),
        );
      });
      
      test('should exclude employees on vacation', () {
        final vacations = [
          TestHelpers.createTestVacation(
            employeeId: testEmployees[0].id,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 7),
            status: VacationStatus.approved,
          ),
        ];
        
        final shift = ShiftService.generateShiftAssignment(
          testEmployees,
          vacations,
          0,
        );
        
        final allMembers = [...shift.t1Members, ...shift.t2Members];
        expect(allMembers.contains(testEmployees[0].id), isFalse);
      });
      
      test('should rotate captain correctly', () {
        final shift1 = ShiftService.generateShiftAssignment(
          testEmployees,
          [],
          0,
        );
        
        final shift2 = ShiftService.generateShiftAssignment(
          testEmployees,
          [],
          1,
        );
        
        // Captain should be different in consecutive weeks
        // (assuming same T2 members)
        if (shift1.t2Members.toSet().containsAll(shift2.t2Members.toSet())) {
          expect(shift1.captainId, isNot(equals(shift2.captainId)));
        }
      });
    });
    
    group('equitable rotation', () {
      test('should distribute roles fairly over multiple weeks', () {
        final shifts = <WeeklyShift>[];
        final employeeStats = <String, Map<String, int>>{};
        
        // Initialize stats
        for (final employee in testEmployees) {
          employeeStats[employee.id] = {
            't1': 0,
            't2': 0,
            'captain': 0,
          };
        }
        
        // Generate 20 weeks of shifts
        for (int week = 0; week < 20; week++) {
          final shift = ShiftService.generateShiftAssignment(
            testEmployees,
            [],
            week,
          );
          shifts.add(shift);
          
          // Count assignments
          for (final memberId in shift.t1Members) {
            employeeStats[memberId]!['t1'] = 
                employeeStats[memberId]!['t1']! + 1;
          }
          
          for (final memberId in shift.t2Members) {
            employeeStats[memberId]!['t2'] = 
                employeeStats[memberId]!['t2']! + 1;
          }
          
          employeeStats[shift.captainId]!['captain'] = 
              employeeStats[shift.captainId]!['captain']! + 1;
        }
        
        // Verify fairness
        final t1Counts = employeeStats.values.map((stats) => stats['t1']!).toList();
        final t2Counts = employeeStats.values.map((stats) => stats['t2']!).toList();
        
        final t1Max = t1Counts.reduce((a, b) => a > b ? a : b);
        final t1Min = t1Counts.reduce((a, b) => a < b ? a : b);
        final t2Max = t2Counts.reduce((a, b) => a > b ? a : b);
        final t2Min = t2Counts.reduce((a, b) => a < b ? a : b);
        
        // Difference should be minimal (at most 2)
        expect(t1Max - t1Min, lessThanOrEqualTo(2));
        expect(t2Max - t2Min, lessThanOrEqualTo(2));
      });
    });
  });
}
```

### VacationService Tests

```dart
// test/unit/services/vacation_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shiftsense/services/vacation_service.dart';
import '../../test_data/test_helpers.dart';

void main() {
  group('VacationService Tests', () {
    late List<Employee> testEmployees;
    
    setUp(() {
      testEmployees = TestHelpers.createTestEmployees();
    });
    
    group('validateVacationRequest', () {
      test('should validate correct vacation request', () {
        final vacation = TestHelpers.createTestVacation(
          employeeId: testEmployees[0].id,
          startDate: DateTime.now().add(Duration(days: 10)),
          endDate: DateTime.now().add(Duration(days: 15)),
          type: VacationType.annual,
        );
        
        final result = VacationService.validateVacationRequest(
          vacation,
          testEmployees,
          [],
        );
        
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });
      
      test('should reject vacation with end date before start date', () {
        final vacation = TestHelpers.createTestVacation(
          employeeId: testEmployees[0].id,
          startDate: DateTime.now().add(Duration(days: 15)),
          endDate: DateTime.now().add(Duration(days: 10)),
          type: VacationType.annual,
        );
        
        final result = VacationService.validateVacationRequest(
          vacation,
          testEmployees,
          [],
        );
        
        expect(result.isValid, isFalse);
        expect(result.errors, contains(
          'La fecha de inicio debe ser anterior a la fecha de fin'
        ));
      });
      
      test('should reject vacation with insufficient advance notice', () {
        final vacation = TestHelpers.createTestVacation(
          employeeId: testEmployees[0].id,
          startDate: DateTime.now().add(Duration(days: 3)),
          endDate: DateTime.now().add(Duration(days: 8)),
          type: VacationType.annual,
        );
        
        final result = VacationService.validateVacationRequest(
          vacation,
          testEmployees,
          [],
        );
        
        expect(result.isValid, isFalse);
        expect(result.errors, contains(
          'Las vacaciones deben solicitarse con al menos 7 días de anticipación'
        ));
      });
      
      test('should allow emergency vacation with short notice', () {
        final vacation = TestHelpers.createTestVacation(
          employeeId: testEmployees[0].id,
          startDate: DateTime.now().add(Duration(days: 1)),
          endDate: DateTime.now().add(Duration(days: 3)),
          type: VacationType.emergency,
        );
        
        final result = VacationService.validateVacationRequest(
          vacation,
          testEmployees,
          [],
        );
        
        expect(result.isValid, isTrue);
      });
      
      test('should reject vacation exceeding maximum days', () {
        final vacation = TestHelpers.createTestVacation(
          employeeId: testEmployees[0].id,
          startDate: DateTime.now().add(Duration(days: 10)),
          endDate: DateTime.now().add(Duration(days: 45)),
          type: VacationType.annual,
        );
        
        final result = VacationService.validateVacationRequest(
          vacation,
          testEmployees,
          [],
        );
        
        expect(result.isValid, isFalse);
        expect(result.errors, contains(
          'Las vacaciones no pueden exceder 30 días'
        ));
      });
      
      test('should detect conflicts with existing vacations', () {
        final existingVacation = TestHelpers.createTestVacation(
          employeeId: testEmployees[0].id,
          startDate: DateTime.now().add(Duration(days: 10)),
          endDate: DateTime.now().add(Duration(days: 15)),
          status: VacationStatus.approved,
        );
        
        final newVacation = TestHelpers.createTestVacation(
          employeeId: testEmployees[0].id,
          startDate: DateTime.now().add(Duration(days: 12)),
          endDate: DateTime.now().add(Duration(days: 18)),
          type: VacationType.annual,
        );
        
        final result = VacationService.validateVacationRequest(
          newVacation,
          testEmployees,
          [existingVacation],
        );
        
        expect(result.warnings, isNotEmpty);
      });
      
      test('should validate minimum staff requirements', () {
        // Create vacations for 4 employees during the same period
        final vacations = testEmployees.take(4).map((employee) => 
          TestHelpers.createTestVacation(
            employeeId: employee.id,
            startDate: DateTime.now().add(Duration(days: 10)),
            endDate: DateTime.now().add(Duration(days: 15)),
            status: VacationStatus.approved,
          )
        ).toList();
        
        final newVacation = TestHelpers.createTestVacation(
          employeeId: testEmployees[4].id,
          startDate: DateTime.now().add(Duration(days: 12)),
          endDate: DateTime.now().add(Duration(days: 14)),
          type: VacationType.annual,
        );
        
        final result = VacationService.validateVacationRequest(
          newVacation,
          testEmployees,
          vacations,
        );
        
        expect(result.isValid, isFalse);
        expect(result.errors, contains(
          contains('Personal insuficiente')
        ));
      });
    });
  });
}
```

---

## 🔗 Integration Tests

### Flujo Completo de Turnos

```dart
// test/integration/shift_flow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shiftsense/main.dart' as app;
import 'package:shiftsense/services/data_service.dart';
import 'package:shiftsense/services/shift_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Shift Flow Integration Tests', () {
    setUp(() async {
      await DataService.clearAllData();
      await DataService.initialize();
    });
    
    testWidgets('complete shift generation and navigation flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Verify initial state
      expect(find.text('Turnos'), findsOneWidget);
      
      // Navigate to current week
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();
      
      // Verify shift information is displayed
      expect(find.text('T1'), findsWidgets);
      expect(find.text('T2'), findsWidgets);
      expect(find.text('CAPITÁN'), findsOneWidget);
      
      // Navigate to next week
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      
      // Verify week changed
      expect(find.text('CAPITÁN'), findsOneWidget);
      
      // Navigate to previous week
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      
      // Verify we're back to original week
      expect(find.text('CAPITÁN'), findsOneWidget);
    });
    
    testWidgets('shift generation with vacations', (WidgetTester tester) async {
      // Create a vacation that affects current week
      final employees = await DataService.loadEmployees();
      final vacation = Vacation(
        id: 'test_vacation',
        employeeId: employees[0].id,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        requestDate: DateTime.now(),
        type: VacationType.annual,
        status: VacationStatus.approved,
      );
      
      await DataService.saveVacation(vacation);
      
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to shifts
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();
      
      // Verify employee on vacation is not in current shift
      final currentWeekOffset = ShiftService.calculateWeekOffset();
      final shift = await DataService.getWeeklyShift(currentWeekOffset);
      
      if (shift != null) {
        final allMembers = [...shift.t1Members, ...shift.t2Members];
        expect(allMembers.contains(employees[0].id), isFalse);
      }
    });
  });
}
```

---

## 🎨 Widget Tests

### EmployeeCard Tests

```dart
// test/widget/employee_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftsense/widgets/employee_card.dart';
import 'package:shiftsense/models/employee.dart';

void main() {
  group('EmployeeCard Widget Tests', () {
    late Employee testEmployee;
    
    setUp(() {
      testEmployee = Employee(
        id: 'test_001',
        name: 'Juan Pérez',
        position: 'Técnico',
        avatar: 'https://example.com/avatar.jpg',
        totalWeeksAsT1: 10,
        totalWeeksAsT2: 5,
        totalWeeksAsCaptain: 2,
        createdAt: DateTime.now(),
        isActive: true,
      );
    });
    
    testWidgets('should display employee information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmployeeCard(
              employee: testEmployee,
              isCaptain: false,
            ),
          ),
        ),
      );
      
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('Técnico'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });
    
    testWidgets('should show captain badge when employee is captain', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmployeeCard(
              employee: testEmployee,
              isCaptain: true,
            ),
          ),
        ),
      );
      
      expect(find.text('CAPITÁN'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });
    
    testWidgets('should not show captain badge when employee is not captain', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmployeeCard(
              employee: testEmployee,
              isCaptain: false,
            ),
          ),
        ),
      );
      
      expect(find.text('CAPITÁN'), findsNothing);
      expect(find.byType(Chip), findsNothing);
    });
    
    testWidgets('should show stats when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmployeeCard(
              employee: testEmployee,
              isCaptain: false,
              showStats: true,
            ),
          ),
        ),
      );
      
      expect(find.text('T1: 10'), findsOneWidget);
      expect(find.text('T2: 5'), findsOneWidget);
      expect(find.text('Cap: 2'), findsOneWidget);
    });
  });
}
```

---

## 📊 Performance Tests

### Pruebas de Rendimiento

```dart
// test/performance/performance_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shiftsense/services/shift_service.dart';
import 'package:shiftsense/services/stats_service.dart';
import '../test_data/test_helpers.dart';

void main() {
  group('Performance Tests', () {
    test('shift generation should complete within reasonable time', () async {
      final employees = TestHelpers.createTestEmployees();
      final stopwatch = Stopwatch()..start();
      
      // Generate 100 weeks of shifts
      for (int i = 0; i < 100; i++) {
        ShiftService.generateShiftAssignment(employees, [], i);
      }
      
      stopwatch.stop();
      
      // Should complete in less than 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
    
    test('stats calculation should be efficient for large datasets', () async {
      final employees = TestHelpers.createTestEmployees();
      final shifts = <WeeklyShift>[];
      
      // Generate large dataset
      for (int i = 0; i < 500; i++) {
        shifts.add(ShiftService.generateShiftAssignment(employees, [], i));
      }
      
      final stopwatch = Stopwatch()..start();
      
      // Calculate stats for all employees
      for (final employee in employees) {
        StatsService.calculateEmployeeStats(employee, shifts, []);
      }
      
      stopwatch.stop();
      
      // Should complete in less than 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
    
    test('data persistence should be fast', () async {
      final employees = TestHelpers.createTestEmployees();
      final stopwatch = Stopwatch()..start();
      
      // Save and load employees multiple times
      for (int i = 0; i < 50; i++) {
        await DataService.saveEmployees(employees);
        await DataService.loadEmployees();
      }
      
      stopwatch.stop();
      
      // Should complete in less than 3 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });
  });
}
```

---

## 🎭 Test Data y Helpers

### Helper Functions

```dart
// test/test_data/test_helpers.dart

import 'package:shiftsense/models/employee.dart';
import 'package:shiftsense/models/vacation.dart';
import 'package:shiftsense/models/weekly_shift.dart';

class TestHelpers {
  static List<Employee> createTestEmployees() {
    return [
      Employee(
        id: 'emp_001',
        name: 'Ana García',
        position: 'Técnico',
        avatar: 'https://ui-avatars.com/api/?name=Ana+Garcia',
        totalWeeksAsT1: 0,
        totalWeeksAsT2: 0,
        totalWeeksAsCaptain: 0,
        createdAt: DateTime.now(),
        isActive: true,
      ),
      Employee(
        id: 'emp_002',
        name: 'Carlos Méndez',
        position: 'Supervisor',
        avatar: 'https://ui-avatars.com/api/?name=Carlos+Mendez',
        totalWeeksAsT1: 0,
        totalWeeksAsT2: 0,
        totalWeeksAsCaptain: 0,
        createdAt: DateTime.now(),
        isActive: true,
      ),
      // ... resto de empleados de prueba
    ];
  }
  
  static Vacation createTestVacation({
    String? id,
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
    VacationType type = VacationType.annual,
    VacationStatus status = VacationStatus.pending,
    String? notes,
  }) {
    return Vacation(
      id: id ?? 'vacation_${DateTime.now().millisecondsSinceEpoch}',
      employeeId: employeeId,
      startDate: startDate,
      endDate: endDate,
      requestDate: DateTime.now(),
      type: type,
      status: status,
      notes: notes,
    );
  }
  
  static WeeklyShift createTestShift({
    String? id,
    required DateTime weekStart,
    required List<String> t1Members,
    required List<String> t2Members,
    required String captainId,
    required int weekOffset,
  }) {
    return WeeklyShift(
      id: id ?? 'shift_${weekOffset}_${weekStart.millisecondsSinceEpoch}',
      weekStart: weekStart,
      t1Members: t1Members,
      t2Members: t2Members,
      captainId: captainId,
      createdAt: DateTime.now(),
      weekOffset: weekOffset,
    );
  }
  
  /// Crea un conjunto de datos de prueba realista
  static Future<Map<String, dynamic>> createRealisticTestData() async {
    final employees = createTestEmployees();
    final shifts = <WeeklyShift>[];
    final vacations = <Vacation>[];
    
    // Generar 6 meses de turnos
    for (int week = 0; week < 26; week++) {
      shifts.add(ShiftService.generateShiftAssignment(employees, vacations, week));
    }
    
    // Agregar algunas vacaciones realistas
    vacations.addAll([
      createTestVacation(
        employeeId: employees[0].id,
        startDate: DateTime.now().add(Duration(days: 30)),
        endDate: DateTime.now().add(Duration(days: 37)),
        type: VacationType.annual,
        status: VacationStatus.approved,
      ),
      createTestVacation(
        employeeId: employees[1].id,
        startDate: DateTime.now().add(Duration(days: 15)),
        endDate: DateTime.now().add(Duration(days: 17)),
        type: VacationType.sick,
        status: VacationStatus.pending,
      ),
    ]);
    
    return {
      'employees': employees,
      'shifts': shifts,
      'vacations': vacations,
    };
  }
}
```

---

## ✅ Lista de Verificación de Testing

Antes de continuar al siguiente paso, asegúrate de haber completado:

- [ ] ✅ Unit tests para todos los servicios
- [ ] ✅ Integration tests para flujos principales
- [ ] ✅ Widget tests para componentes UI
- [ ] ✅ Performance tests implementados
- [ ] ✅ Test data y helpers configurados
- [ ] ✅ Cobertura de código > 80%
- [ ] ✅ Tests de regresión implementados
- [ ] ✅ Manual testing completado

---

## 🔧 Comandos de Testing

### Ejecutar Tests
```bash
# Todos los tests
flutter test

# Solo unit tests
flutter test test/unit/

# Solo integration tests
flutter test test/integration/

# Con coverage
flutter test --coverage

# Tests específicos
flutter test test/unit/services/shift_service_test.dart
```

### Generar Reporte de Coverage
```bash
# Instalar herramientas
brew install lcov  # macOS
sudo apt-get install lcov  # Ubuntu

# Generar reporte HTML
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```
