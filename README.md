# 📅 ShiftSense - Documentación para FlutterFlow

**Sistema inteligente de gestión de turnos y vacaciones con guía completa de implementación en FlutterFlow**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter)](https://flutter.dev/)
[![FlutterFlow](https://img.shields.io/badge/FlutterFlow-Compatible-purple?logo=flutter)](https://flutterflow.io/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue?logo=dart)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Documentation](https://img.shields.io/badge/Documentation-GitBook-orange)](https://app.gitbook.com/o/-LEJnsuiDJajz8FoVsPk/s/abrhwtCLK2InTZBm5pvT/)

## 🎆 ¿Qué es ShiftSense?

**ShiftSense** es un sistema inteligente para la gestión de turnos rotatorios y vacaciones, diseñado específicamente para equipos de 9 empleados con distribución T1 (7 personas) y T2 (2 personas), incluyendo rotación automática de capitán.

### 🚀 Demo en Vivo
**[🌐 Ver ShiftSense en Acción](https://vinipurtan.github.io/shiftSense/)**

---

## 📚 Documentación Completa para FlutterFlow

Este repositorio contiene una **guía completa paso a paso** para implementar ShiftSense en FlutterFlow:

### 🛠️ Guías de Implementación

1. **[🚀 Configuración Inicial](docs/01-setup.md)**
   - Setup de FlutterFlow y dependencias
   - Configuración de tema y navegación
   - Variables de estado globales

2. **[🗃️ Modelado de Datos](docs/02-data-modeling.md)**
   - Estructuras de datos principales
   - Custom Data Types en FlutterFlow
   - Persistencia con SharedPreferences

3. **[🎨 Componentes UI](docs/03-ui-components.md)**
   - Interfaces con Material Design 3
   - Componentes reutilizables
   - Responsive design

4. **[⚙️ Lógica de Negocio](docs/04-business-logic.md)**
   - Algoritmo de rotación inteligente
   - Servicios de gestión de vacaciones
   - Estadísticas y métricas

5. **[🧪 Testing y Validación](docs/05-testing.md)**
   - Estrategia de testing integral
   - Unit, Widget e Integration tests
   - Performance testing

6. **[🚀 Despliegue](docs/06-deployment.md)**
   - Deployment multiplataforma
   - CI/CD con GitHub Actions
   - Publicación en stores

### 📖 Navegación Rápida
- **[📋 Tabla de Contenidos](docs/SUMMARY.md)** - Índice completo
- **[📚 GitBook](https://app.gitbook.com/o/-LEJnsuiDJajz8FoVsPk/s/abrhwtCLK2InTZBm5pvT/)** - Documentación interactiva

---

## ✨ Características Principales

### 📊 Gestión de Turnos Inteligente
- 🔄 **Rotación Automática**: Algoritmo equitativo para 9 empleados
- 👥 **Distribución T1/T2**: 7 personas en T1, 2 en T2
- ⭐ **Capitán Rotativo**: Liderazgo rotativo en T2
- 📅 **Navegación Temporal**: Vista de semanas anterior/actual/siguiente

### 🏖️ Sistema de Vacaciones
- 📝 **Solicitudes Digitales**: Gestión completa de vacaciones
- ✅ **Validación Automática**: Verificación de personal mínimo
- 🔄 **Estados**: Pendiente → Aprobado/Rechazado
- 🚨 **Detección de Conflictos**: Prevención automática

### 📈 Analytics y Reportes
- 📊 **Estadísticas Detalladas**: Participación por empleado
- ⚖️ **Métricas de Equidad**: Distribución justa garantizada
- 📅 **Resumen Anual**: Vista completa del año
- 📈 **Tendencias**: Análisis de patrones

### 👥 Gestión de Equipo
- 👤 **Perfiles Completos**: Información detallada
- 🖼️ **Avatars Personalizados**: Representación visual
- 📊 **Historial Individual**: Seguimiento de participación
- 📋 **Estadísticas**: Métricas de cada empleado

---

## 🏗️ Arquitectura Técnica

### 🎨 Stack Tecnológico
- **Framework**: Flutter 3.0+
- **Plataforma**: FlutterFlow
- **Lenguaje**: Dart 3.0+
- **UI**: Material Design 3
- **Persistencia**: SharedPreferences
- **Fuentes**: Google Fonts (Inter)

### 📱 Plataformas Soportadas
- ✅ **Web**: Progressive Web App
- ✅ **Android**: APK y App Bundle
- ✅ **iOS**: App Store ready
- ✅ **Desktop**: Windows, macOS, Linux

### 🔧 Dependencias Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0      # Tipografías
  shared_preferences: ^2.0.0 # Almacenamiento
  intl: ^0.19.0             # Internacionalización
  cupertino_icons: ^1.0.8   # Iconos iOS
```

---

## 🚀 Inicio Rápido

### 📋 Prerrequisitos
- **Cuenta FlutterFlow** (Plan Pro recomendado)
- **Flutter SDK** 3.0+
- **Editor** (VS Code o Android Studio)
- **Git** configurado

### ⚡ Setup Básico
```bash
# 1. Clonar repositorio
git clone https://github.com/ViniPurtan/shiftSense.git
cd shiftSense

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar tests
flutter test

# 4. Ejecutar aplicación
flutter run -d chrome
```

### 📚 Seguir Documentación
1. Comienza con **[Configuración Inicial](docs/01-setup.md)**
2. Sigue la secuencia numérica de documentos
3. Consulta **[GitBook](https://app.gitbook.com/o/-LEJnsuiDJajz8FoVsPk/s/abrhwtCLK2InTZBm5pvT/)** para navegación interactiva

---

## 🎯 Casos de Uso

### 👨‍💼 Para Administradores
- 📊 Dashboard ejecutivo completo
- ⚙️ Gestión de configuraciones
- 📈 Reportes avanzados
- ✅ Aprobación de vacaciones

### 👤 Para Empleados
- 📅 Consulta de turnos asignados
- 🏖️ Solicitud de vacaciones
- 📊 Historial personal
- 🗓️ Calendario anual

### 🏢 Para Recursos Humanos
- ⚖️ Métricas de equidad
- 📊 Análisis de carga
- 📈 Tendencias de ausencias
- 📄 Reportes de cumplimiento

---

## 🎉 Beneficios de Implementación

### 💼 Operacionales
- ⏱️ **Ahorro de Tiempo**: Automatización completa
- ⚖️ **Equidad Garantizada**: Algoritmo matemático
- 📉 **Reducción de Errores**: Eliminación manual
- 🔍 **Transparencia**: Visibilidad total

### 💻 Técnicos
- 📱 **Multiplataforma**: Una solución para todo
- ⚡ **Alto Rendimiento**: Optimizado
- 💾 **Sin Dependencias**: Funciona offline
- 🔧 **Fácil Mantenimiento**: Arquitectura limpia

### 👥 Organizacionales
- 🚀 **Mejora de Moral**: Distribución justa visible
- 🔥 **Reducción de Conflictos**: Sin favoritismos
- 📈 **Mejor Planificación**: Vista clara
- 📁 **Documentación**: Historial completo

---

## 🛣️ Roadmap

### ✅ Fase 1: Completada
- Algoritmo de rotación
- Gestión de vacaciones
- Interfaz completa
- Testing integral
- Deployment multiplataforma

### 🔄 Fase 2: En Progreso
- Notificaciones push
- Dashboard avanzado
- Exportación reportes
- Integraciones externas

### 🌟 Fase 3: Futuro
- Sincronización cloud
- Multi-organización
- Inteligencia artificial
- App nativa optimizada

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Consulta nuestra **[Guía de Contribución](CONTRIBUTING.md)** para comenzar.

### 🎯 Formas de Contribuir
- 🐛 Reportar bugs
- ✨ Solicitar features
- 📄 Mejorar documentación
- 🧪 Agregar tests
- 🎨 Mejorar UI/UX

---

## 📞 Soporte y Comunidad

### 🔗 Enlaces Útiles
- **[🌐 Demo](https://vinipurtan.github.io/shiftSense/)** - Aplicación funcionando
- **[📚 GitBook](https://app.gitbook.com/o/-LEJnsuiDJajz8FoVsPk/s/abrhwtCLK2InTZBm5pvT/)** - Documentación interactiva
- **[🐛 Issues](https://github.com/ViniPurtan/shiftSense/issues)** - Reportar problemas
- **[💬 Discussions](https://github.com/ViniPurtan/shiftSense/discussions)** - Comunidad

### 📧 Contacto
- **GitHub**: [@ViniPurtan](https://github.com/ViniPurtan)
- **Email**: vini@nayarsystems.com

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

---

<div align="center">

**¡Transforma la gestión de turnos de tu equipo hoy!** 🚀

**[📚 Comenzar Implementación](docs/01-setup.md)** | **[🌐 Ver Demo](https://vinipurtan.github.io/shiftSense/)**

Hecho con ❤️ usando Flutter + FlutterFlow

</div>