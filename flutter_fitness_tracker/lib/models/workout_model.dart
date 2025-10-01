class WorkoutSession {
  final DateTime startAt;
  final DateTime? endAt;

  const WorkoutSession({
    required this.startAt,
    this.endAt,
  });

  Duration? get duration {
    if (endAt == null) return null;
    return endAt!.difference(startAt);
  }

  bool get isActive => endAt == null;

  Map<String, dynamic> toMap() {
    return {
      'startAt': startAt.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      startAt: DateTime.parse(map['startAt']),
      endAt: map['endAt'] != null ? DateTime.parse(map['endAt']) : null,
    );
  }
}

class WorkoutModel {
  final String id;
  final String name;
  final String type; // cardio, strength, yoga, hiit, custom
  final int? durationMinutes; // optional if using reps
  final String? repsScheme; // e.g., "3 x 12"
  final int calories;
  final DateTime date;
  final String intensity; // easy, moderate, hard
  final bool completed;
  final List<String> tags;
  final List<WorkoutSession> sessions; // multiple start/end sessions
  
  // Legacy fields for backward compatibility
  final DateTime? startAt; // when workout started
  final DateTime? endAt; // when workout ended

  const WorkoutModel({
    required this.id,
    required this.name,
    required this.type,
    required this.calories,
    required this.date,
    this.durationMinutes,
    this.repsScheme,
    this.intensity = 'moderate',
    this.completed = false,
    this.tags = const [],
    this.sessions = const [],
    this.startAt,
    this.endAt,
  });

  bool get isCardio => type.toLowerCase() == 'cardio';
  bool get isStrength => type.toLowerCase() == 'strength';

  String get primaryDisplayDetail {
    if (durationMinutes != null && durationMinutes! > 0) {
      return '$durationMinutes min';
    }
    if (repsScheme != null && repsScheme!.isNotEmpty) {
      return repsScheme!;
    }
    return '—';
  }

  // Check if there's an active session
  bool get hasActiveSession {
    return sessions.any((session) => session.isActive);
  }

  // Get the current active session if any
  WorkoutSession? get activeSession {
    try {
      return sessions.firstWhere((session) => session.isActive);
    } catch (e) {
      return null;
    }
  }

  // Get cumulative duration from all completed sessions
  Duration get cumulativeDuration {
    Duration total = Duration.zero;
    for (final session in sessions) {
      if (session.duration != null) {
        total += session.duration!;
      }
    }
    return total;
  }

  // Get total elapsed duration including active session
  Duration? get elapsedDuration {
    Duration total = cumulativeDuration;
    
    // Add current active session time if any
    final active = activeSession;
    if (active != null) {
      total += DateTime.now().difference(active.startAt);
    }
    
    // Fallback to legacy fields for backward compatibility
    if (total == Duration.zero && startAt != null) {
      final end = endAt ?? DateTime.now();
      if (!end.isBefore(startAt!)) {
        total = end.difference(startAt!);
      }
    }
    
    return total == Duration.zero ? null : total;
  }

  // Get the last session duration
  Duration? get lastSessionDuration {
    if (sessions.isEmpty) return null;
    
    // If there's an active session, return its current duration
    final active = activeSession;
    if (active != null) {
      return DateTime.now().difference(active.startAt);
    }
    
    // Otherwise return the last completed session
    final completedSessions = sessions.where((s) => s.duration != null).toList();
    if (completedSessions.isEmpty) return null;
    
    return completedSessions.last.duration;
  }

  String? get elapsedDisplay {
    final d = elapsedDuration;
    if (d == null) return null;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
    }
    return '${seconds}s';
  }

  String? get lastSessionDisplay {
    final d = lastSessionDuration;
    if (d == null) return null;
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  WorkoutModel copyWith({
    String? id,
    String? name,
    String? type,
    int? durationMinutes,
    String? repsScheme,
    int? calories,
    DateTime? date,
    String? intensity,
    bool? completed,
    List<String>? tags,
    List<WorkoutSession>? sessions,
    DateTime? startAt,
    DateTime? endAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      repsScheme: repsScheme ?? this.repsScheme,
      calories: calories ?? this.calories,
      date: date ?? this.date,
      intensity: intensity ?? this.intensity,
      completed: completed ?? this.completed,
      tags: tags ?? this.tags,
      sessions: sessions ?? this.sessions,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
    );
  }

  // Helper methods for session management
  WorkoutModel startNewSession() {
    final newSession = WorkoutSession(startAt: DateTime.now());
    final updatedSessions = List<WorkoutSession>.from(sessions)..add(newSession);
    return copyWith(sessions: updatedSessions);
  }

  WorkoutModel endCurrentSession() {
    if (!hasActiveSession) return this;
    
    final updatedSessions = sessions.map((session) {
      if (session.isActive) {
        return WorkoutSession(
          startAt: session.startAt,
          endAt: DateTime.now(),
        );
      }
      return session;
    }).toList();
    
    return copyWith(sessions: updatedSessions);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'durationMinutes': durationMinutes,
      'repsScheme': repsScheme,
      'calories': calories,
      'date': date.toIso8601String(),
      'intensity': intensity,
      'completed': completed,
      'tags': tags,
      'sessions': sessions.map((session) => session.toMap()).toList(),
      'startAt': startAt?.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    // ignore: no_leading_underscores_for_local_identifiers
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      try {
        // Support Firestore Timestamp or ISO String
        if (v is DateTime) return v;
        final dynamicValue = v;
        if (dynamicValue is String) return DateTime.tryParse(dynamicValue);
        final ts = dynamicValue;
        // Timestamp type check by duck-typing to avoid importing Firestore here
        if (ts is Map || ts is Object) {
          // not reliably parsable without type; fall back
        }
      } catch (_) {}
      return null;
    }
    // Parse sessions
    List<WorkoutSession> parsedSessions = [];
    if (map['sessions'] != null && map['sessions'] is List) {
      parsedSessions = (map['sessions'] as List)
          .map((sessionMap) => WorkoutSession.fromMap(sessionMap as Map<String, dynamic>))
          .toList();
    }

    return WorkoutModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'custom',
      durationMinutes: map['durationMinutes'],
      repsScheme: map['repsScheme'],
      calories: (map['calories'] ?? 0).toInt(),
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      intensity: map['intensity'] ?? 'moderate',
      completed: map['completed'] ?? false,
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      sessions: parsedSessions,
      startAt: _parseDate(map['startAt']) ?? (map['startAt'] is String
          ? DateTime.tryParse(map['startAt'])
          : null),
      endAt: _parseDate(map['endAt']) ?? (map['endAt'] is String
          ? DateTime.tryParse(map['endAt'])
          : null),
    );
  }
}
