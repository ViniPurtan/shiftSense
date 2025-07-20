# 🎨 Componentes UI - ShiftSense

Esta guía te ayudará a crear todos los componentes de interfaz para ShiftSense usando Material Design 3 en FlutterFlow.

## 🎯 Visión General de la UI

### Arquitectura de Navegación
```
ShiftSense App
├── 🔐 Authentication Flow
│   ├── Login Page
│   ├── Register Page
│   └── Password Reset
├── 📱 Main App (Bottom Navigation)
│   ├── 🏠 Dashboard
│   ├── ⏰ Time Tracking
│   ├── 📊 Reports
│   ├── 👥 Team (Supervisors+)
│   └── ⚙️ Settings
├── 📋 Secondary Pages
│   ├── Profile Management
│   ├── Shift Details
│   ├── Location Management
│   ├── Notifications
│   └── Help & Support
└── 🔧 Admin Pages
    ├── Company Settings
    ├── User Management
    ├── Location Setup
    └── Reports Dashboard
```

### Material 3 Theme Configuration
```dart
// En FlutterFlow Theme Settings
Material 3 Theme:
  Primary: #1976D2 (Blue 700)
  Secondary: #FF9800 (Orange 500)
  Tertiary: #9C27B0 (Purple 500)
  Surface: #FFFFFF
  Background: #F5F5F5
  Error: #D32F2F
  Success: #388E3C
  Warning: #F57C00
  
Dark Theme:
  Primary: #90CAF9 (Blue 200)
  Secondary: #FFB74D (Orange 300)
  Surface: #121212
  Background: #000000
```

## 🔐 1. Authentication Flow

### 1.1 Login Page
```dart
// En FlutterFlow: Crear página "LoginPage"
Layout: Column
Padding: 24px all sides
Background: Gradient (Primary to Secondary)

Components:
1. AppBar (transparent)
2. Logo Container
3. Welcome Text
4. Login Form
5. Social Login Buttons
6. Register Link
```

#### Login Form Component
```dart
// Container con Material 3 styling
Container {
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [Material3 elevation]
  ),
  
  child: Column(
    children: [
      // Logo y título
      SizedBox(height: 32),
      Icon(Icons.work_outline, size: 64, color: primary),
      Text('ShiftSense', style: displayMedium),
      Text('Gestión inteligente de turnos', style: bodyLarge),
      
      SizedBox(height: 32),
      
      // Email Field
      TextField(
        decoration: InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(Icons.email_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          filled: true,
          fillColor: Colors.grey[50]
        ),
        keyboardType: TextInputType.emailAddress
      ),
      
      SizedBox(height: 16),
      
      // Password Field
      TextField(
        decoration: InputDecoration(
          labelText: 'Contraseña',
          prefixIcon: Icon(Icons.lock_outlined),
          suffixIcon: Icon(Icons.visibility_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          filled: true,
          fillColor: Colors.grey[50]
        ),
        obscureText: true
      ),
      
      SizedBox(height: 24),
      
      // Login Button
      FilledButton(
        onPressed: () {},
        style: FilledButton.styleFrom(
          minimumSize: Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          )
        ),
        child: Text('Iniciar Sesión', style: titleMedium)
      ),
      
      SizedBox(height: 16),
      
      // Google Sign In
      OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.g_mobiledata, size: 24),
        label: Text('Continuar con Google'),
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          )
        )
      )
    ]
  )
}
```

## 🏠 2. Dashboard Principal

### 2.1 Dashboard Layout
```dart
// Página principal con scroll view
CustomScrollView(
  slivers: [
    // App Bar con información del usuario
    SliverAppBar(
      expandedHeight: 200,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('Hola, ${user.firstName}'),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, secondary]
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.profilePictureUrl)
              ),
              SizedBox(height: 8),
              Text(
                '${user.firstName} ${user.lastName}',
                style: headlineSmall.copyWith(color: Colors.white)
              ),
              Text(
                user.position ?? user.role,
                style: bodyMedium.copyWith(color: Colors.white70)
              )
            ]
          )
        )
      )
    ),
    
    // Current Status Card
    SliverToBoxAdapter(
      child: CurrentStatusCard()
    ),
    
    // Quick Actions
    SliverToBoxAdapter(
      child: QuickActionsGrid()
    ),
    
    // Recent Activity
    SliverToBoxAdapter(
      child: RecentActivityList()
    )
  ]
)
```

### 2.2 Current Status Card
```dart
// Widget para mostrar el estado actual del turno
Container(
  margin: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: isOnShift ? Colors.green[50] : Colors.orange[50],
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isOnShift ? Colors.green : Colors.orange,
      width: 2
    )
  ),
  child: Padding(
    padding: EdgeInsets.all(20),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnShift ? Colors.green : Colors.orange
              )
            ),
            SizedBox(width: 8),
            Text(
              isOnShift ? 'En Turno' : 'Fuera de Turno',
              style: titleLarge.copyWith(
                fontWeight: FontWeight.bold
              )
            ),
            Spacer(),
            Icon(
              isOnShift ? Icons.work : Icons.work_off,
              color: isOnShift ? Colors.green : Colors.orange,
              size: 32
            )
          ]
        ),
        
        SizedBox(height: 16),
        
        if (isOnShift) ...
          // Información del turno actual
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inicio', style: bodySmall),
                      Text(
                        DateFormat('HH:mm').format(shiftStartTime),
                        style: titleMedium
                      )
                    ]
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Duración', style: bodySmall),
                      StreamBuilder(
                        stream: Stream.periodic(Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          final duration = DateTime.now().difference(shiftStartTime);
                          return Text(
                            formatDuration(duration),
                            style: titleMedium.copyWith(
                              fontWeight: FontWeight.bold
                            )
                          );
                        }
                      )
                    ]
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Ubicación', style: bodySmall),
                      Text(
                        currentLocation?.name ?? 'Detectando...',
                        style: titleMedium
                      )
                    ]
                  )
                ]
              ),
              
              SizedBox(height: 16),
              
              // Botón de Check Out
              FilledButton.icon(
                onPressed: () => showCheckOutDialog(),
                icon: Icon(Icons.logout),
                label: Text('Terminar Turno'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 48)
                )
              )
            ]
          )
        else ...
          // Botón de Check In
          Column(
            children: [
              Text(
                'Presiona para comenzar tu turno cuando llegues al trabajo',
                style: bodyMedium,
                textAlign: TextAlign.center
              ),
              
              SizedBox(height: 16),
              
              FilledButton.icon(
                onPressed: () => showCheckInDialog(),
                icon: Icon(Icons.login),
                label: Text('Iniciar Turno'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 48)
                )
              )
            ]
          )
      ]
    )
  )
)
```

### 2.3 Quick Actions Grid
```dart
// Grid de acciones rápidas
Container(
  margin: EdgeInsets.symmetric(horizontal: 16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Acciones Rápidas',
        style: titleLarge.copyWith(fontWeight: FontWeight.bold)
      ),
      
      SizedBox(height: 16),
      
      GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          // Time Tracking
          QuickActionCard(
            icon: Icons.access_time,
            title: 'Seguimiento',
            subtitle: 'Ver historial de turnos',
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(context, '/time-tracking')
          ),
          
          // Request Time Off
          QuickActionCard(
            icon: Icons.event_busy,
            title: 'Solicitar Permiso',
            subtitle: 'Vacaciones o ausencias',
            color: Colors.orange,
            onTap: () => showTimeOffDialog()
          ),
          
          // View Schedule
          QuickActionCard(
            icon: Icons.calendar_today,
            title: 'Horario',
            subtitle: 'Ver horario semanal',
            color: Colors.purple,
            onTap: () => Navigator.pushNamed(context, '/schedule')
          ),
          
          // Reports
          QuickActionCard(
            icon: Icons.assessment,
            title: 'Reportes',
            subtitle: 'Estadísticas de trabajo',
            color: Colors.green,
            onTap: () => Navigator.pushNamed(context, '/reports')
          )
        ]
      )
    ]
  )
)
```

## ⏰ 3. Time Tracking Page

### 3.1 Time Tracking Layout
```dart
// Página de seguimiento de tiempo
Scaffold(
  appBar: AppBar(
    title: Text('Seguimiento de Tiempo'),
    actions: [
      IconButton(
        icon: Icon(Icons.filter_list),
        onPressed: () => showFilterDialog()
      ),
      IconButton(
        icon: Icon(Icons.file_download),
        onPressed: () => exportTimesheet()
      )
    ]
  ),
  body: Column(
    children: [
      // Date Range Selector
      DateRangeSelector(),
      
      // Summary Cards
      SummaryCardsRow(),
      
      // Shift List
      Expanded(
        child: ShiftListView()
      )
    ]
  ),
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () => showManualEntryDialog(),
    icon: Icon(Icons.add),
    label: Text('Entrada Manual')
  )
)
```

### 3.2 Shift List Item
```dart
// Item de la lista de turnos
class ShiftListItem extends StatelessWidget {
  final Shift shift;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor(shift.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)
          ),
          child: Icon(
            _getStatusIcon(shift.status),
            color: _getStatusColor(shift.status)
          )
        ),
        
        title: Text(
          DateFormat('EEEE, dd MMMM', 'es').format(shift.date),
          style: titleMedium.copyWith(fontWeight: FontWeight.bold)
        ),
        
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  '${DateFormat('HH:mm').format(shift.actualStart)} - ${DateFormat('HH:mm').format(shift.actualEnd)}',
                  style: bodyMedium
                ),
                
                Spacer(),
                
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(shift.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Text(
                    _getStatusText(shift.status),
                    style: bodySmall.copyWith(
                      color: _getStatusColor(shift.status),
                      fontWeight: FontWeight.bold
                    )
                  )
                )
              ]
            ),
            
            SizedBox(height: 4),
            
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    shift.location?.name ?? 'Ubicación no detectada',
                    style: bodySmall.copyWith(color: Colors.grey[600])
                  )
                ),
                
                Text(
                  '${formatDuration(shift.duration)} hrs',
                  style: titleSmall.copyWith(fontWeight: FontWeight.bold)
                )
              ]
            )
          ]
        ),
        
        onTap: () => Navigator.pushNamed(
          context, 
          '/shift-details',
          arguments: shift
        )
      )
    );
  }
}
```

## 📊 4. Reports Page

### 4.1 Reports Dashboard
```dart
// Página de reportes con tabs
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      title: Text('Reportes y Análisis'),
      bottom: TabBar(
        tabs: [
          Tab(icon: Icon(Icons.person), text: 'Personal'),
          Tab(icon: Icon(Icons.group), text: 'Equipo'),
          Tab(icon: Icon(Icons.business), text: 'Empresa')
        ]
      )
    ),
    body: TabBarView(
      children: [
        PersonalReportsView(),
        TeamReportsView(),
        CompanyReportsView()
      ]
    )
  )
)
```

## 📱 5. Configuración en FlutterFlow

### 5.1 Crear Pages en FlutterFlow

1. **LoginPage**
   - Type: Authentication Page
   - Layout: Column with ScrollView
   - Components: Logo, Form, Buttons

2. **DashboardPage**
   - Type: Main Page
   - Layout: Custom ScrollView
   - Components: SliverAppBar, Status Card, Quick Actions

3. **TimeTrackingPage**
   - Type: Secondary Page
   - Layout: Column with ListView
   - Components: Date Selector, Summary Cards, Shift List

4. **ReportsPage**
   - Type: Secondary Page
   - Layout: TabBar with TabBarView
   - Components: Charts, Export Buttons, Filters

### 5.2 Configurar Bottom Navigation
```dart
// En FlutterFlow Main Navigation
Bottom Navigation Bar:
  - Dashboard (Icons.home)
  - Time Tracking (Icons.access_time)
  - Reports (Icons.assessment)
  - Team (Icons.people) [Solo supervisores]
  - Settings (Icons.settings)
```

### 5.3 Theme Configuration
```dart
// Configurar en FlutterFlow Theme Editor
Material 3 Settings:
  - Enable Material 3: true
  - Dynamic Colors: true (Android 12+)
  - Color Scheme: Custom
  - Primary: #1976D2
  - Secondary: #FF9800
  - Surface Tint: Enabled
  - Elevation: Material 3 Levels
```

## ✅ Checklist de Componentes UI

### Páginas Principales
- [ ] ✅ Login Page con Material 3
- [ ] ✅ Dashboard con SliverAppBar
- [ ] ✅ Time Tracking con filtros
- [ ] ✅ Reports con TabBar
- [ ] ✅ Settings Page
- [ ] ✅ Profile Management

### Componentes Reutilizables
- [ ] ✅ Current Status Card
- [ ] ✅ Quick Action Card
- [ ] ✅ Shift List Item
- [ ] ✅ Summary Cards
- [ ] ✅ Date Range Selector
- [ ] ✅ Custom App Bar

### Elementos de UI
- [ ] ✅ Bottom Navigation
- [ ] ✅ Floating Action Buttons
- [ ] ✅ Dialog Components
- [ ] ✅ Form Components
- [ ] ✅ Loading States
- [ ] ✅ Error States

## 🚀 Próximos Pasos

Con los componentes UI configurados:

1. **[⚙️ Lógica de Negocio](04-business-logic.md)** - Implementar Custom Actions
2. **[🧪 Testing](05-testing.md)** - Probar componentes y flujos
3. **[🚀 Despliegue](06-deployment.md)** - Publicar aplicación

---

**🎨 ¡Componentes UI completados!** Tu interfaz de ShiftSense está lista con Material Design 3.

**➡️ Siguiente: [Lógica de Negocio](04-business-logic.md)**
