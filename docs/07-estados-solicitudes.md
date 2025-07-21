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
