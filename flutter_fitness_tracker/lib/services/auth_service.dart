import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register new user
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      // Update display name in Firebase Auth
      await credential.user!.updateDisplayName('$firstName $lastName');

      // 🔹 Save user profile in Firestore
      final userDoc = _firestore.collection('users').doc(credential.user!.uid);
      await userDoc.set({
        'uid': credential.user!.uid,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': normalizedEmail,
        'displayName': '${firstName.trim()} ${lastName.trim()}',
        'profilePicture': '',
        'fitnessGoals': [],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Account created successfully!',
        'firebaseUser': credential.user,
      };
    } on FirebaseAuthException catch (e) {
      developer.log('FirebaseAuthException: ${e.code} - ${e.message}');
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already in use.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message = 'Operation not allowed. Please contact support.';
          break;
        case 'weak-password':
          message = 'Password is too weak.';
          break;
        default:
          message = e.message ?? 'Registration failed. Please try again.';
      }

      return {'success': false, 'message': message};
    } catch (e) {
      developer.log('Other exception: $e');
      return {
        'success': false,
        'message': 'Failed to save account. Please try again later.',
      };
    }
  }

  /// Login existing user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = credential.user;

      // 🔹 Fetch user profile from Firestore; auto-provision if missing
      final userRef = _firestore.collection('users').doc(user!.uid);
      DocumentSnapshot snapshot = await userRef.get();

      if (!snapshot.exists) {
        final display = user.displayName ?? '';
        final parts = display.trim().split(' ');
        final first = parts.isNotEmpty ? parts.first : '';
        final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';

        await userRef.set({
          'uid': user.uid,
          'firstName': first,
          'lastName': last,
          'email': user.email ?? normalizedEmail,
          'displayName': display,
          'profilePicture': '',
          'fitnessGoals': [],
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        snapshot = await userRef.get();
      }

      // 🔹 Convert Firestore data safely
      final data = snapshot.data() as Map<String, dynamic>;
      data.updateAll((key, value) {
        if (value is Timestamp) {
          return value.toDate().toIso8601String();
        }
        return value;
      });

      return {
        'success': true,
        'message': 'Login successful!',
        'firebaseUser': user, // FirebaseAuth User object
        'firestoreUser': data, // Firestore user profile map
      };
    } on FirebaseAuthException catch (e) {
      developer.log('FirebaseAuthException: ${e.code} - ${e.message}');
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = e.message ?? 'Login failed. Please try again.';
      }

      return {'success': false, 'message': message};
    } catch (e) {
      developer.log('Other exception: $e');
      return {
        'success': false,
        'message': 'Login failed. Please try again later.',
      };
    }
  }

  /// Logout current user
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get current user (Auth object, not Firestore data)
  static User? get currentUser => _auth.currentUser;
}
