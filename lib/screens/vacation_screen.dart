import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shiftsense/models/employee.dart';
import 'package:shiftsense/services/data_service.dart';
import 'package:shiftsense/services/shift_service.dart';

class VacationScreen extends StatefulWidget {
  const VacationScreen({super.key});

  @override
  State<VacationScreen> createState() => _VacationScreenState();
}

class _VacationScreenState extends State<VacationScreen> {
  late DataService _dataService;
  late ShiftService _shiftService;
  List<Vacation> _vacations = [];
  List<Employee> _employees = [];
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
      final vacations = await _dataService.getVacations();
      final employees = await _dataService.getEmployees();
      
      if (mounted) {
        setState(() {
          _vacations = vacations;
          _employees = employees;
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
          'Gestión de Vacaciones',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVacationDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Solicitar'),
      ),
    );
  }

  Widget _buildContent() {
    if (_vacations.isEmpty) {
      return _buildEmptyState();
    }

    final upcomingVacations = _vacations
        .where((v) => v.endDate.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final pastVacations = _vacations
        .where((v) => v.endDate.isBefore(DateTime.now()))
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (upcomingVacations.isNotEmpty) ...[
            _buildSectionHeader('Próximas Vacaciones', Icons.upcoming, upcomingVacations.length),
            const SizedBox(height: 16),
            ...upcomingVacations.map((vacation) => _buildVacationCard(vacation)),
            const SizedBox(height: 32),
          ],
          if (pastVacations.isNotEmpty) ...[
            _buildSectionHeader('Historial', Icons.history, pastVacations.length),
            const SizedBox(height: 16),
            ...pastVacations.take(10).map((vacation) => _buildVacationCard(vacation)),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVacationCard(Vacation vacation) {
    final employee = _employees.firstWhere(
      (e) => e.id == vacation.employeeId,
      orElse: () => Employee(
        id: vacation.employeeId,
        name: 'Empleado no encontrado',
        position: '',
        avatar: '❓',
      ),
    );

    final statusColor = _getStatusColor(vacation.status);
    final typeColor = _getTypeColor(vacation.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showVacationDetails(vacation, employee),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  _buildStatusChip(vacation.status, statusColor),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: typeColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getTypeIcon(vacation.type),
                      color: typeColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTypeText(vacation.type),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${vacation.durationInDays} días',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('d MMM yyyy', 'es').format(vacation.startDate)} - ${DateFormat('d MMM yyyy', 'es').format(vacation.endDate)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(VacationStatus status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        _getStatusText(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.beach_access_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin vacaciones programadas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Solicita tus vacaciones para planificar los turnos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(VacationStatus status) {
    return switch (status) {
      VacationStatus.pending => Theme.of(context).colorScheme.tertiary,
      VacationStatus.approved => Colors.green,
      VacationStatus.rejected => Theme.of(context).colorScheme.error,
    };
  }

  Color _getTypeColor(VacationType type) {
    return switch (type) {
      VacationType.annual => Theme.of(context).colorScheme.primary,
      VacationType.sick => Theme.of(context).colorScheme.error,
      VacationType.personal => Theme.of(context).colorScheme.secondary,
      VacationType.emergency => Theme.of(context).colorScheme.tertiary,
    };
  }

  IconData _getTypeIcon(VacationType type) {
    return switch (type) {
      VacationType.annual => Icons.beach_access,
      VacationType.sick => Icons.local_hospital,
      VacationType.personal => Icons.person,
      VacationType.emergency => Icons.emergency,
    };
  }

  String _getTypeText(VacationType type) {
    return switch (type) {
      VacationType.annual => 'Vacaciones',
      VacationType.sick => 'Baja médica',
      VacationType.personal => 'Personal',
      VacationType.emergency => 'Emergencia',
    };
  }

  String _getStatusText(VacationStatus status) {
    return switch (status) {
      VacationStatus.pending => 'Pendiente',
      VacationStatus.approved => 'Aprobada',
      VacationStatus.rejected => 'Rechazada',
    };
  }

  Future<void> _showAddVacationDialog() async {
    final result = await showModalBottomSheet<Vacation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VacationFormBottomSheet(employees: _employees, allVacations: _vacations),
    );

    if (result != null) {
      try {
        final canTake = await _shiftService.canEmployeeTakeVacation(
          result.employeeId,
          result.startDate,
          result.endDate,
          result.type,
        );

        if (!canTake && mounted && result.type != VacationType.sick && result.type != VacationType.emergency) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Advertencia: Puede que no haya suficiente personal para los turnos en estas fechas. El sistema intentará aprobar tu solicitud según la disponibilidad y el orden de llegada.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }

        await _dataService.addVacation(result);
        await _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Solicitud de vacaciones enviada')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al solicitar vacaciones: $e')),
          );
        }
      }
    }
  }

  void _showVacationDetails(Vacation vacation, Employee employee) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => VacationDetailsBottomSheet(
        vacation: vacation,
        employee: employee,
        onUpdate: _loadData,
      ),
    );
  }
}

class VacationFormBottomSheet extends StatefulWidget {
  final List<Employee> employees;
  final List<Vacation> allVacations;

  const VacationFormBottomSheet({super.key, required this.employees, required this.allVacations});

  @override
  State<VacationFormBottomSheet> createState() => _VacationFormBottomSheetState();
}

class _VacationFormBottomSheetState extends State<VacationFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  Employee? _selectedEmployee;
  VacationType _selectedType = VacationType.annual;
  DateTime? _startDate;
  DateTime? _endDate;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Solicitar Vacaciones',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedEmployee != null) ...[
                  VacationDaysSummary(
                    employee: _selectedEmployee!,
                    allVacations: widget.allVacations,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  DropdownButtonFormField<Employee>(
                    value: _selectedEmployee,
                    decoration: const InputDecoration(
                      labelText: 'Empleado',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.employees.map((employee) {
                      return DropdownMenuItem(
                        value: employee,
                        child: Row(
                          children: [
                            Text(employee.avatar),
                            const SizedBox(width: 8),
                            Text(employee.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (employee) => setState(() => _selectedEmployee = employee),
                    validator: (value) => value == null ? 'Selecciona un empleado' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<VacationType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de vacaciones',
                      border: OutlineInputBorder(),
                    ),
                    items: VacationType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getTypeText(type)),
                      );
                    }).toList(),
                    onChanged: (type) => setState(() => _selectedType = type!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Fecha inicio',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: _startDate == null
                                ? ''
                                : DateFormat('dd/MM/yyyy').format(_startDate!),
                          ),
                          onTap: () => _selectStartDate(),
                          validator: (value) => _startDate == null ? 'Selecciona fecha' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Fecha fin',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: _endDate == null
                                ? ''
                                : DateFormat('dd/MM/yyyy').format(_endDate!),
                          ),
                          onTap: () => _selectEndDate(),
                          validator: (value) => _endDate == null ? 'Selecciona fecha' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Solicitar Vacaciones'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _startDate = date);
      if (_endDate != null && _endDate!.isBefore(date)) {
        setState(() => _endDate = null);
      }
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final vacation = Vacation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        employeeId: _selectedEmployee!.id,
        startDate: _startDate!,
        endDate: _endDate!,
        type: _selectedType,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        requestDate: DateTime.now(),
      );
      Navigator.of(context).pop(vacation);
    }
  }

  String _getTypeText(VacationType type) {
    return switch (type) {
      VacationType.annual => 'Vacaciones anuales',
      VacationType.sick => 'Baja médica',
      VacationType.personal => 'Asuntos personales',
      VacationType.emergency => 'Emergencia',
    };
  }
}

// Widget para mostrar los días restantes de cada tipo de vacaciones
class VacationDaysSummary extends StatelessWidget {
  final Employee employee;
  final List<Vacation> allVacations;

  const VacationDaysSummary({super.key, required this.employee, required this.allVacations});

  int getRemainingDays(VacationType type) {
    final maxDays = {
      VacationType.annual: 22,
      VacationType.sick: 365,
      VacationType.personal: 5,
      VacationType.emergency: 3,
    };
    final usedDays = allVacations
      .where((v) => v.employeeId == employee.id && v.type == type && v.status == VacationStatus.approved)
      .fold<int>(0, (sum, v) => sum + v.durationInDays);
    return maxDays[type]! - usedDays;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildType(context, 'Anuales', getRemainingDays(VacationType.annual)),
            _buildType(context, 'Baja', getRemainingDays(VacationType.sick)),
            _buildType(context, 'Personal', getRemainingDays(VacationType.personal)),
            _buildType(context, 'Urgencia', getRemainingDays(VacationType.emergency)),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildType(BuildContext context, String label, int days) {
    return Column(
      children: [
        Text('$days', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class VacationDetailsBottomSheet extends StatelessWidget {
  final Vacation vacation;
  final Employee employee;
  final VoidCallback onUpdate;

  const VacationDetailsBottomSheet({
    super.key,
    required this.vacation,
    required this.employee,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          employee.avatar,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              employee.position,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(context, 'Tipo', _getTypeText(vacation.type)),
                  _buildDetailRow(context, 'Estado', _getStatusText(vacation.status)),
                  _buildDetailRow(context, 'Duración', '${vacation.durationInDays} días'),
                  _buildDetailRow(context, 'Fecha inicio', DateFormat('dd/MM/yyyy').format(vacation.startDate)),
                  _buildDetailRow(context, 'Fecha fin', DateFormat('dd/MM/yyyy').format(vacation.endDate)),
                  _buildDetailRow(context, 'Solicitado', DateFormat('dd/MM/yyyy').format(vacation.requestDate)),
                  if (vacation.notes != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Notas',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(vacation.notes!),
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

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeText(VacationType type) {
    return switch (type) {
      VacationType.annual => 'Vacaciones anuales',
      VacationType.sick => 'Baja médica',
      VacationType.personal => 'Asuntos personales',
      VacationType.emergency => 'Emergencia',
    };
  }

  String _getStatusText(VacationStatus status) {
    return switch (status) {
      VacationStatus.pending => 'Pendiente',
      VacationStatus.approved => 'Aprobada',
      VacationStatus.rejected => 'Rechazada',
    };
  }
}
