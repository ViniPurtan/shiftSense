# 🚀 Configuración Inicial de ShiftSense en FlutterFlow

Esta guía te llevará paso a paso para configurar el proyecto ShiftSense desde cero en FlutterFlow.

## 📋 Prerequisitos

### Cuentas Necesarias
- ✅ **FlutterFlow Pro/Team** (para acceso a custom actions y APIs)
- ✅ **Firebase Project** con Blaze plan (para Cloud Functions)
- ✅ **Google Cloud Console** access
- ✅ **Apple Developer** (para iOS deployment)
- ✅ **Google Play Console** (para Android deployment)

### Herramientas de Desarrollo
- ✅ **Android Studio** con SDK actualizado
- ✅ **Xcode** (para desarrollo iOS)
- ✅ **Git** para control de versiones
- ✅ **Visual Studio Code** (opcional, para custom code)

## 🏗️ Paso 1: Crear Proyecto en FlutterFlow

### 1.1 Nuevo Proyecto
1. Ve a [FlutterFlow](https://flutterflow.io)
2. Click en **"Create New Project"**
3. Selecciona **"Start from Scratch"**
4. Configura:
   - **Project Name:** `ShiftSense`
   - **Bundle ID:** `com.yourcompany.shiftsense`
   - **Project Type:** `Mobile App`
   - **Theme:** `Material 3`

### 1.2 Configuración Inicial
```yaml
# Configuración básica del proyecto
Project Settings:
  - App Name: ShiftSense
  - Description: "Gestión automática de turnos con sensores"
  - Version: 1.0.0
  - Min SDK: Android 21+ (API Level 21)
  - iOS Deployment: 12.0+
  - Web Support: Enabled
```

## 🔥 Paso 2: Configurar Firebase

### 2.1 Crear Proyecto Firebase
1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Click **"Crear proyecto"**
3. Nombre: `shiftsense-app`
4. Habilita Google Analytics
5. Selecciona región (recomendado: us-central1)

### 2.2 Configurar Servicios Firebase

#### Authentication
```bash
# Habilitar proveedores de autenticación
1. Email/Password ✅
2. Google Sign-In ✅
3. Anonymous (para testing) ✅
```

#### Firestore Database
```javascript
// Reglas de seguridad inicial
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios solo pueden leer/escribir sus propios datos
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Shifts require authentication
    match /shifts/{shiftId} {
      allow read, write: if request.auth != null;
    }
    
    // Empresas - solo admins
    match /companies/{companyId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 📱 Paso 3: Configurar FlutterFlow con Firebase

### 3.1 Conectar Firebase
1. En FlutterFlow, ve a **Settings > Firebase**
2. Click **"Connect to Firebase"**
3. Selecciona tu proyecto `shiftsense-app`
4. Configura para todas las plataformas:
   - ✅ Android
   - ✅ iOS  
   - ✅ Web

### 3.2 Configurar Authentication
```dart
// En FlutterFlow Authentication Settings
Settings:
  - Enable Authentication: ✅
  - Default Page: /login
  - Entry Page: /dashboard
  - Providers:
    * Email/Password ✅
    * Google Sign-In ✅
```

## 📦 Paso 4: Dependencias y Packages

### 4.1 Packages Nativos de FlutterFlow
```yaml
# En FlutterFlow Package Dependencies
Required Packages:
  - geolocator: ^10.1.0
  - permission_handler: ^11.3.1
  - flutter_local_notifications: ^16.3.2
  - connectivity_plus: ^5.0.2
  - wifi_info_flutter: ^2.0.2
  - flutter_bluetooth_serial: ^0.4.0
```

### 4.2 Custom Actions Required
```dart
// Custom Actions que necesitaremos crear
Custom Actions List:
  1. requestLocationPermissions()
  2. startLocationTracking()
  3. checkGeofenceEntry()
  4. scanWifiNetworks()
  5. detectBluetoothBeacons()
  6. calculateWorkHours()
  7. sendPushNotification()
  8. exportTimeReport()
```

### 4.3 Configurar Permisos

#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

#### iOS (ios/Runner/Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>ShiftSense necesita acceso a ubicación para detectar tu llegada al trabajo</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>ShiftSense necesita acceso continuo a ubicación para tracking automático de turnos</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>ShiftSense usa Bluetooth para detectar beacons en el lugar de trabajo</string>
```

## 🎨 Paso 5: Configurar Tema y Recursos

### 5.1 Material 3 Theme
```dart
// En FlutterFlow Theme Settings
Material 3 Configuration:
  Primary Color: #1976D2 (Blue)
  Secondary Color: #FF9800 (Orange)
  Success Color: #4CAF50 (Green)
  Error Color: #F44336 (Red)
  Warning Color: #FF9800 (Amber)
  Info Color: #2196F3 (Light Blue)
  
  Dark Mode: Enabled
  Dynamic Colors: Enabled (Android 12+)
```

## ⚙️ Paso 6: Configuración de Variables Globales

### 6.1 App State Variables
```dart
// Configurar en FlutterFlow App State
Global Variables:
  - currentUser (DocumentReference?)
  - isOnShift (bool) = false
  - currentLocation (LatLng?)
  - workplaceLocation (LatLng?)
  - shiftStartTime (DateTime?)
  - lastLocationUpdate (DateTime?)
  - isLocationPermissionGranted (bool) = false
  - selectedCompany (DocumentReference?)
  - userRole (String) = 'employee'
```

### 6.2 Constants
```dart
// Configurar constantes en Custom Code
Constants:
  - GEOFENCE_RADIUS = 100.0 // metros
  - LOCATION_UPDATE_INTERVAL = 30 // segundos
  - MIN_SHIFT_DURATION = 15 // minutos
  - MAX_SHIFT_DURATION = 12 // horas
  - WIFI_SCAN_INTERVAL = 60 // segundos
  - BLUETOOTH_SCAN_INTERVAL = 30 // segundos
```

## ✅ Verificación de Setup

### Checklist Final
- [ ] ✅ Proyecto FlutterFlow creado y configurado
- [ ] ✅ Firebase conectado y configurado
- [ ] ✅ Authentication habilitado
- [ ] ✅ Firestore configurado con reglas
- [ ] ✅ Packages/dependencias añadidas
- [ ] ✅ Permisos configurados (Android/iOS)
- [ ] ✅ Tema Material 3 aplicado
- [ ] ✅ Variables globales definidas
- [ ] ✅ Constantes configuradas
- [ ] ✅ Testing environment preparado

### Probar Setup
```dart
// Test básico - crear en FlutterFlow
Test Actions:
1. Build app en modo debug
2. Verificar que carga sin errores
3. Test authentication flow
4. Verificar conexión a Firestore
5. Test location permissions
```

## 🚀 Próximos Pasos

Con el setup completado, estás listo para:

1. **[🗃️ Modelado de Datos](02-data-modeling.md)** - Crear estructura de datos
2. **[🎨 Componentes UI](03-ui-components.md)** - Diseñar interfaces
3. **[⚙️ Lógica de Negocio](04-business-logic.md)** - Implementar funcionalidades

---

**🎉 ¡Setup completado!** Tu proyecto ShiftSense está listo para el desarrollo.

**➡️ Siguiente: [Modelado de Datos](02-data-modeling.md)**
