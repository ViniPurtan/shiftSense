# ShiftSense

ShiftSense is a modern Flutter application for managing shifts and vacations for a 9-person team with rotating schedules (T1: 7 people, T2: 2 people) and a weekly rotating Captain role in T2.

## 🚀 Features

---
## Provisional Page Hoasting

This is a provisional page hoasting for the ShiftSense application. 
It showcases the current state of the application's architecture and features.
[Shift Sense](https://app.dreamflow.com/project/40756c03-cb4b-4798-a8b9-fb0ba4eb6157/view)


- **Shift Management**: Rotating schedules for different teams
- **Vacation Planning**: Integrated vacation management system
- **Captain Role**: Weekly rotating captain assignments for T2
- **Team Organization**: Manage 9-person teams efficiently
- **Modern UI**: Built with Flutter for a smooth user experience


## 🛠️ Technical Stack

- **Frontend**: Flutter (Web)
- **State Management**: Provider pattern
- **Storage**: SharedPreferences for local data
- **Fonts**: Google Fonts integration
- **Architecture**: Clean architecture with separation of concerns

## 📦 Installation

1. Clone the repository:
```bash
git clone https://github.com/ViniPurtan/shiftSense.git
cd shiftSense
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run -d chrome
```

## 🚀 Building for Web

To build for web deployment:

```bash
flutter build web --release --base-href "/shiftSense/"
```

Or use the provided build script:
```bash
chmod +x build_check.sh
./build_check.sh
```

## 🌐 Live Demo

Visit the live application at: [Shift Sense](https://vinipurtan.github.io/shiftSense/)
Previous Live Demo at: [Shift Sense Demo App](https://0zadbuks1yk84tzmzny0.share.dreamflow.app)

## 📋 Project Structure

```
lib/
├── models/          # Data models
├── screens/         # UI screens
├── widgets/         # Reusable widgets
├── services/        # Business logic
└── main.dart        # App entry point
```

## 🔧 Configuration

The application uses environment-specific configurations. Check `pubspec.yaml` for dependencies and version constraints.

## 📄 License

This project is developed by Vinicius testing purposes only & for internal team management.

---

** Gestión de Turnos y Vacaciones para Equipos de Trabajo **
