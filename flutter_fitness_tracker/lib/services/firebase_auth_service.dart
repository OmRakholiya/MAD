import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _userKey = 'current_user';

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ===========================
  // REGISTER USER
  // ===========================
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      developer.log(
        '=== FIREBASE REGISTRATION STARTED ===',
        name: 'FirebaseAuthService',
      );
      developer.log('Email: $email', name: 'FirebaseAuthService');

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.toLowerCase().trim(),
            password: password,
          );

      final User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName('$firstName $lastName');

        final userDataForFirestore = {
          'uid': user.uid,
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'email': email.toLowerCase().trim(),
          'displayName': '$firstName $lastName',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'profilePicture': '',
          'fitnessGoals': [],
          'isActive': true,
        };

        // Write to Firestore with server timestamps
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userDataForFirestore);

        // Save a JSON-safe copy locally (replace server timestamps with DateTime strings)
        final userDataForLocal = {
          ...userDataForFirestore,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        await _saveUserLocally(_jsonSafe(userDataForLocal));

        return {
          'success': true,
          'message': 'Account created successfully! Welcome to FitTracker!',
          'user': userDataForLocal,
        };
      }
      return {
        'success': false,
        'error': 'firebase_error',
        'message': 'Failed to create account. Please try again.',
      };
    } on FirebaseAuthException catch (e) {
      developer.log(
        '❌ Firebase Auth error: ${e.code}',
        name: 'FirebaseAuthService',
      );

      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = e.message ?? 'An unknown Firebase error occurred.';
      }

      return {'success': false, 'error': e.code, 'message': message};
    } catch (e, stack) {
      developer.log(
        '❌ Registration error',
        error: e,
        stackTrace: stack,
        name: 'FirebaseAuthService',
      );
      return {
        'success': false,
        'error': 'unknown_error',
        'message': e.toString(),
      };
    }
  }

  // ===========================
  // LOGIN USER
  // ===========================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      developer.log(
        '🔐 Firebase login attempt for: $email',
        name: 'FirebaseAuthService',
      );

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: email.toLowerCase().trim(),
            password: password,
          );

      final User? user = userCredential.user;
      if (user != null) {
        final DocumentReference userRef = _firestore
            .collection('users')
            .doc(user.uid);
        DocumentSnapshot userDoc = await userRef.get();

        if (!userDoc.exists) {
          final display = user.displayName ?? '';
          final parts = display.trim().split(' ');
          final first = parts.isNotEmpty ? parts.first : '';
          final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';

          final minimal = {
            'uid': user.uid,
            'firstName': first,
            'lastName': last,
            'email': user.email ?? email.toLowerCase().trim(),
            'displayName': display,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'profilePicture': '',
            'fitnessGoals': [],
            'isActive': true,
          };
          await userRef.set(minimal);
          userDoc = await userRef.get();
        }

        final userData = userDoc.data() as Map<String, dynamic>;
        await _saveUserLocally(_jsonSafe(userData));

        return {
          'success': true,
          'message': 'Login successful!',
          'user': _jsonSafe(userData),
        };
      }
      return {
        'success': false,
        'error': 'login_failed',
        'message': 'Login failed. Please try again.',
      };
    } on FirebaseAuthException catch (e) {
      developer.log(
        '❌ Firebase Auth error: ${e.code}',
        name: 'FirebaseAuthService',
      );

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Try again later.';
          break;
        default:
          message = e.message ?? 'Login failed due to Firebase error.';
      }

      return {'success': false, 'error': e.code, 'message': message};
    } catch (e, stack) {
      developer.log(
        '❌ Login error',
        error: e,
        stackTrace: stack,
        name: 'FirebaseAuthService',
      );
      return {
        'success': false,
        'error': 'unknown_error',
        'message': e.toString(),
      };
    }
  }

  // ===========================
  // LOGOUT
  // ===========================
  static Future<void> logout() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      developer.log(
        '👋 User logged out successfully',
        name: 'FirebaseAuthService',
      );
    } catch (e, stack) {
      developer.log(
        '❌ Logout error',
        error: e,
        stackTrace: stack,
        name: 'FirebaseAuthService',
      );
    }
  }

  // ===========================
  // PASSWORD RESET
  // ===========================
  static Future<Map<String, dynamic>> sendPasswordResetEmail(
    String email,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.toLowerCase().trim());
      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      developer.log(
        '❌ Password reset error: ${e.code}',
        name: 'FirebaseAuthService',
      );

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = e.message ?? 'Password reset failed.';
      }

      return {'success': false, 'error': e.code, 'message': message};
    } catch (e, stack) {
      developer.log(
        '❌ Password reset error',
        error: e,
        stackTrace: stack,
        name: 'FirebaseAuthService',
      );
      return {
        'success': false,
        'error': 'unknown_error',
        'message': e.toString(),
      };
    }
  }

  // ===========================
  // UPDATE PROFILE
  // ===========================
  static Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? profilePicture,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return {
          'success': false,
          'error': 'not_authenticated',
          'message': 'User not authenticated',
        };
      }

      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (profilePicture != null) updateData['profilePicture'] = profilePicture;

      if (firstName != null && lastName != null) {
        updateData['displayName'] = '$firstName $lastName';
        await user.updateDisplayName('$firstName $lastName');
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);

      final currentUserData = await getCurrentUser();
      if (currentUserData != null) {
        final localMerge = {
          ...currentUserData,
          'updatedAt': DateTime.now().toIso8601String(),
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (profilePicture != null) 'profilePicture': profilePicture,
          if (firstName != null && lastName != null)
            'displayName': '$firstName $lastName',
        };
        await _saveUserLocally(_jsonSafe(localMerge));
      }

      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e, stack) {
      developer.log(
        '❌ Profile update error',
        error: e,
        stackTrace: stack,
        name: 'FirebaseAuthService',
      );
      return {
        'success': false,
        'error': 'update_failed',
        'message': e.toString(),
      };
    }
  }

  // ===========================
  // LOCAL STORAGE HELPERS
  // ===========================
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    // Only consider logged in if Firebase has a current user
    final user = currentUser;
    if (user == null) return false;
    // Backfill local cache (best effort)
    try {
      final snap = await _firestore.collection('users').doc(user.uid).get();
      if (snap.exists) {
        await _saveUserLocally(
          _jsonSafe(snap.data() as Map<String, dynamic>),
        );
      }
    } catch (_) {
      // ignore cache backfill errors
    }
    return true;
  }

  static Future<void> _saveUserLocally(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
    developer.log('💾 User data saved locally', name: 'FirebaseAuthService');
  }

  // Convert any Firestore Timestamp values to ISO8601 strings (and handle nested maps/lists)
  static dynamic _jsonSafe(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _jsonSafe(v)));
    }
    if (value is Iterable) {
      return value.map(_jsonSafe).toList();
    }
    return value;
  }
}
