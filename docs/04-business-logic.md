# ⚙️ Lógica de Negocio - ShiftSense

Esta guía detalla la implementación de toda la lógica de negocio para ShiftSense en FlutterFlow, incluyendo Custom Actions, Cloud Functions y flujos de trabajo.

## 🎯 Visión General de la Lógica

### Arquitectura de la Lógica de Negocio
```
ShiftSense Business Logic
├── 📱 Frontend Logic (FlutterFlow)
│   ├── Custom Actions
│   ├── Page Actions
│   ├── Component Actions
│   └── State Management
├── ☁️ Backend Logic (Firebase)
│   ├── Cloud Functions
│   ├── Firestore Triggers
│   ├── Authentication Triggers
│   └── Scheduled Functions
└── 🔄 Integration Logic
    ├── Location Services
    ├── Notification System
    ├── Report Generation
    └── External APIs
```

## 📱 1. Custom Actions en FlutterFlow

### 1.1 Location Tracking Actions

#### requestLocationPermissions()
```dart
// Custom Action: Solicitar permisos de ubicación
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

Future<Map<String, dynamic>> requestLocationPermissions() async {
  try {
    // Verificar permisos actuales
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        return {
          'success': false,
          'error': 'Permisos de ubicación denegados',
          'shouldShowRationale': true
        };
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return {
        'success': false,
        'error': 'Permisos de ubicación denegados permanentemente',
        'shouldOpenSettings': true
      };
    }
    
    // Verificar si el servicio de ubicación está habilitado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        'success': false,
        'error': 'Servicio de ubicación deshabilitado',
        'shouldEnableService': true
      };
    }
    
    return {
      'success': true,
      'permission': permission.toString()
    };
    
  } catch (e) {
    return {
      'success': false,
      'error': 'Error al solicitar permisos: $e'
    };
  }
}
```

#### startShift()
```dart
// Custom Action: Iniciar turno
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<String, dynamic>> startShift(
  String locationId,
  double latitude,
  double longitude,
  String detectionMethod
) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'success': false, 'error': 'Usuario no autenticado'};
    }
    
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    
    // Verificar si ya hay un turno activo
    final activeShifts = await firestore
        .collection('shifts')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .get();
    
    if (activeShifts.docs.isNotEmpty) {
      return {
        'success': false,
        'error': 'Ya hay un turno activo',
        'existingShiftId': activeShifts.docs.first.id
      };
    }
    
    // Obtener información del usuario
    final userDoc = await firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data()!;
    final companyId = userData['companyId'] as String;
    
    // Crear nuevo documento de turno
    final shiftData = {
      'userId': user.uid,
      'companyId': companyId,
      'locationId': locationId,
      'status': 'active',
      'type': 'regular',
      'isAutomatic': detectionMethod != 'manual',
      
      // Tiempos
      'actualStart': Timestamp.fromDate(now),
      'clockInTime': Timestamp.fromDate(now),
      
      // Ubicación de check-in
      'locationData': {
        'clockInLocation': {
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': 10.0,
          'method': detectionMethod,
          'timestamp': Timestamp.fromDate(now)
        },
        'isWithinGeofence': true
      },
      
      // Metadatos
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'date': DateFormat('yyyy-MM-dd').format(now),
      'month': DateFormat('yyyy-MM').format(now)
    };
    
    // Guardar turno en Firestore
    final shiftRef = await firestore.collection('shifts').add(shiftData);
    
    // Actualizar estado del usuario
    await firestore.collection('users').doc(user.uid).update({
      'currentStatus.isOnShift': true,
      'currentStatus.currentShiftId': shiftRef.id,
      'currentStatus.lastSeen': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp()
    });
    
    // Actualizar App State
    FFAppState().isOnShift = true;
    FFAppState().currentShiftId = shiftRef.id;
    FFAppState().shiftStartTime = now;
    
    return {
      'success': true,
      'shiftId': shiftRef.id,
      'message': 'Turno iniciado correctamente'
    };
    
  } catch (e) {
    return {
      'success': false,
      'error': 'Error al iniciar turno: $e'
    };
  }
}
```

#### endShift()
```dart
// Custom Action: Finalizar turno
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<String, dynamic>> endShift(
  String shiftId,
  double latitude,
  double longitude,
  String detectionMethod
) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'success': false, 'error': 'Usuario no autenticado'};
    }
    
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    
    // Obtener documento del turno
    final shiftDoc = await firestore.collection('shifts').doc(shiftId).get();
    if (!shiftDoc.exists) {
      return {'success': false, 'error': 'Turno no encontrado'};
    }
    
    final shiftData = shiftDoc.data()!;
    
    // Verificar que el turno pertenece al usuario
    if (shiftData['userId'] != user.uid) {
      return {'success': false, 'error': 'Turno no autorizado'};
    }
    
    // Calcular duración del turno
    final startTime = (shiftData['actualStart'] as Timestamp).toDate();
    final duration = now.difference(startTime);
    final durationMinutes = duration.inMinutes;
    
    // Verificar duración mínima (15 minutos)
    if (durationMinutes < 15) {
      return {
        'success': false,
        'error': 'El turno debe durar al menos 15 minutos',
        'currentDuration': durationMinutes
      };
    }
    
    // Calcular horas regulares y overtime
    final totalHours = duration.inMinutes / 60.0;
    final dailyLimit = 8.0; // horas antes de overtime
    final regularHours = totalHours > dailyLimit ? dailyLimit : totalHours;
    final overtimeHours = totalHours > dailyLimit ? totalHours - dailyLimit : 0.0;
    
    // Actualizar documento del turno
    final updateData = {
      'actualEnd': Timestamp.fromDate(now),
      'clockOutTime': Timestamp.fromDate(now),
      'status': 'completed',
      
      // Ubicación de check-out
      'locationData.clockOutLocation': {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': 10.0,
        'method': detectionMethod,
        'timestamp': Timestamp.fromDate(now)
      },
      
      // Duración calculada
      'duration': {
        'actual': durationMinutes,
        'regular': (regularHours * 60).round(),
        'overtime': (overtimeHours * 60).round(),
        'paid': durationMinutes
      },
      
      'updatedAt': FieldValue.serverTimestamp()
    };
    
    await firestore.collection('shifts').doc(shiftId).update(updateData);
    
    // Actualizar estado del usuario
    await firestore.collection('users').doc(user.uid).update({
      'currentStatus.isOnShift': false,
      'currentStatus.currentShiftId': null,
      'currentStatus.lastSeen': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp()
    });
    
    // Actualizar App State
    FFAppState().isOnShift = false;
    FFAppState().currentShiftId = null;
    FFAppState().shiftStartTime = null;
    
    return {
      'success': true,
      'message': 'Turno finalizado correctamente',
      'duration': durationMinutes,
      'regularHours': regularHours,
      'overtimeHours': overtimeHours
    };
    
  } catch (e) {
    return {
      'success': false,
      'error': 'Error al finalizar turno: $e'
    };
  }
}
```

### 1.3 WiFi Detection Actions

#### scanWifiNetworks()
```dart
// Custom Action: Escanear redes WiFi
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

Future<Map<String, dynamic>> scanWifiNetworks() async {
  try {
    // Solicitar permisos necesarios
    Map<Permission, PermissionStatus> permissions = await [
      Permission.location,
      Permission.locationWhenInUse,
    ].request();
    
    if (permissions[Permission.location] != PermissionStatus.granted) {
      return {
        'success': false,
        'error': 'Permisos de ubicación necesarios para escanear WiFi'
      };
    }
    
    // Obtener información de la red WiFi actual
    String? wifiName = await WifiInfo().getWifiName();
    String? wifiBSSID = await WifiInfo().getWifiBSSID();
    String? wifiIP = await WifiInfo().getWifiIP();
    
    // En Android, necesitamos verificar si estamos conectados a WiFi
    if (wifiName == null || wifiName == '<unknown ssid>') {
      return {
        'success': false,
        'error': 'No conectado a red WiFi o sin permisos',
        'networks': []
      };
    }
    
    // Limpiar nombre de la red (remover comillas)
    wifiName = wifiName.replaceAll('"', '');
    
    List<Map<String, dynamic>> detectedNetworks = [];
    
    if (wifiName != null && wifiName.isNotEmpty) {
      detectedNetworks.add({
        'ssid': wifiName,
        'bssid': wifiBSSID ?? '',
        'connected': true,
        'signalStrength': -50, // Estimado para red conectada
        'frequency': 2400, // Estimado
        'capabilities': 'WPA2',
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });
    }
    
    return {
      'success': true,
      'currentNetwork': {
        'ssid': wifiName,
        'bssid': wifiBSSID,
        'ip': wifiIP
      },
      'networks': detectedNetworks,
      'networkCount': detectedNetworks.length
    };
    
  } catch (e) {
    return {
      'success': false,
      'error': 'Error al escanear redes WiFi: $e',
      'networks': []
    };
  }
}
```

### 1.4 Notification Actions

#### sendPushNotification()
```dart
// Custom Action: Enviar notificación push
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>> sendPushNotification(
  String title,
  String body,
  String type,
  Map<String, dynamic>? data
) async {
  try {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    
    // Configuración de la notificación
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'shiftsense_channel',
      'ShiftSense Notifications',
      channelDescription: 'Notificaciones de turnos y ubicación',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher'
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics
    );
    
    // Generar ID único para la notificación
    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    
    // Mostrar notificación local
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
      payload: jsonEncode(data ?? {})
    );
    
    return {
      'success': true,
      'notificationId': notificationId,
      'message': 'Notificación enviada correctamente'
    };
    
  } catch (e) {
    return {
      'success': false,
      'error': 'Error al enviar notificación: $e'
    };
  }
}
```

## ☁️ 2. Cloud Functions (Firebase)

### 2.1 Trigger Functions

#### onShiftCreated()
```javascript
// functions/src/index.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// Trigger cuando se crea un nuevo turno
export const onShiftCreated = functions.firestore
  .document('shifts/{shiftId}')
  .onCreate(async (snap, context) => {
    const shiftData = snap.data();
    const shiftId = context.params.shiftId;
    
    try {
      // Enviar notificación al supervisor
      if (shiftData.companyId) {
        await notifySupervisors(shiftData.companyId, {
          title: 'Nuevo turno iniciado',
          body: `${shiftData.userId} ha iniciado su turno`,
          data: {
            type: 'shift_start',
            shiftId: shiftId,
            userId: shiftData.userId
          }
        });
      }
      
      // Actualizar estadísticas de la empresa
      await updateCompanyStats(shiftData.companyId);
      
      console.log(`Turno ${shiftId} procesado correctamente`);
    } catch (error) {
      console.error('Error procesando nuevo turno:', error);
    }
  });

// Trigger cuando se completa un turno
export const onShiftCompleted = functions.firestore
  .document('shifts/{shiftId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const shiftId = context.params.shiftId;
    
    // Solo procesar si el estado cambió a 'completed'
    if (beforeData.status !== 'completed' && afterData.status === 'completed') {
      try {
        // Calcular estadísticas del turno
        await calculateShiftEarnings(shiftId, afterData);
        
        // Actualizar estadísticas del usuario
        await updateUserStats(afterData.userId, afterData.duration);
        
        // Enviar notificación de turno completado
        await sendCompletionNotification(afterData.userId, afterData);
        
        console.log(`Turno ${shiftId} completado y procesado`);
      } catch (error) {
        console.error('Error procesando turno completado:', error);
      }
    }
  });

// Función auxiliar para notificar supervisores
async function notifySupervisors(companyId: string, notification: any) {
  const supervisors = await admin.firestore()
    .collection('users')
    .where('companyId', '==', companyId)
    .where('role', 'in', ['supervisor', 'admin', 'owner'])
    .where('isActive', '==', true)
    .get();
  
  const notifications = supervisors.docs.map(doc => {
    const userData = doc.data();
    return admin.firestore()
      .collection('notifications')
      .add({
        userId: doc.id,
        companyId: companyId,
        title: notification.title,
        body: notification.body,
        type: notification.data.type,
        priority: 'normal',
        category: 'time_tracking',
        status: 'pending',
        isRead: false,
        relatedData: notification.data,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
  });
  
  await Promise.all(notifications);
}
```

### 2.2 Scheduled Functions

#### dailyReportGeneration()
```javascript
// Función programada para generar reportes diarios
export const dailyReportGeneration = functions.pubsub
  .schedule('0 23 * * *') // Todos los días a las 23:00
  .timeZone('Europe/Madrid')
  .onRun(async (context) => {
    console.log('Iniciando generación de reportes diarios');
    
    try {
      const today = new Date();
      const dateString = today.toISOString().split('T')[0];
      
      // Obtener todas las empresas activas
      const companies = await admin.firestore()
        .collection('companies')
        .where('isActive', '==', true)
        .get();
      
      for (const companyDoc of companies.docs) {
        const companyId = companyDoc.id;
        const companyData = companyDoc.data();
        
        // Generar reporte diario para cada empresa
        await generateDailyReport(companyId, dateString);
        
        // Enviar reporte por email a administradores
        await sendDailyReportEmail(companyId, companyData, dateString);
      }
      
      console.log('Reportes diarios generados exitosamente');
    } catch (error) {
      console.error('Error generando reportes diarios:', error);
    }
  });

async function generateDailyReport(companyId: string, date: string) {
  // Obtener todos los turnos del día
  const shifts = await admin.firestore()
    .collection('shifts')
    .where('companyId', '==', companyId)
    .where('date', '==', date)
    .where('status', '==', 'completed')
    .get();
  
  let totalHours = 0;
  let totalOvertimeHours = 0;
  let totalEmployees = new Set();
  
  shifts.docs.forEach(doc => {
    const shiftData = doc.data();
    totalEmployees.add(shiftData.userId);
    
    if (shiftData.duration) {
      totalHours += (shiftData.duration.actual || 0) / 60;
      totalOvertimeHours += (shiftData.duration.overtime || 0) / 60;
    }
  });
  
  // Guardar reporte en Firestore
  await admin.firestore()
    .collection('reports')
    .add({
      companyId: companyId,
      type: 'daily',
      date: date,
      data: {
        totalShifts: shifts.size,
        totalHours: Math.round(totalHours * 100) / 100,
        totalOvertimeHours: Math.round(totalOvertimeHours * 100) / 100,
        totalEmployees: totalEmployees.size,
        averageHoursPerEmployee: totalEmployees.size > 0 
          ? Math.round((totalHours / totalEmployees.size) * 100) / 100 
          : 0
      },
      generatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
}
```

### 2.3 HTTP Functions

#### exportTimesheet()
```javascript
// Función HTTP para exportar hojas de tiempo
export const exportTimesheet = functions.https.onCall(async (data, context) => {
  // Verificar autenticación
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuario no autenticado');
  }
  
  const { userId, startDate, endDate, format } = data;
  
  try {
    // Verificar permisos del usuario
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(context.auth.uid)
      .get();
    
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
    }
    
    const userData = userDoc.data()!;
    const canExport = userData.role === 'admin' || 
                     userData.role === 'supervisor' || 
                     context.auth.uid === userId;
    
    if (!canExport) {
      throw new functions.https.HttpsError('permission-denied', 'Sin permisos para exportar');
    }
    
    // Obtener turnos en el rango de fechas
    const shifts = await admin.firestore()
      .collection('shifts')
      .where('userId', '==', userId)
      .where('date', '>=', startDate)
      .where('date', '<=', endDate)
      .where('status', '==', 'completed')
      .orderBy('date', 'asc')
      .get();
    
    // Generar datos para exportación
    const exportData = shifts.docs.map(doc => {
      const shift = doc.data();
      return {
        fecha: shift.date,
        horaInicio: shift.actualStart?.toDate().toLocaleTimeString('es-ES', {
          hour: '2-digit',
          minute: '2-digit'
        }),
        horaFin: shift.actualEnd?.toDate().toLocaleTimeString('es-ES', {
          hour: '2-digit',
          minute: '2-digit'
        }),
        horasTrabajadas: (shift.duration?.actual || 0) / 60,
        horasExtra: (shift.duration?.overtime || 0) / 60,
        ubicacion: shift.locationData?.clockInLocation?.address || 'No disponible',
        metodo: shift.locationData?.clockInLocation?.method || 'manual'
      };
    });
    
    if (format === 'csv') {
      // Generar CSV
      const csv = generateCSV(exportData);
      return {
        success: true,
        data: csv,
        format: 'csv',
        filename: `timesheet_${userId}_${startDate}_${endDate}.csv`
      };
    } else {
      // Devolver JSON
      return {
        success: true,
        data: exportData,
        format: 'json',
        filename: `timesheet_${userId}_${startDate}_${endDate}.json`
      };
    }
    
  } catch (error) {
    console.error('Error exportando hoja de tiempo:', error);
    throw new functions.https.HttpsError('internal', 'Error interno del servidor');
  }
});

function generateCSV(data: any[]): string {
  if (data.length === 0) return '';
  
  const headers = Object.keys(data[0]).join(',');
  const rows = data.map(row => 
    Object.values(row).map(value => 
      typeof value === 'string' && value.includes(',') 
        ? `"${value}"` 
        : value
    ).join(',')
  );
  
  return [headers, ...rows].join('\n');
}
```

## 📱 3. Configuración en FlutterFlow

### 3.1 Crear Custom Actions

1. **Ve a Custom Code > Actions**
2. **Crear nuevas acciones:**
   - `requestLocationPermissions`
   - `getCurrentLocation`
   - `checkGeofenceEntry`
   - `startShift`
   - `endShift`
   - `scanWifiNetworks`
   - `sendPushNotification`

### 3.2 Configurar Page Actions

```dart
// Ejemplo: Dashboard Page - OnPageLoad
onPageLoad() {
  // Verificar permisos de ubicación
  requestLocationPermissions().then((result) {
    if (result['success']) {
      // Iniciar seguimiento de ubicación
      startLocationTracking();
    }
  });
  
  // Verificar si hay turno activo
  if (FFAppState().isOnShift) {
    // Actualizar información del turno actual
    updateCurrentShiftInfo();
  }
}

// Ejemplo: Check-in Button Action
onCheckInPressed() {
  getCurrentLocation().then((locationResult) {
    if (locationResult['success']) {
      // Verificar geofence
      checkGeofenceEntry(
        locationResult['latitude'],
        locationResult['longitude'],
        FFAppState().workplaceLocation.latitude,
        FFAppState().workplaceLocation.longitude,
        100.0 // radio en metros
      ).then((geofenceResult) {
        if (geofenceResult['isInside']) {
          // Iniciar turno
          startShift(
            FFAppState().selectedLocationId,
            locationResult['latitude'],
            locationResult['longitude'],
            'gps'
          ).then((shiftResult) {
            if (shiftResult['success']) {
              // Mostrar confirmación
              showSnackBar('Turno iniciado correctamente');
              // Navegar al dashboard actualizado
              setState();
            }
          });
        } else {
          // Usuario fuera del área de trabajo
          showDialog('No estás en el área de trabajo');
        }
      });
    }
  });
}
```

### 3.3 Configurar State Management

```dart
// App State Variables
- currentUser: DocumentReference?
- isOnShift: bool = false
- currentShiftId: String?
- shiftStartTime: DateTime?
- currentLocation: LatLng?
- workplaceLocation: LatLng?
- selectedLocationId: String?
- wasInsideGeofence: bool = false

// Local State (por página)
- shifts: List<ShiftRecord>
- isLoading: bool = false
- errorMessage: String?
- selectedDateRange: DateTimeRange?
```

## ✅ Checklist de Lógica de Negocio

### Custom Actions
- [ ] ✅ Location permissions y tracking
- [ ] ✅ Geofence detection
- [ ] ✅ Shift start/end logic
- [ ] ✅ WiFi network scanning
- [ ] ✅ Push notifications
- [ ] ✅ Data export functions

### Cloud Functions
- [ ] ✅ Shift creation triggers
- [ ] ✅ Completion processing
- [ ] ✅ Daily report generation
- [ ] ✅ Notification system
- [ ] ✅ Statistics updates
- [ ] ✅ Data validation

### Integration
- [ ] ✅ Firebase Auth integration
- [ ] ✅ Firestore real-time updates
- [ ] ✅ Location services
- [ ] ✅ Background processing
- [ ] ✅ Error handling
- [ ] ✅ Offline capabilities

## 🚀 Próximos Pasos

Con la lógica de negocio implementada:

1. **[🧪 Testing](05-testing.md)** - Probar todas las funcionalidades
2. **[🚀 Despliegue](06-deployment.md)** - Configurar CI/CD y deployment
3. Optimizar rendimiento y seguridad

---

**⚙️ ¡Lógica de negocio completada!** ShiftSense tiene toda la funcionalidad backend implementada.

**➡️ Siguiente: [Testing](05-testing.md)**
