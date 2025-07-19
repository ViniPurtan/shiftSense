class Employee {
  final String id;
  final String name;
  final String position;
  final String avatar;
  final int totalWeeksAsT1;
  final int totalWeeksAsT2;
  final int totalWeeksAsCaptain;

  const Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.avatar,
    this.totalWeeksAsT1 = 0,
    this.totalWeeksAsT2 = 0,
    this.totalWeeksAsCaptain = 0,
  });

  Employee copyWith({
    String? name,
    String? position,
    String? avatar,
    int? totalWeeksAsT1,
    int? totalWeeksAsT2,
    int? totalWeeksAsCaptain,
  }) => Employee(
    id: id,
    name: name ?? this.name,
    position: position ?? this.position,
    avatar: avatar ?? this.avatar,
    totalWeeksAsT1: totalWeeksAsT1 ?? this.totalWeeksAsT1,
    totalWeeksAsT2: totalWeeksAsT2 ?? this.totalWeeksAsT2,
    totalWeeksAsCaptain: totalWeeksAsCaptain ?? this.totalWeeksAsCaptain,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': position,
    'avatar': avatar,
    'totalWeeksAsT1': totalWeeksAsT1,
    'totalWeeksAsT2': totalWeeksAsT2,
    'totalWeeksAsCaptain': totalWeeksAsCaptain,
  };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json['id'],
    name: json['name'],
    position: json['position'],
    avatar: json['avatar'],
    totalWeeksAsT1: json['totalWeeksAsT1'] ?? 0,
    totalWeeksAsT2: json['totalWeeksAsT2'] ?? 0,
    totalWeeksAsCaptain: json['totalWeeksAsCaptain'] ?? 0,
  );

  double get captainPercentage {
    if (totalWeeksAsT2 == 0) return 0;
    return (totalWeeksAsCaptain / totalWeeksAsT2) * 100;
  }

  double get t2Percentage {
    final totalWeeks = totalWeeksAsT1 + totalWeeksAsT2;
    if (totalWeeks == 0) return 0;
    return (totalWeeksAsT2 / totalWeeks) * 100;
  }
}

enum VacationStatus { pending, approved, rejected }

enum VacationType { annual, sick, personal, emergency }

class Vacation {
  final String id;
  final String employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final VacationType type;
  final VacationStatus status;
  final String? notes;
  final DateTime requestDate;

  const Vacation({
    required this.id,
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.status = VacationStatus.pending,
    this.notes,
    required this.requestDate,
  });

  int get durationInDays => endDate.difference(startDate).inDays + 1;

  bool isActiveOn(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
           date.isBefore(endDate.add(const Duration(days: 1)));
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': employeeId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'type': type.name,
    'status': status.name,
    'notes': notes,
    'requestDate': requestDate.toIso8601String(),
  };

  factory Vacation.fromJson(Map<String, dynamic> json) => Vacation(
    id: json['id'],
    employeeId: json['employeeId'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    type: VacationType.values.byName(json['type']),
    status: VacationStatus.values.byName(json['status']),
    notes: json['notes'],
    requestDate: DateTime.parse(json['requestDate']),
  );
}

class WeeklyShift {
  final DateTime weekStart;
  final List<String> t1Members;
  final List<String> t2Members;
  final String captainId;

  const WeeklyShift({
    required this.weekStart,
    required this.t1Members,
    required this.t2Members,
    required this.captainId,
  });

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  Map<String, dynamic> toJson() => {
    'weekStart': weekStart.toIso8601String(),
    't1Members': t1Members,
    't2Members': t2Members,
    'captainId': captainId,
  };

  factory WeeklyShift.fromJson(Map<String, dynamic> json) => WeeklyShift(
    weekStart: DateTime.parse(json['weekStart']),
    t1Members: List<String>.from(json['t1Members']),
    t2Members: List<String>.from(json['t2Members']),
    captainId: json['captainId'],
  );
}