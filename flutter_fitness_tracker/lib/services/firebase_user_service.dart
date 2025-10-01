import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirebaseUserService {
  static String? get _uidOrNull => FirebaseAuth.instance.currentUser?.uid;
  static DocumentReference<Map<String, dynamic>>? get _docOrNull => _uidOrNull == null
      ? null
      : FirebaseFirestore.instance.collection('users').doc(_uidOrNull);

  static Future<UserModel?> getUser() async {
    final doc = _docOrNull;
    if (doc == null) return null;
    final snap = await doc.get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    return UserModel.fromMap({
      ...data,
      'id': _uidOrNull,
    });
  }

  static Stream<UserModel?> streamUser() {
    final doc = _docOrNull;
    if (doc == null) return Stream<UserModel?>.value(null);
    return doc.snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      return UserModel.fromMap({
        ...data,
        'id': _uidOrNull,
      });
    });
  }

  static Future<void> upsertUser(UserModel user) async {
    final doc = _docOrNull;
    if (doc == null) return;
    await doc.set(user.toMap(), SetOptions(merge: true));
  }
}
