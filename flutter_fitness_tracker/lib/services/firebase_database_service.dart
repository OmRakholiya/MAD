import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get _currentUserId => _auth.currentUser?.uid;

  // Create workout
  static Future<Map<String, dynamic>?> createWorkout(
    Map<String, dynamic> workoutData,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log(
          '❌ User not authenticated',
          name: 'FirebaseDatabaseService',
        );
        return null;
      }

      workoutData['userId'] = userId;
      workoutData['createdAt'] = FieldValue.serverTimestamp();
      workoutData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection('workouts').add(workoutData);

      developer.log(
        '✅ Workout created successfully with ID: ${docRef.id}',
        name: 'FirebaseDatabaseService',
      );
      return {'id': docRef.id, 'success': true};
    } catch (e) {
      developer.log(
        '❌ Error creating workout: $e',
        error: e,
        name: 'FirebaseDatabaseService',
      );
      return null;
    }
  }

  // Get user workouts
  static Future<List<Map<String, dynamic>>> getUserWorkouts() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log(
          '❌ User not authenticated',
          name: 'FirebaseDatabaseService',
        );
        return [];
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> workouts = [];
      for (var doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        workouts.add(data);
      }

      developer.log(
        '✅ Retrieved ${workouts.length} workouts',
        name: 'FirebaseDatabaseService',
      );
      return workouts;
    } catch (e) {
      developer.log(
        '❌ Error getting workouts: $e',
        error: e,
        name: 'FirebaseDatabaseService',
      );
      return [];
    }
  }

  // Get workout by ID
  static Future<Map<String, dynamic>?> getWorkoutById(String workoutId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log(
          '❌ User not authenticated',
          name: 'FirebaseDatabaseService',
        );
        return null;
      }

      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('workouts')
          .doc(workoutId)
          .get();

      if (doc.exists) {
        final data = Map<String, dynamic>.from(doc.data() ?? {});
        data['id'] = doc.id;

        // Verify the workout belongs to the current user
        if (data['userId'] == userId) {
          developer.log(
            '✅ Workout retrieved successfully',
            name: 'FirebaseDatabaseService',
          );
          return data;
        } else {
          developer.log(
            '❌ Workout does not belong to current user',
            name: 'FirebaseDatabaseService',
          );
          return null;
        }
      } else {
        developer.log('❌ Workout not found', name: 'FirebaseDatabaseService');
        return null;
      }
    } catch (e) {
      developer.log(
        '❌ Error getting workout: $e',
        error: e,
        name: 'FirebaseDatabaseService',
      );
      return null;
    }
  }

  // Update workout
  static Future<bool> updateWorkout(
    String workoutId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log(
          '❌ User not authenticated',
          name: 'FirebaseDatabaseService',
        );
        return false;
      }

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('workouts').doc(workoutId).update(updateData);

      developer.log(
        '✅ Workout updated successfully',
        name: 'FirebaseDatabaseService',
      );
      return true;
    } catch (e) {
      developer.log(
        '❌ Error updating workout: $e',
        error: e,
        name: 'FirebaseDatabaseService',
      );
      return false;
    }
  }

  // Delete workout
  static Future<bool> deleteWorkout(String workoutId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log(
          '❌ User not authenticated',
          name: 'FirebaseDatabaseService',
        );
        return false;
      }

      await _firestore.collection('workouts').doc(workoutId).delete();

      developer.log(
        '✅ Workout deleted successfully',
        name: 'FirebaseDatabaseService',
      );
      return true;
    } catch (e) {
      developer.log(
        '❌ Error deleting workout: $e',
        error: e,
        name: 'FirebaseDatabaseService',
      );
      return false;
    }
  }

  // Save progress data
  static Future<Map<String, dynamic>?> saveProgress(
    Map<String, dynamic> progressData,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log(
          '❌ User not authenticated',
          name: 'FirebaseDatabaseService',
        );
        return null;
      }

      progressData['userId'] = userId;
      progressData['createdAt'] = FieldValue.serverTimestamp();
      progressData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection('progress').add(progressData);

      developer.log(
        '✅ Progress saved successfully with ID: ${docRef.id}',
        name: 'FirebaseDatabaseService',
      );
      return {'id': docRef.id, 'success': true};
    } catch (e) {
      developer.log(
        '❌ Error saving progress: $e',
        error: e,
        name: 'FirebaseDatabaseService',
      );
      return null;
    }
  }

  // Get user progress data
  static Future<List<Map<String, dynamic>>> getUserProgress() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log(
          '❌ User not authenticated',
          name: 'FirebaseDatabaseService',
        );
        return [];
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> progressList = [];
      for (var doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        progressList.add(data);
      }

      developer.log(
        '✅ Retrieved ${progressList.length} progress entries',
        name: 'FirebaseDatabaseService',
      );
      return progressList;
    } catch (e) {
      developer.log(
        '❌ Error getting progress: $e',
        error: e,
        name: 'FirebaseDatabaseService',
      );
      return [];
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log(
          '❌ User not authenticated',
          name: 'FirebaseDatabaseService',
        );
        return null;
      }

      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data['id'] = doc.id;
        developer.log(
          '✅ User profile retrieved successfully',
          name: 'FirebaseDatabaseService',
        );
        return data;
      } else {
        developer.log(
          '❌ User profile not found',
          name: 'FirebaseDatabaseService',
        );
        return null;
      }
    } catch (e) {
      developer.log(
        '❌ Error getting user profile: $e',
        error: e,
        name: 'FirebaseDatabaseService',
      );
      return null;
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile(Map<String, dynamic> updateData) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log(
          '❌ User not authenticated',
          name: 'FirebaseDatabaseService',
        );
        return false;
      }

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(userId).update(updateData);

      developer.log(
        '✅ User profile updated successfully',
        name: 'FirebaseDatabaseService',
      );
      return true;
    } catch (e) {
      developer.log(
        '❌ Error updating user profile: $e',
        error: e,
        name: 'FirebaseDatabaseService',
      );
      return false;
    }
  }

  // Get workout statistics
  static Future<Map<String, dynamic>> getWorkoutStats() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log(
          '❌ User not authenticated',
          name: 'FirebaseDatabaseService',
        );
        return {};
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .get();

      int totalWorkouts = snapshot.docs.length;
      int totalDuration = 0;
      Map<String, int> exerciseCounts = {};

      for (var doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());

        // Sum up duration
        if (data['duration'] != null) {
          totalDuration += (data['duration'] as num).toInt();
        }

        // Count exercises
        if (data['exercises'] != null) {
          final exercises = data['exercises'] as List;
          for (var exercise in exercises) {
            if (exercise is Map<String, dynamic> && exercise['name'] != null) {
              final exerciseName = exercise['name'] as String;
              exerciseCounts[exerciseName] =
                  (exerciseCounts[exerciseName] ?? 0) + 1;
            }
          }
        }
      }

      final stats = {
        'totalWorkouts': totalWorkouts,
        'totalDuration': totalDuration,
        'exerciseCounts': exerciseCounts,
        'averageWorkoutDuration': totalWorkouts > 0
            ? (totalDuration / totalWorkouts).round()
            : 0,
      };

      developer.log(
        '✅ Workout statistics calculated',
        name: 'FirebaseDatabaseService',
      );
      return stats;
    } catch (e) {
      developer.log(
        '❌ Error getting workout stats: $e',
        error: e,
        name: 'FirebaseDatabaseService',
      );
      return {};
    }
  }

  // Real-time workout stream
  static Stream<List<Map<String, dynamic>>> getUserWorkoutsStream() {
    final userId = _currentUserId;
    if (userId == null) {
      developer.log(
        '❌ User not authenticated',
        name: 'FirebaseDatabaseService',
      );
      return Stream.value([]);
    }

    return _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  // Real-time progress stream
  static Stream<List<Map<String, dynamic>>> getUserProgressStream() {
    final userId = _currentUserId;
    if (userId == null) {
      developer.log(
        '❌ User not authenticated',
        name: 'FirebaseDatabaseService',
      );
      return Stream.value([]);
    }

    return _firestore
        .collection('progress')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }
}
