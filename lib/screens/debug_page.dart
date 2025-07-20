import 'package:flutter/material.dart';
import 'package:shiftsense/services/supabase_shift_service.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final _supabaseService = SupabaseShiftService();
  Map<String, dynamic>? _debugInfo;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => _loading = true);
    try {
      final info = await _supabaseService.getDebugInfo();
      setState(() => _debugInfo = info);
    } catch (e) {
      setState(() => _debugInfo = {'error': e.toString()});
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Debug Supabase'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard('🔌 Test Conexión', _debugInfo?['connection_test']),
                  const SizedBox(height: 16),
                  _buildInfoCard('📊 Conteos', _debugInfo?['simple_counts']),
                  const SizedBox(height: 16),
                  _buildInfoCard('🏠 Dashboard', _debugInfo?['dashboard']),
                  const SizedBox(height: 16),
                  _buildInfoCard('📅 Turnos Hoy', _debugInfo?['turnos_hoy']),
                  const SizedBox(height: 16),
                  if (_debugInfo?['error'] != null)
                    _buildErrorCard(_debugInfo!['error']),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, dynamic data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                data?.toString() ?? 'Sin datos',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  '❌ Error',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.red[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _testIndividualFunctions,
            icon: const Icon(Icons.play_arrow),
            label: const Text('🧪 Probar Funciones Individuales'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showRawData,
            icon: const Icon(Icons.code),
            label: const Text('📄 Ver Datos Crudos'),
          ),
        ),
      ],
    );
  }

  Future<void> _testIndividualFunctions() async {
    setState(() => _loading = true);
    
    final results = <String, dynamic>{};
    
    try {
      results['departamentos'] = await _supabaseService.getDepartamentos();
      results['tipos_turno'] = await _supabaseService.getTiposTurno();
      results['turnos_recientes'] = await _supabaseService.getTurnosRecientes();
      
      setState(() => _debugInfo = {..._debugInfo ?? {}, 'individual_tests': results});
    } catch (e) {
      setState(() => _debugInfo = {..._debugInfo ?? {}, 'test_error': e.toString()});
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showRawData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📄 Datos Crudos'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              _debugInfo.toString(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
