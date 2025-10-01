class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final double heightCm;
  final double weightKg;
  final String gender; // male, female, other
  final String activityLevel; // sedentary, light, moderate, active, very_active
  final int dailyStepsTarget;
  final int dailyCaloriesTarget;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.heightCm,
    required this.weightKg,
    this.dateOfBirth,
    this.gender = 'other',
    this.activityLevel = 'moderate',
    this.dailyStepsTarget = 8000,
    this.dailyCaloriesTarget = 2200,
  });

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  double get bmi {
    if (heightCm <= 0 || weightKg <= 0) return 0;
    final heightMeters = heightCm / 100.0;
    return weightKg / (heightMeters * heightMeters);
  }

  String get bmiCategory {
    final value = bmi;
    if (value == 0) return 'Unknown';
    if (value < 18.5) return 'Underweight';
    if (value < 24.9) return 'Normal';
    if (value < 29.9) return 'Overweight';
    return 'Obese';
  }

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int years = now.year - dateOfBirth!.year;
    final hadBirthday = (now.month > dateOfBirth!.month) ||
        (now.month == dateOfBirth!.month && now.day >= dateOfBirth!.day);
    return hadBirthday ? years : years - 1;
  }

  // Mifflin-St Jeor BMR estimate
  double get bmr {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    if (gender.toLowerCase() == 'male') return base + 5;
    if (gender.toLowerCase() == 'female') return base - 161;
    return base - 80; // neutral adjustment
  }

  double get maintenanceCalories {
    final level = activityLevel.toLowerCase();
    double factor = 1.55; // moderate
    // ignore: curly_braces_in_flow_control_structures
    if (level == 'sedentary') factor = 1.2;
    // ignore: curly_braces_in_flow_control_structures
    else if (level == 'light') factor = 1.375;
    // ignore: curly_braces_in_flow_control_structures
    else if (level == 'active') factor = 1.725;
    // ignore: curly_braces_in_flow_control_structures
    else if (level == 'very_active') factor = 1.9;
    return bmr * factor;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
    String? gender,
    String? activityLevel,
    int? dailyStepsTarget,
    int? dailyCaloriesTarget,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      dailyStepsTarget: dailyStepsTarget ?? this.dailyStepsTarget,
      dailyCaloriesTarget: dailyCaloriesTarget ?? this.dailyCaloriesTarget,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'heightCm': heightCm,
      'weightKg': weightKg,
      'gender': gender,
      'activityLevel': activityLevel,
      'dailyStepsTarget': dailyStepsTarget,
      'dailyCaloriesTarget': dailyCaloriesTarget,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      dateOfBirth: _parseDate(map['dateOfBirth']),
      heightCm: (map['heightCm'] ?? 0).toDouble(),
      weightKg: (map['weightKg'] ?? 0).toDouble(),
      gender: map['gender'] ?? 'other',
      activityLevel: map['activityLevel'] ?? 'moderate',
      dailyStepsTarget: map['dailyStepsTarget'] ?? 8000,
      dailyCaloriesTarget: map['dailyCaloriesTarget'] ?? 2200,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
