# ShiftSense 📅

> **Gestión de Turnos y Vacaciones para Equipos de Trabajo**

Sistema inteligente para gestionar turnos rotatorios de 9 empleados con distribución T1 (7 personas) y T2 (2 personas), incluyendo rotación automática de capitán y gestión integrada de vacaciones.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue?logo=dart)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GitHub Pages](https://img.shields.io/badge/Deploy-GitHub%20Pages-brightgreen?logo=github)](https://vinipurtan.github.io/shiftSense/)

## 🌐 Demo en Vivo

**[🚀 Ver ShiftSense en acción](https://vinipurtan.github.io/shiftSense/)**

## ✨ Características Principales

### 📊 Gestión de Turnos
- **Turnos Rotativos Automáticos**: Sistema de rotación inteligente para 9 empleados
- **Distribución T1/T2**: 7 personas en T1, 2 personas en T2
- **Capitán Rotativo**: Rotación automática del rol de capitán en T2
- **Navegación por Semanas**: Visualización de semana anterior, actual y siguiente
- **Algoritmo de Equidad**: Distribución equitativa de roles y responsabilidades

### 🏖️ Gestión de Vacaciones
- **Solicitudes de Vacaciones**: Sistema completo de gestión de vacaciones
- **Verificación de Disponibilidad**: Validación automática de personal mínimo
- **Estados de Aprobación**: Pendiente, aprobado, rechazado
- **Tipos de Ausencia**: Vacaciones anuales, enfermedad, personal, emergencia

### 📈 Resumen y Estadísticas
- **Resumen Anual**: Vista completa del año con estadísticas
- **Distribución de Roles**: Análisis de participación en T1/T2
- **Estadísticas de Capitán**: Seguimiento de rotación de liderazgo
- **Métricas de Equipo**: Análisis de carga de trabajo y distribución

### 👥 Gestión de Equipo
- **Perfiles de Empleados**: Información completa de cada miembro
- **Avatars Personalizados**: Representación visual única
- **Estadísticas Individuales**: Seguimiento de participación y roles
- **Historial de Turnos**: Registro completo de asignaciones

## 🏗️ Arquitectura

```
lib/
├── models/              # Modelos de datos
│   └── employee.dart   # Employee, Vacation, WeeklyShift
├── services/           # Lógica de negocio
│   ├── data_service.dart      # Persistencia local
│   └── shift_service.dart     # Algoritmo de turnos
├── screens/            # Pantallas principales
│   ├── current_shift_screen.dart
│   ├── vacation_screen.dart
│   ├── annual_overview_screen.dart
│   └── employees_screen.dart
├── widgets/            # Componentes reutilizables
│   └── shift_card.dart
├── theme.dart          # Tema y estilos
└── main.dart          # Punto de entrada
```

## 🚀 Instalación y Desarrollo

### Prerrequisitos
- Flutter 3.0.0 o superior
- Dart 3.0.0 o superior

### Configuración Local

```bash
# Clonar el repositorio
git clone https://github.com/ViniPurtan/shiftSense.git
cd shiftSense

# Instalar dependencias
flutter pub get

# Ejecutar en modo desarrollo
flutter run -d chrome

# O para dispositivos móviles
flutter run
```

### Build para Producción

```bash
# Web
flutter build web --release

# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🛠️ Tecnologías Utilizadas

- **Framework**: Flutter 3.0+
- **Lenguaje**: Dart 3.0+
- **Persistencia**: SharedPreferences (local)
- **UI**: Material Design 3
- **Fuentes**: Google Fonts (Inter)
- **Internacionalización**: Español (es)
- **Deploy**: GitHub Pages + GitHub Actions

### Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0      # Tipografías modernas
  shared_preferences: ^2.0.0 # Almacenamiento local
  intl: ^0.19.0             # Internacionalización
  cupertino_icons: ^1.0.8   # Iconos iOS
```

## 📱 Compatibilidad

- ✅ **Web**: Chrome, Firefox, Safari, Edge
- ✅ **Android**: API 21+ (Android 5.0+)
- ✅ **iOS**: iOS 12.0+
- ✅ **Desktop**: Windows, macOS, Linux (Flutter Desktop)

## 🔄 Algoritmo de Turnos

El sistema utiliza un algoritmo de rotación equitativa que:

1. **Calcula semanas desde época**: Determina posición en ciclo de rotación
2. **Aplica offset rotativo**: Cada semana rota las asignaciones
3. **Verifica disponibilidad**: Excluye empleados en vacaciones
4. **Asigna roles automáticamente**: T1 (7), T2 (2), Capitán (rotativo)
5. **Actualiza estadísticas**: Mantiene contadores de participación

## 📊 Gestión de Datos

### Almacenamiento Local
- **Empleados**: Lista de 9 empleados con avatars y estadísticas
- **Turnos**: Historial completo de asignaciones semanales
- **Vacaciones**: Solicitudes y estados de aprobación
- **Configuración**: Preferencias de usuario y configuración

### Estructura de Datos

```dart
class Employee {
  final String id, name, position, avatar;
  final int totalWeeksAsT1, totalWeeksAsT2, totalWeeksAsCaptain;
}

class WeeklyShift {
  final DateTime weekStart;
  final List<String> t1Members, t2Members;
  final String captainId;
}

class Vacation {
  final String id, employeeId;
  final DateTime startDate, endDate, requestDate;
  final VacationType type;
  final VacationStatus status;
}
```

## 🎯 Características Técnicas

### Rendimiento
- ⚡ **Carga Rápida**: Optimizado para web y móvil
- 📱 **Responsive**: Adaptable a cualquier tamaño de pantalla
- 🔄 **Lazy Loading**: Carga eficiente de datos
- 💾 **Cache Local**: Funcionamiento offline

### UX/UI
- 🎨 **Material Design 3**: Diseño moderno y consistente
- 🌙 **Tema Oscuro/Claro**: Adaptación automática del sistema
- 📱 **Navegación Intuitiva**: TabBar con iconos descriptivos
- ⚡ **Animaciones Fluidas**: Transiciones suaves

### Seguridad
- 🔒 **Datos Locales**: Sin exposición de información sensible
- 🛡️ **Validación Robusta**: Verificación de integridad de datos
- 🔐 **Sin Autenticación Externa**: Operación completamente local

## 🤝 Contribuir

1. **Fork** el proyecto
2. **Crea** una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. **Abre** un Pull Request

### Guías de Contribución
- Seguir las convenciones de Dart/Flutter
- Incluir tests para nuevas funcionalidades
- Documentar cambios en el código
- Mantener compatibilidad con versiones existentes

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

## 👨‍💻 Autor

**Vini Purtan**
- GitHub: [@ViniPurtan](https://github.com/ViniPurtan)

## 🔮 Roadmap

### v1.1.0 (Próximamente)
- [ ] Notificaciones push para cambios de turno
- [ ] Exportación de datos a Excel/PDF
- [ ] Calendario visual mejorado
- [ ] Sistema de comentarios en turnos

### v1.2.0 (Futuro)
- [ ] Sincronización en la nube (Firebase)
- [ ] Aplicación móvil nativa
- [ ] Sistema de reportes avanzado
- [ ] Integración con calendarios externos

### v2.0.0 (Visión)
- [ ] Multi-empresa
- [ ] Roles y permisos avanzados
- [ ] Dashboard administrativo
- [ ] API REST completa

## 📞 Soporte

¿Tienes preguntas o necesitas ayuda?

- 📧 **Email**: [Crear Issue](https://github.com/ViniPurtan/shiftSense/issues)
- 🐛 **Bugs**: [Reportar Bug](https://github.com/ViniPurtan/shiftSense/issues/new?template=bug_report.md)
- 💡 **Feature Request**: [Solicitar Feature](https://github.com/ViniPurtan/shiftSense/issues/new?template=feature_request.md)

---

<div align="center">

**[⬆ Volver al inicio](#shiftsense-)**

Made with ❤️ using Flutter

</div>