# Estados de las solicitudes 

## Inicio con trompicones
1. Estado inicial: Pendiente
Cuando solicitas cualquier tipo de ausencia (vacaciones, baja médica, etc.), la solicitud se crea con el estado pendiente (VacationStatus.pending).
Esto es así para todos los tipos, incluso para bajas médicas y urgencias.
2. ¿Quién valida la solicitud?
Por defecto, el sistema NO la aprueba automáticamente.
La lógica actual no contiene ningún proceso automático que cambie el estado de pendiente a aprobado o rechazado.
Normalmente, esto lo haría un responsable, administrador o alguien con permisos de gestión, a través de una pantalla de administración o mediante una acción manual.
3. ¿Dónde se gestiona esto en el código?
El modelo Vacation tiene el campo status que puede ser pending, approved o rejected.
No hay lógica automática en el sistema que apruebe o rechace solicitudes, ni siquiera para bajas médicas o urgencias.

## Propuesta para la mejora de la app
### Reglas 
- El primero de los empleados que solicita es al primero que se le otrogan las vacaciones anuales. El sistema se encargara de una vez introducidos las vacaciones recrear los turnos en funcion de ello. El sistema lo hara automáticamente cada vez que hay un cambio o solicitud de vacaciones. 
- Bajas medicas y urgencias seran aceptadas automaticamente y el sistema re-gestionara los turnos de manera inmediata avisando a los interlocutores de sus cambios de turnos pertinentes.
- Asuntos personales se aceptaran siempre y cuando se avisen con 48h de antelación. El sistema, de nuevo lo gestionara y reubicara los empleados en nuevos turnos etc. 

## Reglas y funcionamiento propuesto

### 1. Bajas médicas y urgencias
- Se aprueban automáticamente al solicitarse.
- El sistema regenera los turnos inmediatamente y notifica a los empleados afectados.

### 2. Vacaciones anuales
- El orden de solicitud determina la prioridad: el primero que solicita es el primero en ser aprobado.
- Cuando un empleado solicita vacaciones anuales:
- Se crea la solicitud en estado "pendiente".
- El sistema, tras cada nueva solicitud, revisa todas las solicitudes pendientes en orden de llegada y aprueba tantas como sea posible (según la disponibilidad mínima de empleados).
- Tras cada aprobación, se regeneran los turnos automáticamente.

### 3. Asuntos personales
- Se aprueban automáticamente si se solicitan con al menos 48h de antelación.
- El sistema regenera los turnos y notifica a los empleados afectados.

* * *

## ¿Quién valida?

- El sistema es el responsable de aprobar/rechazar solicitudes según las reglas anteriores.
- No es necesario que un administrador intervenga manualmente, salvo en casos de maxima prioridad.

## Plan de implementación

### 1. Lógica automática (backend/app)

- El sistema aprueba automáticamente según las reglas que definimos.
- Tras cada cambio, se regeneran los turnos.
- El administrador puede modificar el estado de cualquier solicitud manualmente.

### 2. Pantalla de Administrador

- Nueva pantalla accesible solo para administradores.
- Permite:
- Ver todas las solicitudes de vacaciones/ausencias (pendientes, aprobadas, rechazadas).
- Filtrar por tipo, estado, empleado, fecha.
- Aprobar, rechazar o modificar cualquier solicitud manualmente.
- Forzar la regeneración de turnos si es necesario.
- (Opcional) Ver un historial de cambios y notificaciones. - ???? (irrelevante?) preguntar al cliente. 

## Solución propuesta:
- Cada vez que se añade o modifica una solicitud de vacaciones, el sistema debe:
1. Recorrer todas las solicitudes de vacaciones anuales en estado "pendiente", en orden de llegada.
2. Aprobar automáticamente tantas como sea posible (según la disponibilidad mínima de empleados).
3. Rechazar el resto si no hay disponibilidad.
4. Regenerar los turnos desde la semana afectada tras cada aprobación/cambio.

Esto se puede hacer justo después de añadir una nueva solicitud o cuando el administrador cambia el estado de alguna.
- Procesa automáticamente todas las solicitudes de vacaciones anuales pendientes cada vez que se añade una nueva solicitud.
- Aprueba en orden de llegada tantas como sea posible según la disponibilidad mínima de empleados.
- Rechaza automáticamente las que no se puedan conceder.
- Regenera los turnos desde la semana afectada tras cada aprobación/cambio.
Esto ocurre de forma inmediata, sin esperas ni intervención manual (excepto si el admin lo desea).

## Propuesta para los turnos de vacaciones
- T1 tiene que permitir un minimo de 2 empleados, esto implica que pueden haber 5 personas de vacaciones en temporada alta o varias personas disfrutando de vacaciones mientras se sigue poder otorgar dias libres por bajas médicas, emergencias o asuntos personales.
- T2 sigue intacto con un minimo de 2 personas.

Esto permite que de los 9 empleados haya aun minimo de 4 personas trabajando en todo momento. 
