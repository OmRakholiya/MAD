import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FirebaseStatsService {
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;
  static DocumentReference<Map<String, dynamic>> _dayRef(DateTime date) {
    final dayId = DateFormat('yyyy-MM-dd').format(date);
    return FirebaseFirestore.instance
      .collection('users').doc(_uid)
      .collection('stats').doc(dayId);
  }

  static Future<void> incrementDaily({required int calories, required DateTime date, String? type}) async {
    final ref = _dayRef(date);
    final byTypeField = type != null ? {'byType.$type': FieldValue.increment(1)} : {};
    await ref.set({
      'totalCalories': FieldValue.increment(calories),
      'totalWorkouts': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
      ...byTypeField,
    }, SetOptions(merge: true));
  }

  static Future<void> decrementDaily({required int calories, required DateTime date, String? type}) async {
    final ref = _dayRef(date);
    final byTypeField = type != null ? {'byType.$type': FieldValue.increment(-1)} : {};
    await ref.set({
      'totalCalories': FieldValue.increment(-calories),
      'totalWorkouts': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
      ...byTypeField,
    }, SetOptions(merge: true));
  }

  static Future<List<Map<String, dynamic>>> loadStatsRange(DateTime start, DateTime end) async {
    // Iterate days (7 reads) – efficient for charts
    final days = <Map<String, dynamic>>[];
    for (int i = 0; i < end.difference(start).inDays; i++) {
      final day = start.add(Duration(days: i));
      final doc = await _dayRef(day).get();
      days.add({'date': day, ...?doc.data()});
    }
    return days;
  }
}