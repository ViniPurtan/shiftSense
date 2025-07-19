import 'package:flutter/material.dart';
import 'package:shiftsense/widgets/demo_screen.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoScreen(
      title: 'Gestión de Equipo',
      icon: Icons.people,
      description: 'Administración del equipo de trabajo. Aquí podrás gestionar la información y estadísticas de cada empleado.',
    );
  }
}