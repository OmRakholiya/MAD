import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SimpleAuthService {
  static const String _userKey = 'current_user';

  // Register new user (mock implementation)
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      developer.log(
        '=== SIMPLE REGISTRATION STARTED ===',
        name: 'SimpleAuthService',
      );
      developer.log('Email: $email', name: 'SimpleAuthService');

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Create user data
      final userData = {
        'uid': 'mock_${DateTime.now().millisecondsSinceEpoch}',
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.toLowerCase().trim(),
        'displayName': '${firstName.trim()} ${lastName.trim()}',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'profilePicture': '',
        'fitnessGoals': [],
        'isActive': true,
      };

      // Save user data locally
      await _saveUserLocally(userData);

      developer.log(
        '✅ Registration completed successfully',
        name: 'SimpleAuthService',
      );
      return {
        'success': true,
        'message': 'Account created successfully! Welcome to FitTracker!',
        'user': userData,
      };
    } catch (e) {
      developer.log(
        '❌ Registration error: $e',
        error: e,
        name: 'SimpleAuthService',
      );
      return {
        'success': false,
        'error': 'unknown_error',
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Login user (mock implementation)
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      developer.log(
        '🔐 Simple login attempt for: $email',
        name: 'SimpleAuthService',
      );

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock user data
      final userData = {
        'uid': 'mock_user_123',
        'firstName': 'John',
        'lastName': 'Doe',
        'email': email.toLowerCase().trim(),
        'displayName': 'John Doe',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'profilePicture': '',
        'fitnessGoals': [],
        'isActive': true,
      };

      await _saveUserLocally(userData);

      developer.log(
        '✅ Login completed successfully',
        name: 'SimpleAuthService',
      );
      return {
        'success': true,
        'message': 'Login successful!',
        'user': userData,
      };
    } catch (e) {
      developer.log('❌ Login error: $e', error: e, name: 'SimpleAuthService');
      return {
        'success': false,
        'error': 'unknown_error',
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      developer.log(
        '👋 User logged out successfully',
        name: 'SimpleAuthService',
      );
    } catch (e) {
      developer.log('❌ Logout error: $e', error: e, name: 'SimpleAuthService');
    }
  }

  // Get current user from local storage
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Save user data locally
  static Future<void> _saveUserLocally(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
    developer.log('💾 User data saved locally', name: 'SimpleAuthService');
  }

  // Send password reset email (mock implementation)
  static Future<Map<String, dynamic>> sendPasswordResetEmail(
    String email,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      developer.log('✅ Password reset email sent', name: 'SimpleAuthService');
      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.',
      };
    } catch (e) {
      developer.log(
        '❌ Password reset error: $e',
        error: e,
        name: 'SimpleAuthService',
      );
      return {
        'success': false,
        'error': 'unknown_error',
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }
}

