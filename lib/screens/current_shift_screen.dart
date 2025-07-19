import 'package:flutter/material.dart';
import 'package:shiftsense/widgets/demo_screen.dart';
import 'package:shiftsense/services/supabase_service.dart';

class CurrentShiftScreen extends StatefulWidget {
  const CurrentShiftScreen({super.key});

  @override
  State<CurrentShiftScreen> createState() => _CurrentShiftScreenState();
}

class _CurrentShiftScreenState extends State<CurrentShiftScreen> {
  bool _isLoading = true;
  bool _supabaseConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      final supabaseService = SupabaseService();
      _supabaseConnected = await supabaseService.isConnected();
    } catch (e) {
      _supabaseConnected = false;
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return DemoScreen(
      title: 'Gestión de Turnos',
      icon: Icons.schedule,
      description: 'Sistema de gestión de turnos rotatorios para equipos de trabajo. Aquí podrás ver y gestionar los turnos actuales del equipo.',
    );
  }
}
