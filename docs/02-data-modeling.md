# 🗃️ Modelado de Datos - ShiftSense

Este documento define la estructura completa de datos para ShiftSense en Firestore, incluyendo colecciones, campos, índices y relaciones.

## 📊 Visión General de la Arquitectura de Datos

### Estructura de Colecciones
```
Firestore Database
├── 👥 companies/          # Información de empresas
├── 👤 users/              # Perfiles de usuarios
├── ⏰ shifts/             # Registros de turnos
├── 📍 locations/          # Ubicaciones de trabajo
├── 📢 notifications/      # Sistema de notificaciones
├── 📋 teams/              # Equipos de trabajo
├── 📊 reports/            # Reportes generados
└── ⚙️ settings/           # Configuraciones del sistema
```

## 🏢 Colección: Companies

### Estructura del Documento
```javascript
// /companies/{companyId}
{
  // Información básica
  "name": "string",                    // "Acme Corp"
  "description": "string?",            // Descripción opcional
  "industry": "string?",               // "Technology", "Healthcare", etc.
  "size": "string",                    // "small", "medium", "large", "enterprise"
  
  // Contacto y ubicación
  "email": "string?",                  // Email de contacto
  "phone": "string?",                  // Teléfono
  "website": "string?",                // URL del sitio web
  "address": {
    "street": "string",
    "city": "string",
    "state": "string",
    "country": "string",
    "zipCode": "string",
    "coordinates": {
      "latitude": "number",
      "longitude": "number"
    }
  },
  
  // Configuración de trabajo
  "workSettings": {
    "timeZone": "string",               // "Europe/Madrid"
    "workDays": ["array"],              // ["monday", "tuesday", ...]
    "standardHours": {
      "start": "string",                // "09:00"
      "end": "string",                  // "17:00"
      "breakDuration": "number"         // minutos
    },
    "overtimeRules": {
      "dailyLimit": "number",           // horas antes de overtime
      "weeklyLimit": "number",          // horas semanales estándar
      "multiplier": "number"            // 1.5 para time-and-a-half
    }
  },
  
  // Configuración de ubicación
  "locationSettings": {
    "geofenceRadius": "number",         // metros (default: 100)
    "enableWifiTracking": "boolean",
    "enableBluetoothTracking": "boolean",
    "wifiNetworks": [{
      "ssid": "string",
      "isSecure": "boolean"
    }],
    "bluetoothBeacons": [{
      "uuid": "string",
      "major": "number",
      "minor": "number",
      "name": "string"
    }]
  },
  
  // Metadatos
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "createdBy": "string",              // userId del creador
  "isActive": "boolean",
  "logoUrl": "string?",               // URL del logo
  
  // Estadísticas
  "stats": {
    "totalEmployees": "number",
    "activeEmployees": "number",
    "totalLocations": "number"
  }
}
```

## 🔗 Configuración de Índices en Firestore

### Índices Simples (Automáticos)
```javascript
// Estos se crean automáticamente:
- companies: name, isActive, industry, size
- users: email, companyId, role, isActive
- shifts: userId, companyId, status, date
- locations: companyId, isActive, type
- notifications: userId, type, status, isRead
```

### Índices Compuestos (Manuales)
```javascript
// Crear en Firebase Console > Firestore > Índices

// Para consultas de shifts por usuario y fecha
shifts: (userId, date, status)
shifts: (companyId, date, status)
shifts: (userId, status, createdAt)

// Para consultas de usuarios por empresa
users: (companyId, isActive, role)
users: (companyId, role, createdAt)

// Para notificaciones
notifications: (userId, isRead, createdAt)
notifications: (userId, type, status)

// Para ubicaciones
locations: (companyId, isActive, type)

// Para reportes y analytics
shifts: (companyId, date, type)
shifts: (userId, month, status)
```

## 🔐 Reglas de Seguridad de Firestore

### Implementar en Firebase Console
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Función helper para verificar autenticación
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Función helper para verificar si es el mismo usuario
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Función helper para verificar rol de empresa
    function isCompanyRole(companyId, roles) {
      return isAuthenticated() && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.companyId == companyId &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in roles;
    }
    
    // Companies - Solo admins y owners pueden modificar
    match /companies/{companyId} {
      allow read: if isAuthenticated() && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.companyId == companyId;
      allow write: if isCompanyRole(companyId, ['admin', 'owner']);
    }
    
    // Users - Los usuarios pueden leer/escribir sus propios datos
    match /users/{userId} {
      allow read: if isOwner(userId) || 
        isCompanyRole(resource.data.companyId, ['admin', 'supervisor', 'owner']);
      allow write: if isOwner(userId) || 
        isCompanyRole(resource.data.companyId, ['admin', 'owner']);
    }
    
    // Shifts - Los usuarios pueden crear/leer sus shifts, supervisores pueden ver todos
    match /shifts/{shiftId} {
      allow read: if isAuthenticated() && (
        resource.data.userId == request.auth.uid ||
        isCompanyRole(resource.data.companyId, ['supervisor', 'admin', 'owner'])
      );
      allow create: if isAuthenticated() && request.auth.uid == resource.data.userId;
      allow update: if isAuthenticated() && (
        request.auth.uid == resource.data.userId ||
        isCompanyRole(resource.data.companyId, ['supervisor', 'admin', 'owner'])
      );
      allow delete: if isCompanyRole(resource.data.companyId, ['admin', 'owner']);
    }
    
    // Locations - Solo admins pueden modificar
    match /locations/{locationId} {
      allow read: if isAuthenticated() && 
        isCompanyRole(resource.data.companyId, ['employee', 'supervisor', 'admin', 'owner']);
      allow write: if isCompanyRole(resource.data.companyId, ['admin', 'owner']);
    }
    
    // Notifications - Los usuarios solo ven sus notificaciones
    match /notifications/{notificationId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isOwner(resource.data.userId) || 
        isCompanyRole(resource.data.companyId, ['supervisor', 'admin', 'owner']);
    }
  }
}
```

## 📱 Configuración en FlutterFlow

### Paso 1: Crear Data Types
```dart
// En FlutterFlow > Data Types

// CompanyDataType
struct CompanyDataType {
  String name
  String? description
  LatLng? coordinates
  bool isActive
  DateTime createdAt
}

// UserDataType
struct UserDataType {
  String firstName
  String lastName
  String email
  String role
  String companyId
  bool isOnShift
  DateTime? lastSeen
}

// ShiftDataType
struct ShiftDataType {
  String userId
  String companyId
  DateTime? actualStart
  DateTime? actualEnd
  String status
  double duration
  bool isAutomatic
}

// LocationDataType
struct LocationDataType {
  String name
  String companyId
  LatLng coordinates
  double geofenceRadius
  bool isActive
}
```

### Paso 2: Configurar Collections en FlutterFlow
1. Ve a **Firestore > Collections**
2. Para cada colección:
   - Click **"Create Collection"**
   - Añade los campos principales
   - Configura tipos de datos
   - Establece referencias entre documentos

### Paso 3: Crear Queries
```dart
// Queries comunes en FlutterFlow

// Obtener shifts del usuario actual
Query: shifts
Where: userId == currentUser.uid
Order by: createdAt DESC
Limit: 50

// Obtener usuarios de una empresa
Query: users
Where: companyId == selectedCompany.id AND isActive == true
Order by: firstName ASC

// Obtener shifts activos de una empresa
Query: shifts
Where: companyId == selectedCompany.id AND status == "active"
Order by: actualStart DESC
```

## ✅ Verificación del Modelo de Datos

### Checklist de Implementación
- [ ] ✅ Colecciones creadas en Firestore
- [ ] ✅ Campos configurados según especificación
- [ ] ✅ Índices compuestos creados
- [ ] ✅ Reglas de seguridad implementadas
- [ ] ✅ Data Types creados en FlutterFlow
- [ ] ✅ Collections configuradas en FlutterFlow
- [ ] ✅ Queries básicas testadas
- [ ] ✅ Referencias entre documentos funcionando

### Test del Modelo
```dart
// Test básico - crear en FlutterFlow Custom Action
Future<void> testDataModel() async {
  // 1. Crear empresa de prueba
  final company = await FirebaseFirestore.instance
    .collection('companies')
    .add({
      'name': 'Test Company',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  
  // 2. Crear usuario de prueba
  final user = await FirebaseFirestore.instance
    .collection('users')
    .add({
      'firstName': 'Test',
      'lastName': 'User',
      'email': 'test@example.com',
      'companyId': company.id,
      'role': 'employee',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  
  // 3. Crear shift de prueba
  await FirebaseFirestore.instance
    .collection('shifts')
    .add({
      'userId': user.id,
      'companyId': company.id,
      'status': 'active',
      'actualStart': FieldValue.serverTimestamp(),
      'isAutomatic': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  
  print('✅ Modelo de datos testeado exitosamente');
}
```

## 🚀 Próximos Pasos

Con el modelo de datos configurado:

1. **[🎨 Componentes UI](03-ui-components.md)** - Crear interfaces
2. **[⚙️ Lógica de Negocio](04-business-logic.md)** - Implementar funcionalidades
3. **[🧪 Testing](05-testing.md)** - Validar el sistema

---

**📊 ¡Modelo de datos completo!** La estructura está lista para soportar todas las funcionalidades de ShiftSense.

**➡️ Siguiente: [Componentes UI](03-ui-components.md)**
