import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_model.dart';

class FirebaseWorkoutService {
  static String? get _uidOrNull => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>>? get _colOrNull => _uidOrNull == null
      ? null
      : FirebaseFirestore.instance
          .collection('users')
          .doc(_uidOrNull)
          .collection('workouts');

  static Future<void> upsertWorkout(WorkoutModel workout) async {
    final col = _colOrNull;
    if (col == null) return;
    final doc = col.doc(workout.id);
    await doc.set({
      ...workout.toMap(),
      'date': Timestamp.fromDate(workout.date),
      'startAt': workout.startAt != null ? Timestamp.fromDate(workout.startAt!) : null,
      'endAt': workout.endAt != null ? Timestamp.fromDate(workout.endAt!) : null,
    }, SetOptions(merge: true));
  }
  static Future<void> deleteWorkout(String id) async {
    final col = _colOrNull;
    if (col == null) return;
    await col.doc(id).delete();
  }

  static Stream<List<WorkoutModel>> streamWorkouts({String? type}) {
    // React to auth state so the stream starts after login
    return FirebaseAuth.instance.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream<List<WorkoutModel>>.value(const []);
      }
      Query<Map<String, dynamic>> q = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .orderBy('date', descending: true);
      if (type != null && type != 'all') {
        q = q.where('type', isEqualTo: type);
      }
      return q.snapshots().map((snap) => snap.docs.map((d) {
            final data = d.data();
            final ts = data['date'] as Timestamp?;
            final iso = ts != null ? ts.toDate().toIso8601String() : DateTime.now().toIso8601String();
            final startTs = data['startAt'] as Timestamp?;
            final endTs = data['endAt'] as Timestamp?;
            return WorkoutModel.fromMap({
              ...data,
              'id': d.id,
              'date': iso,
              'startAt': startTs?.toDate().toIso8601String(),
              'endAt': endTs?.toDate().toIso8601String(),
            });
          }).toList());
    });
  }

  static Future<List<WorkoutModel>> loadWorkoutsInRange(DateTime start, DateTime end) async {
    final col = _colOrNull;
    if (col == null) return [];
    final snap = await col
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      final ts = data['date'] as Timestamp?;
      final iso = ts != null ? ts.toDate().toIso8601String() : DateTime.now().toIso8601String();
      final startTs = data['startAt'] as Timestamp?;
      final endTs = data['endAt'] as Timestamp?;
      return WorkoutModel.fromMap({
        ...data,
        'id': d.id,
        'date': iso,
        'startAt': startTs?.toDate().toIso8601String(),
        'endAt': endTs?.toDate().toIso8601String(),
      });
    }).toList();
  }
}