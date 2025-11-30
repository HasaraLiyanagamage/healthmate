class UserProfile {
  final int? id;
  final String name;
  final int age;
  final String gender; // 'male', 'female', 'other'
  final double height; // in cm
  final double weight; // in kg
  final int dailyStepsGoal;
  final double dailyWaterGoal; // in liters
  final double dailyCaloriesGoal;
  final String activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    this.dailyStepsGoal = 10000,
    this.dailyWaterGoal = 2.5,
    this.dailyCaloriesGoal = 2000,
    this.activityLevel = 'moderate',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Calculate BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // Get BMI category
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Get BMI color
  String get bmiColor {
    if (bmi < 18.5) return '#4DD0E1';
    if (bmi < 25) return '#66BB6A';
    if (bmi < 30) return '#FFA726';
    return '#EF5350';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'dailyStepsGoal': dailyStepsGoal,
      'dailyWaterGoal': dailyWaterGoal,
      'dailyCaloriesGoal': dailyCaloriesGoal,
      'activityLevel': activityLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      height: (map['height'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
      dailyStepsGoal: map['dailyStepsGoal'] as int? ?? 10000,
      dailyWaterGoal: (map['dailyWaterGoal'] as num?)?.toDouble() ?? 2.5,
      dailyCaloriesGoal: (map['dailyCaloriesGoal'] as num?)?.toDouble() ?? 2000,
      activityLevel: map['activityLevel'] as String? ?? 'moderate',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  UserProfile copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    int? dailyStepsGoal,
    double? dailyWaterGoal,
    double? dailyCaloriesGoal,
    String? activityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      dailyStepsGoal: dailyStepsGoal ?? this.dailyStepsGoal,
      dailyWaterGoal: dailyWaterGoal ?? this.dailyWaterGoal,
      dailyCaloriesGoal: dailyCaloriesGoal ?? this.dailyCaloriesGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
