# 📅 ShiftSense - Implementación en FlutterFlow

## 🎯 Introducción

**ShiftSense** es un sistema inteligente de gestión de turnos y vacaciones diseñado específicamente para equipos de trabajo con rotaciones complejas. Este proyecto Flutter ha sido desarrollado para gestionar turnos rotatorios de 9 empleados con distribución T1 (7 personas) y T2 (2 personas), incluyendo rotación automática de capitán.

### 🌐 Demo en Vivo
- **[🚀 Ver ShiftSense](https://vinipurtan.github.io/shiftSense/)**
- **[📂 Repositorio GitHub](https://github.com/ViniPurtan/shiftSense)**

---

## ✨ Características Principales

### 📊 Gestión de Turnos Avanzada
- **Turnos Rotativos Automáticos**: Sistema de rotación inteligente para 9 empleados
- **Distribución T1/T2**: 7 personas en turno T1, 2 personas en turno T2
- **Capitán Rotativo**: Rotación automática del rol de capitán en T2
- **Navegación Temporal**: Visualización de semana anterior, actual y siguiente
- **Algoritmo de Equidad**: Distribución equitativa de roles y responsabilidades

### 🏖️ Sistema de Vacaciones Integral
- **Solicitudes Digitales**: Sistema completo de gestión de vacaciones
- **Validación Automática**: Verificación de personal mínimo disponible
- **Estados de Aprobación**: Flujo completo (Pendiente → Aprobado/Rechazado)
- **Tipos de Ausencia**: Vacaciones anuales, enfermedad, personal, emergencia

### 📈 Analytics y Reportes
- **Resumen Anual**: Vista completa del año con estadísticas detalladas
- **Distribución de Roles**: Análisis de participación en T1/T2 por empleado
- **Estadísticas de Liderazgo**: Seguimiento de rotación de capitán
- **Métricas de Equidad**: Análisis de carga de trabajo y distribución justa

### 👥 Gestión de Equipo Completa
- **Perfiles Detallados**: Información completa de cada miembro del equipo
- **Avatars Personalizados**: Representación visual única para cada empleado
- **Estadísticas Individuales**: Seguimiento de participación y roles históricos
- **Historial Completo**: Registro detallado de todas las asignaciones

---

## 🏗️ Arquitectura del Sistema

### Estructura de Directorios
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

### Tecnologías Clave
- **Framework**: Flutter 3.0+
- **Lenguaje**: Dart 3.0+
- **Persistencia**: SharedPreferences (almacenamiento local)
- **UI**: Material Design 3
- **Fuentes**: Google Fonts (Inter)
- **Internacionalización**: Español (es)

---

## 🎨 Interfaz de Usuario

### Pantallas Principales

#### 1. Vista de Turno Actual
- Visualización de la semana actual con empleados asignados
- Navegación entre semanas (anterior/siguiente)
- Identificación clara del capitán con badge especial
- Diferenciación visual entre T1 y T2

#### 2. Gestión de Vacaciones
- Calendario interactivo para solicitar vacaciones
- Lista de vacaciones pendientes y aprobadas
- Formulario de solicitud con tipos de ausencia
- Validación de conflictos automática

#### 3. Resumen Anual
- Vista de año completo en formato grid
- Estadísticas de participación por empleado
- Métricas de equidad en la distribución
- Gráficos de tendencias y análisis

#### 4. Perfiles de Empleados
- Lista completa del equipo con fotos
- Estadísticas individuales detalladas
- Historial de turnos y vacaciones
- Información de contacto y posición

---

## 🔄 Algoritmo de Rotación

### Funcionamiento del Sistema
El corazón de ShiftSense es su algoritmo de rotación equitativa:

1. **Cálculo Temporal**: Determina semanas desde época de referencia
2. **Offset Rotativo**: Cada semana aplica rotación automática
3. **Verificación de Disponibilidad**: Excluye empleados en vacaciones
4. **Asignación Inteligente**: Distribuye T1 (7), T2 (2), Capitán (rotativo)
5. **Actualización de Métricas**: Mantiene estadísticas de participación

### Algoritmo de Equidad
```dart
// Ejemplo simplificado del algoritmo
int calculateWeekOffset() {
  final now = DateTime.now();
  final epoch = DateTime(2024, 1, 1);
  final difference = now.difference(epoch).inDays;
  return (difference / 7).floor();
}

List<Employee> assignShifts(int weekOffset) {
  // Rotación basada en offset semanal
  // Excluye empleados en vacaciones
  // Asigna roles de forma equitativa
}
```

---

## 📱 Compatibilidad Multiplataforma

### Plataformas Soportadas
- ✅ **Web**: Chrome, Firefox, Safari, Edge
- ✅ **Android**: API 21+ (Android 5.0+)
- ✅ **iOS**: iOS 12.0+
- ✅ **Desktop**: Windows, macOS, Linux

### Características Responsive
- Adaptación automática a diferentes tamaños de pantalla
- Optimización para tablets y dispositivos móviles
- Navegación táctil intuitiva
- Rendimiento optimizado en todas las plataformas

---

## 🔧 Dependencias del Proyecto

### Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0      # Tipografías modernas
  shared_preferences: ^2.0.0 # Almacenamiento local
  intl: ^0.19.0             # Internacionalización
  cupertino_icons: ^1.0.8   # Iconos iOS
```

### Desarrollo
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0    # Análisis de código
```

---

## 🎯 Casos de Uso Principales

### Para Administradores
- Visualización rápida de turnos actuales
- Aprobación/rechazo de solicitudes de vacaciones
- Análisis de estadísticas del equipo
- Planificación a largo plazo

### Para Empleados
- Consulta de turnos asignados
- Solicitud de vacaciones
- Verificación de historial personal
- Visualización de calendario anual

### Para Gerencia
- Reportes de equidad en la distribución
- Análisis de productividad
- Planificación de recursos humanos
- Métricas de satisfacción del equipo

---

## 🚀 Beneficios de la Implementación

### Operacionales
- **Automatización Completa**: Elimina asignación manual de turnos
- **Reducción de Errores**: Algoritmo garantiza distribución justa
- **Ahorro de Tiempo**: Gestión automática de rotaciones
- **Transparencia**: Todos ven la misma información actualizada

### Técnicos
- **Sin Dependencias Externas**: Funciona completamente offline
- **Rendimiento Óptimo**: Carga rápida y operación fluida
- **Mantenimiento Mínimo**: Arquitectura simple y robusta
- **Escalabilidad**: Fácil adaptación a equipos de diferentes tamaños

### Organizacionales
- **Mejora la Moral**: Distribución justa visible para todos
- **Reduce Conflictos**: Eliminación de favoritismos percibidos
- **Facilita Planificación**: Vista clara de disponibilidad futura
- **Documenta Historial**: Registro completo para auditorías

---

## 📋 Próximos Pasos

Este documento forma parte de una serie completa de implementación en FlutterFlow:

1. **[Configuración Inicial](setup)** - Preparación del entorno FlutterFlow
2. **[Modelado de Datos](data-modeling)** - Estructuras y esquemas
3. **[Interfaces de Usuario](ui-components)** - Componentes y pantallas
4. **[Lógica de Negocio](business-logic)** - Servicios y algoritmos
5. **[Integración y Testing](testing)** - Pruebas y validación
6. **[Despliegue](deployment)** - Publicación y distribución

---

**¡Comencemos a implementar ShiftSense en FlutterFlow!** 🚀
