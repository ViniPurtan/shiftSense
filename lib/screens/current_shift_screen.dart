import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shiftsense/models/employee.dart';
import 'package:shiftsense/services/shift_service.dart';
import 'package:shiftsense/widgets/shift_card.dart';

class CurrentShiftScreen extends StatefulWidget {
  const CurrentShiftScreen({super.key});

  @override
  State<CurrentShiftScreen> createState() => _CurrentShiftScreenState();
}

class _CurrentShiftScreenState extends State<CurrentShiftScreen> {
  final PageController _pageController = PageController(initialPage: 1);
  final ShiftService _shiftService = ShiftService();
  
  DateTime _currentDate = DateTime.now();
  List<WeeklyShift> _shifts = [];
  int _currentPageIndex = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  Future<void> _loadShifts() async {
    setState(() => _isLoading = true);
    
    try {
      final currentWeekStart = _getWeekStart(_currentDate);
      final previousWeek = currentWeekStart.subtract(const Duration(days: 7));
      final nextWeek = currentWeekStart.add(const Duration(days: 7));

      final shifts = <WeeklyShift>[];
      
      // Load previous, current, and next week shifts
      for (final weekStart in [previousWeek, currentWeekStart, nextWeek]) {
        try {
          var shift = await _shiftService.getShiftForWeek(weekStart);
          shift ??= await _shiftService.generateShiftForWeek(weekStart);
          shifts.add(shift);
        } catch (e) {
          print('Error loading shift for week $weekStart: $e');
        }
      }

      if (mounted) {
        setState(() {
          _shifts = shifts;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading shifts: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los turnos: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _navigateWeek(bool forward) async {
    final direction = forward ? 1 : -1;
    final newDate = _currentDate.add(Duration(days: 7 * direction));
    
    setState(() {
      _currentDate = newDate;
      _isLoading = true;
    });

    await _loadShifts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Turnos Actuales',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.today,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            onPressed: () {
              setState(() => _currentDate = DateTime.now());
              _loadShifts();
            },
            tooltip: 'Ir a hoy',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                _buildWeekNavigator(),
                Expanded(
                  child: _shifts.isEmpty
                      ? _buildEmptyState()
                      : PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentPageIndex = index);
                          },
                          itemCount: _shifts.length,
                          itemBuilder: (context, index) {
                            final shift = _shifts[index];
                            final isCurrentWeek = index == 1; // Middle page is current week
                            
                            return SingleChildScrollView(
                              padding: const EdgeInsets.only(bottom: 100),
                              child: ShiftCard(
                                shift: shift,
                                isCurrentWeek: isCurrentWeek,
                                onTap: () => _showShiftDetails(shift),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildWeekNavigator() {
    final currentWeekStart = _getWeekStart(_currentDate);
    final formatter = DateFormat('MMMM yyyy', 'es');
    
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _navigateWeek(false),
            icon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).colorScheme.primary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatter.format(currentWeekStart).toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Semana del ${DateFormat('d', 'es').format(currentWeekStart)} al ${DateFormat('d', 'es').format(currentWeekStart.add(const Duration(days: 6)))}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _navigateWeek(true),
            icon: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.primary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay turnos disponibles',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No se pudieron generar los turnos para esta semana',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadShifts,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showShiftDetails(WeeklyShift shift) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShiftDetailsBottomSheet(shift: shift),
    );
  }
}

class ShiftDetailsBottomSheet extends StatelessWidget {
  final WeeklyShift shift;

  const ShiftDetailsBottomSheet({
    super.key,
    required this.shift,
  });

  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Detalles del Turno',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ShiftCard(
                shift: shift,
                isCurrentWeek: _isCurrentWeek(shift),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isCurrentWeek(WeeklyShift shift) {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekStart = DateTime(currentWeekStart.year, currentWeekStart.month, currentWeekStart.day);
    return shift.weekStart.isAtSameMomentAs(thisWeekStart);
  }
}