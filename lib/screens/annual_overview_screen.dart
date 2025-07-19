import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shiftsense/models/employee.dart';
import 'package:shiftsense/services/data_service.dart';
import 'package:shiftsense/services/shift_service.dart';

class AnnualOverviewScreen extends StatefulWidget {
  const AnnualOverviewScreen({super.key});

  @override
  State<AnnualOverviewScreen> createState() => _AnnualOverviewScreenState();
}

class _AnnualOverviewScreenState extends State<AnnualOverviewScreen> {
  late DataService _dataService;
  late ShiftService _shiftService;
  
  int _selectedYear = DateTime.now().year;
  List<Employee> _employees = [];
  List<WeeklyShift> _yearShifts = [];
  Map<String, int> _captainStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _dataService = await DataService.getInstance();
    _shiftService = ShiftService();
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final employees = await _dataService.getEmployees();
      final yearShifts = await _shiftService.getShiftsForYear(_selectedYear);
      final captainStats = await _shiftService.getCaptainDistribution();

      if (mounted) {
        setState(() {
          _employees = employees;
          _yearShifts = yearShifts;
          _captainStats = captainStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Resumen Anual',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          PopupMenuButton<int>(
            icon: Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            onSelected: (year) {
              setState(() => _selectedYear = year);
              _loadData();
            },
            itemBuilder: (context) => List.generate(5, (index) {
              final year = DateTime.now().year - 2 + index;
              return PopupMenuItem(
                value: year,
                child: Text(year.toString()),
              );
            }),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildYearHeader(),
            const SizedBox(height: 24),
            _buildOverallStats(),
            const SizedBox(height: 32),
            _buildCaptainDistribution(),
            const SizedBox(height: 32),
            _buildEmployeeStats(),
            const SizedBox(height: 32),
            _buildMonthlyGrid(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildYearHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics_outlined,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Año $_selectedYear',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Análisis completo de turnos y rotaciones',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats() {
    final totalWeeks = _yearShifts.length;
    final currentWeek = DateTime.now().difference(DateTime(_selectedYear, 1, 1)).inDays ~/ 7 + 1;
    final completionRate = totalWeeks > 0 ? (currentWeek / 52 * 100).clamp(0, 100) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas Generales',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Semanas Planificadas',
                totalWeeks.toString(),
                Icons.calendar_month,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Progreso Anual',
                '${completionRate.round()}%',
                Icons.trending_up,
                Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCaptainDistribution() {
    if (_captainStats.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribución de Capitanía',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _employees.map((employee) {
              final weeks = _captainStats[employee.id] ?? 0;
              final totalCaptainWeeks = _captainStats.values.fold(0, (sum, w) => sum + w);
              final percentage = totalCaptainWeeks > 0 ? (weeks / totalCaptainWeeks * 100) : 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        employee.avatar,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.name.split(' ').first,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$weeks sem.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas por Empleado',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._employees.map((employee) => _buildEmployeeStatCard(employee)),
      ],
    );
  }

  Widget _buildEmployeeStatCard(Employee employee) {
    final t1Weeks = _yearShifts.where((s) => s.t1Members.contains(employee.id)).length;
    final t2Weeks = _yearShifts.where((s) => s.t2Members.contains(employee.id)).length;
    final captainWeeks = _yearShifts.where((s) => s.captainId == employee.id).length;
    final totalWeeks = t1Weeks + t2Weeks;

    final t2Percentage = totalWeeks > 0 ? (t2Weeks / totalWeeks * 100).toDouble() : 0.0;
    final captainPercentage = t2Weeks > 0 ? (captainWeeks / t2Weeks * 100).toDouble() : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  employee.avatar,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      employee.position,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat('T1', t1Weeks, Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 12),
              _buildMiniStat('T2', t2Weeks, Theme.of(context).colorScheme.tertiary),
              const SizedBox(width: 12),
              _buildMiniStat('Capitán', captainWeeks, Theme.of(context).colorScheme.primary),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPercentageBar(
                  'T2 %',
                  t2Percentage,
                  Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPercentageBar(
                  'Capitán %',
                  captainPercentage,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${percentage.round()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildMonthlyGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vista Mensual',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final month = index + 1;
            final monthName = DateFormat('MMMM', 'es').format(DateTime(_selectedYear, month));
            final monthShifts = _getShiftsForMonth(month);
            
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    monthName.substring(0, 3).toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${monthShifts.length}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'semanas',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  List<WeeklyShift> _getShiftsForMonth(int month) {
    return _yearShifts.where((shift) => shift.weekStart.month == month).toList();
  }
}