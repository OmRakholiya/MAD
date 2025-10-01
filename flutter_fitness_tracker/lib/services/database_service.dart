import 'package:mongo_dart/mongo_dart.dart';
import 'dart:developer' as developer;

class DatabaseService {
  static late Db _db;
  static late DbCollection _usersCollection;
  static late DbCollection _workoutsCollection;
  static late DbCollection _progressCollection;

  // Replace with your actual MongoDB Atlas connection string
  static const String _connectionString =
      'mongodb+srv://fittracker_user:503eTKFPjXD2p1yp@cluster0.xw1uhil.mongodb.net/fitness_tracker?retryWrites=true&w=majority&appName=Cluster0';

  // Initialize database connection
  static Future<bool> connect() async {
    try {
      _db = Db(_connectionString);
      await _db.open();

      _usersCollection = _db.collection('users');
      _workoutsCollection = _db.collection('workouts');
      _progressCollection = _db.collection('progress');

      developer.log(
        '✅ Connected to MongoDB Atlas: fitness_tracker',
        name: 'DatabaseService',
      );
      return true;
    } catch (e) {
      developer.log(
        '❌ MongoDB Atlas connection failed',
        error: e,
        name: 'DatabaseService',
      );
      return false;
    }
  }

  // Create user
  static Future<Map<String, dynamic>?> createUser(
    Map<String, dynamic> userData,
  ) async {
    try {
      final result = await _usersCollection.insertOne(userData);
      if (result.isSuccess) {
        developer.log('User created successfully', name: 'DatabaseService');
        return {'insertedId': result.id.toString()};
      }
      return null;
    } catch (e) {
      developer.log('Error creating user', error: e, name: 'DatabaseService');
      return null;
    }
  }

  // Find user by email
  static Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    try {
      developer.log('🔍 Searching for user: $email', name: 'DatabaseService');

      final user = await _usersCollection.findOne(where.eq('email', email));

      if (user != null) {
        developer.log('✅ User found: $email', name: 'DatabaseService');
        return user;
      } else {
        developer.log('ℹ️ User NOT found: $email', name: 'DatabaseService');
        return null; // Explicitly return null when no user found
      }
    } catch (e) {
      developer.log('❌ Error finding user', error: e, name: 'DatabaseService');
      // Return null on error, don't treat as "user exists"
      return null;
    }
  }

  // Create workout
  static Future<Map<String, dynamic>?> createWorkout(
    Map<String, dynamic> workoutData,
  ) async {
    try {
      workoutData['createdAt'] = DateTime.now().toIso8601String();
      final result = await _workoutsCollection.insertOne(workoutData);
      if (result.isSuccess) {
        developer.log('Workout created successfully', name: 'DatabaseService');
        return {'insertedId': result.id.toString()};
      }
      return null;
    } catch (e) {
      developer.log(
        'Error creating workout',
        error: e,
        name: 'DatabaseService',
      );
      return null;
    }
  }

  // Get user workouts
  static Future<List<Map<String, dynamic>>> getUserWorkouts(
    String userId,
  ) async {
    try {
      final workouts = await _workoutsCollection
          .find(where.eq('userId', userId))
          .toList();
      developer.log(
        'Retrieved ${workouts.length} workouts',
        name: 'DatabaseService',
      );
      return workouts;
    } catch (e) {
      developer.log(
        'Error getting workouts',
        error: e,
        name: 'DatabaseService',
      );
      return [];
    }
  }

  // Save progress data
  static Future<Map<String, dynamic>?> saveProgress(
    Map<String, dynamic> progressData,
  ) async {
    try {
      progressData['createdAt'] = DateTime.now().toIso8601String();
      final result = await _progressCollection.insertOne(progressData);
      if (result.isSuccess) {
        developer.log('Progress saved successfully', name: 'DatabaseService');
        return {'insertedId': result.id.toString()};
      }
      return null;
    } catch (e) {
      developer.log('Error saving progress', error: e, name: 'DatabaseService');
      return null;
    }
  }

  // Close database connection
  static Future<void> close() async {
    await _db.close();
    developer.log('Database connection closed', name: 'DatabaseService');
  }

  // Test connection
  static Future<void> testConnection() async {
    try {
      final testData = {
        'name': 'Test User',
        'email': 'test@example.com',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final result = await createUser(testData);
      if (result != null) {
        developer.log(
          '✅ MongoDB Atlas connection test successful!',
          name: 'DatabaseService',
        );
        // Clean up test data
        await _usersCollection.deleteOne(where.eq('email', 'test@example.com'));
      } else {
        developer.log(
          '❌ MongoDB Atlas connection test failed',
          name: 'DatabaseService',
        );
      }
    } catch (e) {
      developer.log(
        '❌ MongoDB Atlas connection test error',
        error: e,
        name: 'DatabaseService',
      );
    }
  }
}
