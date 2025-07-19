# ShiftSense - Architecture Plan

## Overview
ShiftSense is a modern Flutter application for managing shifts and vacations for a 9-person team with rotating schedules (T1: 7 people, T2: 2 people) and a weekly rotating Captain role in T2.

## Core Features
1. **Current Week View** - Display current shift assignments with Captain identification
2. **Vacation Management** - Request and view vacation schedules
3. **Annual Overview** - Year-long view of shifts, captains, and vacation distribution
4. **Employee Management** - View employee profiles and statistics

## Technical Architecture

### Data Models
1. **Employee Model** - id, name, position, avatar, statistics
2. **Vacation Model** - employeeId, startDate, endDate, status, type
3. **WeeklyShift Model** - weekStart, t1Members, t2Members, captainId
4. **ShiftStats Model** - rotation metrics and fairness calculations

### Screen Structure
1. **HomePage** - Bottom navigation with 4 tabs
2. **CurrentShiftScreen** - Weekly view with navigation arrows
3. **VacationScreen** - Calendar view + vacation request form
4. **AnnualOverviewScreen** - Year grid with employee statistics
5. **EmployeesScreen** - Team member profiles and metrics

### Business Logic Services
1. **ShiftService** - Handles rotation logic and captain assignment
2. **VacationService** - Manages vacation requests and validation
3. **DataService** - Local storage with shared_preferences
4. **StatsService** - Calculates fairness metrics and statistics

### Key Features
- Automatic shift rotation with 9-person cycle
- Smart captain rotation ensuring fairness
- Vacation conflict detection
- Visual indicators for shift types and captain role
- Statistical analysis of rotation fairness
- Modern Material Design 3 UI with animations

## Implementation Steps
1. Set up data models and services
2. Implement core business logic for shift rotation
3. Create navigation structure with bottom tabs
4. Build current shift view with week navigation
5. Implement vacation management system
6. Create annual overview with statistical analysis
7. Add employee profiles and metrics
8. Apply modern UI design with animations
9. Test and validate rotation algorithms
10. Compile and fix any issues

## File Structure (10 files total)
- models/employee.dart (data models)
- services/shift_service.dart (rotation logic)
- services/data_service.dart (local storage)
- screens/home_page.dart (main navigation)
- screens/current_shift_screen.dart (weekly view)
- screens/vacation_screen.dart (vacation management)
- screens/annual_overview_screen.dart (yearly statistics)
- screens/employees_screen.dart (team profiles)
- widgets/shift_card.dart (reusable components)
- main.dart (updated with navigation)

This architecture ensures a maintainable, scalable solution that meets all Nayar Systems requirements while providing an excellent user experience.