import 'package:flutter/material.dart';
import 'package:shiftsense/widgets/demo_screen.dart';

class VacationScreen extends StatelessWidget {
  const VacationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoScreen(
      title: 'Gestión de Vacaciones',
      icon: Icons.beach_access,
      description: 'Sistema de gestión de vacaciones del equipo. Aquí podrás planificar y aprobar las vacaciones del personal.',
    );
  }
}