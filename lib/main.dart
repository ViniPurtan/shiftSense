import 'package:flutter/material.dart';
import 'package:shiftsense/theme.dart';
import 'package:shiftsense/screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShiftSense - Gestión de Turnos',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
      // Configuración para web
      onGenerateRoute: (settings) {
        // Maneja todas las rutas desconocidas dirigiéndolas a la página principal
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
          settings: settings,
        );
      },
      onUnknownRoute: (settings) {
        // Fallback para rutas no encontradas
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
        );
      },
    );
  }
}
