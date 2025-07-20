import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shiftsense/models/employee.dart';
import 'package:shiftsense/services/data_service.dart';
import 'package:shiftsense/services/shift_service.dart';

class CurrentShiftScreen extends StatefulWidget {
  const CurrentShiftScreen({super.key});

  @override
  State<CurrentShiftScreen> createState() => _CurrentShiftScreenState();
}

class _CurrentShiftScreenState extends State<CurrentShiftScreen> {
  late Future<WeeklyShift?> _currentShiftFuture;
  late Future<List<Employee>> _employeesFuture;
  final ShiftService _shiftService = ShiftService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _currentShiftFuture = _initializeAndGetShift();
    _employeesFuture = DataService.getInstance().then((ds) => ds.getEmployees());
  }

  Future<WeeklyShift?> _initializeAndGetShift() async {
    await _shiftService.initialize();
    try {
      return await _shiftService.getCurrentShift();
    } catch (e) {
      print('Error getting current shift: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([_currentShiftFuture, _employeesFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar los datos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _loadData();
                    });
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final currentShift = snapshot.data![0] as WeeklyShift?;
        final employees = snapshot.data![1] as List<Employee>;
        final employeeMap = {for (var e in employees) e.id: e};

        if (currentShift == null) {
          return _buildEmptyState(context);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, currentShift),
              const SizedBox(height: 24),
              _buildSectionTitle(context),
              const SizedBox(height: 16),
              _buildT1Shift(context, currentShift, employeeMap),
              const SizedBox(height: 16),
              _buildT2Shift(context, currentShift, employeeMap),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay turnos configurados',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Configura los turnos para comenzar',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              try {
                await _shiftService.initialize();
                await _shiftService.getCurrentShift();
                setState(() {
                  _loadData();
                });
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Generar Turnos'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WeeklyShift shift) {
    final now = DateTime.now();
    final weekStart = shift.weekStart;
    final weekEnd = shift.weekEnd;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Turnos Actuales',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, d \'de\' MMMM y', 'es').format(now),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          Text(
            'Semana del ${DateFormat('d', 'es').format(weekStart)} al ${DateFormat('d', 'es').format(weekEnd)}',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Esta semana',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'ACTUAL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildT1Shift(BuildContext context, WeeklyShift shift, Map<String, Employee> employeeMap) {
    final t1Employees = shift.t1Members
        .map((id) => employeeMap[id])
        .where((e) => e != null)
        .cast<Employee>()
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF8FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF3B82F6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.groups,
                color: Color(0xFF1E40AF),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'TURNO T1',
                style: TextStyle(
                  color: Color(0xFF1E40AF),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${t1Employees.length} personas',
            style: const TextStyle(
              color: Color(0xFF1E40AF),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: t1Employees
                .map((employee) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(employee.avatar, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            employee.name.split(' ')[0],
                            style: const TextStyle(
                              color: Color(0xFF1E40AF),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildT2Shift(BuildContext context, WeeklyShift shift, Map<String, Employee> employeeMap) {
    final t2Employees = shift.t2Members
        .map((id) => employeeMap[id])
        .where((e) => e != null)
        .cast<Employee>()
        .toList();
    
    final captain = employeeMap[shift.captainId];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B5CF6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.groups,
                color: Color(0xFF7C3AED),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'TURNO T2',
                style: TextStyle(
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.star,
                color: Color(0xFF7C3AED),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${t2Employees.length} personas',
            style: const TextStyle(
              color: Color(0xFF7C3AED),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...t2Employees.map((employee) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(employee.avatar, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      employee.name.split(' ')[0],
                      style: const TextStyle(
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    if (employee.id == shift.captainId) ..[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'CAPITÁN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )),
          if (captain != null) ..[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.menu,
                    color: Color(0xFF7C3AED),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.mic_none,
                    color: Color(0xFF7C3AED),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Líder: ${captain.name.split(' ')[0]}',
                    style: const TextStyle(
                      color: Color(0xFF7C3AED),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
