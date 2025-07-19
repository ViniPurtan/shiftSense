import 'package:flutter/material.dart';
import 'package:shiftsense/services/supabase_shift_service.dart';

class CurrentShiftScreen extends StatefulWidget {
  const CurrentShiftScreen({super.key});

  @override
  State<CurrentShiftScreen> createState() => _CurrentShiftScreenState();
}

class _CurrentShiftScreenState extends State<CurrentShiftScreen> {
  final _supabaseService = SupabaseShiftService();
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  List<Map<String, dynamic>> _turnosHoy = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Cargar datos del dashboard y turnos
      final dashboardFuture = _supabaseService.getDashboard();
      final turnosFuture = _supabaseService.getTurnosHoy();
      
      final results = await Future.wait([dashboardFuture, turnosFuture]);
      
      if (mounted) {
        setState(() {
          _dashboardData = results[0] as Map<String, dynamic>;
          _turnosHoy = results[1] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando turnos...'),
          ],
        ),
      );
    }

    if (_error != null) {
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
              'Error cargando datos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📅 Encabezado con fecha
            _buildDateHeader(),
            const SizedBox(height: 20),
            
            // 📊 Estadísticas rápidas
            _buildStatsRow(),
            const SizedBox(height: 24),
            
            // 🕐 Turnos de hoy
            _buildTurnosSection(),
            const SizedBox(height: 24),
            
            // 🔍 Debug info (temporal)
            _buildDebugInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    final weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                   'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Turnos Actuales',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]} 2025',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
          Text(
            'Semana del 14 al 20',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = _dashboardData?['estadisticas'] ?? {};
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Turnos Totales',
            '${stats['total_turnos'] ?? 0}',
            Icons.event,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Turnos Activos',
            '${stats['turnos_activos'] ?? 0}',
            Icons.schedule,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Usuarios',
            '${stats['total_usuarios'] ?? 0}',
            Icons.people,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTurnosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Esta semana',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
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
        const SizedBox(height: 16),
        
        if (_turnosHoy.isEmpty)
          _buildEmptyTurnos()
        else
          _buildTurnosList(),
      ],
    );
  }

  Widget _buildEmptyTurnos() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay turnos programados para hoy',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Los turnos aparecerán aquí cuando estén disponibles',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTurnosList() {
    // Crear turnos simulados que coincidan con tu diseño
    final turnosEjemplo = [
      {
        'nombre': 'TURNO T1',
        'personas': 7,
        'miembros': ['Ana', 'Carlos', 'María', 'José', 'Elena', 'Roberto', 'Carmen'],
        'color': Colors.blue[100],
        'textColor': Colors.blue[900],
      },
      {
        'nombre': 'TURNO T2', 
        'personas': 2,
        'miembros': ['David'],
        'color': Colors.purple[100],
        'textColor': Colors.purple[900],
        'isCaptain': true,
      },
    ];

    return Column(
      children: turnosEjemplo.map((turno) => _buildTurnoCard(turno)).toList(),
    );
  }

  Widget _buildTurnoCard(Map<String, dynamic> turno) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: turno['color'],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (turno['textColor'] as Color).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups,
                color: turno['textColor'],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                turno['nombre'],
                style: TextStyle(
                  color: turno['textColor'],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (turno['isCaptain'] == true) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.star,
                  color: turno['textColor'],
                  size: 16,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${turno['personas']} personas',
            style: TextStyle(
              color: (turno['textColor'] as Color).withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (turno['miembros'] as List<String>).map((nombre) => 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('👤', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      nombre,
                      style: TextStyle(
                        color: turno['textColor'],
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugInfo() {
    return ExpansionTile(
      title: const Text('🔍 Debug Info'),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard Data:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_dashboardData.toString()),
              const SizedBox(height: 8),
              Text('Turnos Hoy:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_turnosHoy.toString()),
            ],
          ),
        ),
      ],
    );
  }
}
