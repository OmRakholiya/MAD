class ExercisePlan {
  final String id;
  final String name;
  final String description;
  final String level; // beginner, intermediate, advanced
  final String category; // strength, cardio, yoga, hiit, full_body
  final int durationWeeks;
  final int workoutsPerWeek;
  final List<ExerciseDay> exercises;
  final String imageUrl; // Main cover image
  final List<String> galleryImages; // Additional images
  final List<String> videoUrls; // Instructional videos
  final String? thumbnailUrl; // Video thumbnail
  final List<String> benefits;
  final List<String> equipment;
  final int estimatedCaloriesPerSession;

  const ExercisePlan({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.category,
    required this.durationWeeks,
    required this.workoutsPerWeek,
    required this.exercises,
    this.imageUrl = '',
    this.galleryImages = const [],
    this.videoUrls = const [],
    this.thumbnailUrl,
    this.benefits = const [],
    this.equipment = const [],
    this.estimatedCaloriesPerSession = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level': level,
      'category': category,
      'durationWeeks': durationWeeks,
      'workoutsPerWeek': workoutsPerWeek,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'imageUrl': imageUrl,
      'galleryImages': galleryImages,
      'videoUrls': videoUrls,
      'thumbnailUrl': thumbnailUrl,
      'benefits': benefits,
      'equipment': equipment,
      'estimatedCaloriesPerSession': estimatedCaloriesPerSession,
    };
  }

  factory ExercisePlan.fromMap(Map<String, dynamic> map) {
    return ExercisePlan(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      level: map['level'] ?? 'beginner',
      category: map['category'] ?? 'full_body',
      durationWeeks: (map['durationWeeks'] ?? 4).toInt(),
      workoutsPerWeek: (map['workoutsPerWeek'] ?? 3).toInt(),
      exercises: (map['exercises'] as List?)
              ?.map((e) => ExerciseDay.fromMap(e))
              .toList() ??
          const [],
      imageUrl: map['imageUrl'] ?? '',
      galleryImages: (map['galleryImages'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      videoUrls: (map['videoUrls'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      thumbnailUrl: map['thumbnailUrl'],
      benefits: (map['benefits'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      equipment: (map['equipment'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      estimatedCaloriesPerSession: (map['estimatedCaloriesPerSession'] ?? 0).toInt(),
    );
  }
}

class ExerciseDay {
  final int dayNumber;
  final String title;
  final List<Exercise> exercises;
  final int estimatedDurationMinutes;

  const ExerciseDay({
    required this.dayNumber,
    required this.title,
    required this.exercises,
    this.estimatedDurationMinutes = 30,
  });

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'title': title,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'estimatedDurationMinutes': estimatedDurationMinutes,
    };
  }

  factory ExerciseDay.fromMap(Map<String, dynamic> map) {
    return ExerciseDay(
      dayNumber: (map['dayNumber'] ?? 1).toInt(),
      title: map['title'] ?? '',
      exercises: (map['exercises'] as List?)
              ?.map((e) => Exercise.fromMap(e))
              .toList() ??
          const [],
      estimatedDurationMinutes: (map['estimatedDurationMinutes'] ?? 30).toInt(),
    );
  }
}

class Exercise {
  final String name;
  final String description;
  final String type; // cardio, strength, flexibility
  final int? sets;
  final int? reps;
  final int? durationSeconds;
  final int? restSeconds;
  final String difficulty; // easy, moderate, hard
  final String? instructions;
  final String? imageUrl; // Exercise demonstration image
  final String? videoUrl; // Exercise demonstration video
  final String? gifUrl; // Animated GIF demonstration

  const Exercise({
    required this.name,
    required this.description,
    required this.type,
    this.sets,
    this.reps,
    this.durationSeconds,
    this.restSeconds,
    this.difficulty = 'moderate',
    this.instructions,
    this.imageUrl,
    this.videoUrl,
    this.gifUrl,
  });

  String get displayDetail {
    if (sets != null && reps != null) {
      return '$sets x $reps';
    }
    if (durationSeconds != null) {
      final minutes = durationSeconds! ~/ 60;
      final seconds = durationSeconds! % 60;
      if (minutes > 0) {
        return '${minutes}m ${seconds}s';
      }
      return '${seconds}s';
    }
    return '';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'sets': sets,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'restSeconds': restSeconds,
      'difficulty': difficulty,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'gifUrl': gifUrl,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'strength',
      sets: map['sets'],
      reps: map['reps'],
      durationSeconds: map['durationSeconds'],
      restSeconds: map['restSeconds'],
      difficulty: map['difficulty'] ?? 'moderate',
      instructions: map['instructions'],
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      gifUrl: map['gifUrl'],
    );
  }
}
