import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shiftsense/models/employee.dart';
import 'package:shiftsense/services/data_service.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  late DataService _dataService;
  List<Employee> _employees = [];
  List<Vacation> _vacations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _dataService = await DataService.getInstance();
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final employees = await _dataService.getEmployees();
      final vacations = await _dataService.getVacations();

      if (mounted) {
        setState(() {
          _employees = employees;
          _vacations = vacations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar empleados: $e')),
        );
      }
    }
  }

  List<Employee> get _filteredEmployees {
    if (_searchQuery.isEmpty) return _employees;
    
    return _employees
        .where((employee) =>
            employee.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            employee.position.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Equipo de Trabajo',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildSearchAndStats(),
        Expanded(
          child: _filteredEmployees.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = _filteredEmployees[index];
                      return _buildEmployeeCard(employee);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchAndStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
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
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Buscar empleado...',
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 16),
          _buildTeamStats(),
        ],
      ),
    );
  }

  Widget _buildTeamStats() {
    final activeVacations = _vacations
        .where((v) => v.isActiveOn(DateTime.now()) && v.status == VacationStatus.approved)
        .length;
    
    final availableEmployees = _employees.length - activeVacations;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Empleados',
            _employees.length.toString(),
            Icons.people,
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Disponibles',
            availableEmployees.toString(),
            Icons.person,
            Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'De Vacaciones',
            activeVacations.toString(),
            Icons.beach_access,
            Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    final employeeVacations = _vacations
        .where((v) => v.employeeId == employee.id)
        .toList();
    
    final activeVacation = employeeVacations
        .where((v) => v.isActiveOn(DateTime.now()) && v.status == VacationStatus.approved)
        .firstOrNull;

    final upcomingVacations = employeeVacations
        .where((v) => v.startDate.isAfter(DateTime.now()) && v.status == VacationStatus.approved)
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: activeVacation != null
            ? Border.all(
                color: Theme.of(context).colorScheme.tertiary,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showEmployeeDetails(employee, employeeVacations),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: activeVacation != null
                            ? Theme.of(context).colorScheme.tertiary.withOpacity(0.2)
                            : Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          employee.avatar,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      if (activeVacation != null)
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.beach_access,
                              color: Theme.of(context).colorScheme.onTertiary,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
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
                        if (activeVacation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'De vacaciones hasta ${DateFormat('d/M/yyyy').format(activeVacation.endDate)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildEmployeeStats(employee, upcomingVacations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeStats(Employee employee, int upcomingVacations) {
    final totalWeeks = employee.totalWeeksAsT1 + employee.totalWeeksAsT2;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMiniStat(
              'T1',
              employee.totalWeeksAsT1.toString(),
              Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMiniStat(
              'T2',
              employee.totalWeeksAsT2.toString(),
              Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMiniStat(
              'Capitán',
              employee.totalWeeksAsCaptain.toString(),
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMiniStat(
              'Próx. Vac.',
              upcomingVacations.toString(),
              Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron empleados',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta modificar tu búsqueda',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmployeeDetails(Employee employee, List<Vacation> vacations) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmployeeDetailsBottomSheet(
        employee: employee,
        vacations: vacations,
      ),
    );
  }
}

class EmployeeDetailsBottomSheet extends StatelessWidget {
  final Employee employee;
  final List<Vacation> vacations;

  const EmployeeDetailsBottomSheet({
    super.key,
    required this.employee,
    required this.vacations,
  });

  @override
  Widget build(BuildContext context) {
    final totalWeeks = employee.totalWeeksAsT1 + employee.totalWeeksAsT2;
    final t2Percentage = totalWeeks > 0 ? (employee.totalWeeksAsT2 / totalWeeks * 100).toDouble() : 0.0;
    final captainPercentage = employee.totalWeeksAsT2 > 0 
        ? (employee.totalWeeksAsCaptain / employee.totalWeeksAsT2 * 100).toDouble() : 0.0;

    final upcomingVacations = vacations
        .where((v) => v.startDate.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          employee.avatar,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              employee.position,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Statistics
                  Text(
                    'Estadísticas de Turnos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Turno T1',
                          employee.totalWeeksAsT1.toString(),
                          'semanas',
                          Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Turno T2',
                          employee.totalWeeksAsT2.toString(),
                          'semanas',
                          Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Capitán',
                          employee.totalWeeksAsCaptain.toString(),
                          'semanas',
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total',
                          totalWeeks.toString(),
                          'semanas',
                          Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Percentages
                  Text(
                    'Distribución',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildPercentageBar(
                    context,
                    'Tiempo en T2',
                    t2Percentage,
                    Theme.of(context).colorScheme.tertiary,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildPercentageBar(
                    context,
                    'Eficiencia como Capitán',
                    captainPercentage,
                    Theme.of(context).colorScheme.primary,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Upcoming vacations
                  if (upcomingVacations.isNotEmpty) ...[
                    Text(
                      'Próximas Vacaciones',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...upcomingVacations.take(3).map((vacation) => 
                        _buildVacationItem(context, vacation)),
                  ] else ...[
                    Text(
                      'Sin vacaciones programadas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String unit,
    Color color,
  ) {
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            unit,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageBar(
    BuildContext context,
    String label,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${percentage.round()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildVacationItem(BuildContext context, Vacation vacation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${DateFormat('d/M/yyyy').format(vacation.startDate)} - ${DateFormat('d/M/yyyy').format(vacation.endDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            '${vacation.durationInDays} días',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}