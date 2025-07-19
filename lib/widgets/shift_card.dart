import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shiftsense/models/employee.dart';
import 'package:shiftsense/services/data_service.dart';

class ShiftCard extends StatelessWidget {
  final WeeklyShift shift;
  final bool isCurrentWeek;
  final VoidCallback? onTap;

  const ShiftCard({
    super.key,
    required this.shift,
    this.isCurrentWeek = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isCurrentWeek
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
                  ],
                )
              : null,
          color: isCurrentWeek ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: isCurrentWeek
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getWeekText(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isCurrentWeek
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDateRange(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCurrentWeek
                              ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7)
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  if (isCurrentWeek)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ACTUAL',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: _buildShiftGroup(
                      context,
                      'TURNO T1',
                      '7 personas',
                      shift.t1Members,
                      Theme.of(context).colorScheme.secondary,
                      Icons.groups_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _buildShiftGroup(
                      context,
                      'TURNO T2',
                      '2 personas',
                      shift.t2Members,
                      Theme.of(context).colorScheme.tertiary,
                      Icons.star_outline,
                      captainId: shift.captainId,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getWeekText() {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekStart = DateTime(currentWeekStart.year, currentWeekStart.month, currentWeekStart.day);
    
    if (shift.weekStart.isAtSameMomentAs(thisWeekStart)) {
      return 'Esta semana';
    }
    
    final difference = shift.weekStart.difference(thisWeekStart).inDays;
    if (difference == 7) {
      return 'Próxima semana';
    } else if (difference == -7) {
      return 'Semana pasada';
    } else if (difference > 0) {
      return 'En ${difference ~/ 7} semanas';
    } else {
      return 'Hace ${(-difference) ~/ 7} semanas';
    }
  }

  String _getDateRange() {
    final formatter = DateFormat('d MMM', 'es');
    final start = formatter.format(shift.weekStart);
    final end = formatter.format(shift.weekEnd);
    return '$start - $end';
  }

  Widget _buildShiftGroup(
    BuildContext context,
    String title,
    String subtitle,
    List<String> memberIds,
    Color accentColor,
    IconData icon, {
    String? captainId,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Employee>>(
            future: _getEmployeesFromIds(memberIds),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              final employees = snapshot.data!;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: employees.map((employee) {
                  final isCaptain = captainId == employee.id;
                  return _buildEmployeeChip(
                    context,
                    employee,
                    isCaptain,
                    accentColor,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeChip(
    BuildContext context,
    Employee employee,
    bool isCaptain,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCaptain
            ? accentColor.withOpacity(0.3)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isCaptain
            ? Border.all(color: accentColor, width: 1.5)
            : Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            employee.avatar,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              employee.name.split(' ').first,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isCaptain
                    ? accentColor
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isCaptain ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isCaptain) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.military_tech,
              size: 12,
              color: accentColor,
            ),
          ],
        ],
      ),
    );
  }

  Future<List<Employee>> _getEmployeesFromIds(List<String> ids) async {
    final dataService = await DataService.getInstance();
    final allEmployees = await dataService.getEmployees();
    return allEmployees.where((e) => ids.contains(e.id)).toList();
  }
}