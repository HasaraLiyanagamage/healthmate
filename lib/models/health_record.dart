class HealthRecord {
  final int? id;
  final DateTime date;
  final int steps;
  final double calories;
  final double waterIntake; // in liters

  HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.waterIntake,
  });

  // Convert a HealthRecord into a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'steps': steps,
      'calories': calories,
      'waterIntake': waterIntake,
    };
  }

  // Create a HealthRecord from a Map
  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      steps: map['steps'] as int,
      calories: (map['calories'] as num).toDouble(),
      waterIntake: (map['waterIntake'] as num).toDouble(),
    );
  }

  // Create a copy with updated fields
  HealthRecord copyWith({
    int? id,
    DateTime? date,
    int? steps,
    double? calories,
    double? waterIntake,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      waterIntake: waterIntake ?? this.waterIntake,
    );
  }
}
