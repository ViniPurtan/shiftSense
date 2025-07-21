import 'package:flutter/material.dart';
import 'package:shiftsense/models/employee.dart';
import 'package:shiftsense/services/data_service.dart';
import 'package:shiftsense/services/shift_service.dart';
import 'package:intl/intl.dart';

class AdminVacationsScreen extends StatefulWidget {
  const AdminVacationsScreen({super.key});

  @override
  State<AdminVacationsScreen> createState() => _AdminVacationsScreenState();
}

class _AdminVacationsScreenState extends State<AdminVacationsScreen> {
  late DataService _dataService;
  late ShiftService _shiftService;
  List<Vacation> _vacations = [];
  List<Employee> _employees = [];
  VacationStatus? _statusFilter;
  VacationType? _typeFilter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _dataService = await DataService.getInstance();
    _shiftService = ShiftService();
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final vacations = await _dataService.getVacations();
    final employees = await _dataService.getEmployees();
    setState(() {
      _vacations = vacations;
      _employees = employees;
      _isLoading = false;
    });
  }

  List<Vacation> get _filteredVacations {
    return _vacations.where((v) {
      if (_statusFilter != null && v.status != _statusFilter) return false;
      if (_typeFilter != null && v.type != _typeFilter) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.requestDate.compareTo(b.requestDate));
  }

  Future<void> _updateVacationStatus(Vacation vacation, VacationStatus newStatus) async {
    final updated = Vacation(
      id: vacation.id,
      employeeId: vacation.employeeId,
      startDate: vacation.startDate,
      endDate: vacation.endDate,
      type: vacation.type,
      status: newStatus,
      notes: vacation.notes,
      requestDate: vacation.requestDate,
    );
    await _dataService.updateVacation(updated);
    await _shiftService.regenerateShiftsFromWeek(vacation.startDate);
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado y turnos regenerados.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Solicitudes de Vacaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      DropdownButton<VacationStatus?>(
                        value: _statusFilter,
                        hint: const Text('Estado'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos')),
                          ...VacationStatus.values.map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(_statusText(s)),
                              )),
                        ],
                        onChanged: (v) => setState(() => _statusFilter = v),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<VacationType?>(
                        value: _typeFilter,
                        hint: const Text('Tipo'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos')),
                          ...VacationType.values.map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(_typeText(t)),
                              )),
                        ],
                        onChanged: (v) => setState(() => _typeFilter = v),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredVacations.isEmpty
                      ? const Center(child: Text('No hay solicitudes.'))
                      : ListView.builder(
                          itemCount: _filteredVacations.length,
                          itemBuilder: (context, i) {
                            final v = _filteredVacations[i];
                            final employee = _employees.firstWhere((e) => e.id == v.employeeId, orElse: () => Employee(id: v.employeeId, name: 'Desconocido', position: '', avatar: '❓'));
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(child: Text(employee.avatar)),
                                title: Text('${employee.name} (${_typeText(v.type)})'),
                                subtitle: Text('${DateFormat('d MMM yyyy').format(v.startDate)} - ${DateFormat('d MMM yyyy').format(v.endDate)}\nEstado: ${_statusText(v.status)}'),
                                isThreeLine: true,
                                trailing: PopupMenuButton<VacationStatus>(
                                  onSelected: (newStatus) => _updateVacationStatus(v, newStatus),
                                  itemBuilder: (context) => [
                                    if (v.status != VacationStatus.approved)
                                      PopupMenuItem(
                                        value: VacationStatus.approved,
                                        child: const Text('Aprobar'),
                                      ),
                                    if (v.status != VacationStatus.rejected)
                                      PopupMenuItem(
                                        value: VacationStatus.rejected,
                                        child: const Text('Rechazar'),
                                      ),
                                    if (v.status != VacationStatus.pending)
                                      PopupMenuItem(
                                        value: VacationStatus.pending,
                                        child: const Text('Pendiente'),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _statusText(VacationStatus status) {
    switch (status) {
      case VacationStatus.pending:
        return 'Pendiente';
      case VacationStatus.approved:
        return 'Aprobada';
      case VacationStatus.rejected:
        return 'Rechazada';
    }
  }

  String _typeText(VacationType type) {
    switch (type) {
      case VacationType.annual:
        return 'Vacaciones';
      case VacationType.sick:
        return 'Baja médica';
      case VacationType.personal:
        return 'Personal';
      case VacationType.emergency:
        return 'Urgencia';
    }
  }
} 
