import 'package:flutter/material.dart';
import 'package:shiftsense/widgets/demo_screen.dart';

class AnnualOverviewScreen extends StatelessWidget {
  const AnnualOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoScreen(
      title: 'Resumen Anual',
      icon: Icons.analytics,
      description: 'Vista general del año con estadísticas de turnos, vacaciones y rendimiento del equipo.',
    );
  }
}