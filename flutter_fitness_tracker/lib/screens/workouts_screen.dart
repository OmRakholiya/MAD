import 'package:flutter/material.dart';
import 'dart:async';
import '../models/workout_model.dart';
import 'package:intl/intl.dart';
import '../services/firebase_workout_service.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  WorkoutsScreenState createState() => WorkoutsScreenState();
}

class WorkoutsScreenState extends State<WorkoutsScreen> {
  final DateFormat _dateFmt = DateFormat('EEE, MMM d');
  final List<String> _filters = const ['all', 'cardio', 'strength', 'yoga', 'hiit'];
  String _selectedFilter = 'all';

  // ignore: unused_element
  String _formatMmSs(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildTitle(WorkoutModel w) {
    final base = w.name;
    final isOngoing = w.hasActiveSession;
    
    if (!isOngoing) {
      // For completed workouts, show static last session time
      if (w.lastSessionDisplay != null) {
        return Text('$base • ${w.lastSessionDisplay}');
      }
      return Text(base);
    }
    
    // For ongoing workouts, update every second to show current session time
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(seconds: 1), (x) => x),
      builder: (context, _) {
        final currentTime = w.lastSessionDisplay;
        if (currentTime != null) {
          return Text('$base • $currentTime');
        }
        return Text(base);
      },
    );
  }

  Widget _buildSubtitle(WorkoutModel w) {
    // Just show the basic workout info without time (time is now in title)
    return Text('${w.type.toUpperCase()} • ${w.primaryDisplayDetail} • ${_dateFmt.format(w.date)}');
  }

  Future<void> _startWorkout(WorkoutModel w) async {
    final started = w.startNewSession();
    await FirebaseWorkoutService.upsertWorkout(started);
  }

  Future<void> _endWorkout(WorkoutModel w) async {
    final ended = w.endCurrentSession();
    await FirebaseWorkoutService.upsertWorkout(ended);
  }

  Future<void> _openEditDialog({WorkoutModel? existing}) async {
    final formKey = GlobalKey<FormState>();
    String name = existing?.name ?? '';
    String type = existing?.type ?? 'cardio';
    String intensity = existing?.intensity ?? 'moderate';
    String reps = existing?.repsScheme ?? '';
    String caloriesStr = existing?.calories.toString() ?? '';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Workout' : 'Edit Workout'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onSaved: (v) => name = v?.trim() ?? '',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(value: 'cardio', child: Text('Cardio')),
                      DropdownMenuItem(value: 'strength', child: Text('Strength')),
                      DropdownMenuItem(value: 'yoga', child: Text('Yoga')),
                      DropdownMenuItem(value: 'hiit', child: Text('HIIT')),
                      DropdownMenuItem(value: 'custom', child: Text('Custom')),
                    ],
                    onChanged: (v) => type = v ?? 'custom',
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: intensity,
                    decoration: const InputDecoration(labelText: 'Intensity'),
                    items: const [
                      DropdownMenuItem(value: 'easy', child: Text('Easy')),
                      DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                      DropdownMenuItem(value: 'hard', child: Text('Hard')),
                    ],
                    onChanged: (v) => intensity = v ?? 'moderate',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: reps,
                    decoration: const InputDecoration(labelText: 'Reps scheme (e.g., 4 x 12)'),
                    onSaved: (v) => reps = v?.trim() ?? '',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: caloriesStr,
                    decoration: const InputDecoration(labelText: 'Calories'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final parsed = int.tryParse(v);
                      if (parsed == null || parsed < 0) return 'Enter a valid number';
                      return null;
                    },
                    onSaved: (v) => caloriesStr = v!.trim(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                formKey.currentState!.save();
                final now = DateTime.now();
                final model = WorkoutModel(
                  id: existing?.id ?? now.millisecondsSinceEpoch.toString(),
                  name: name,
                  type: type,
                  durationMinutes: existing?.durationMinutes,
                  repsScheme: reps.isEmpty ? null : reps,
                  calories: int.tryParse(caloriesStr) ?? 0,
                  date: existing?.date ?? now,
                  intensity: intensity,
                  completed: existing?.completed ?? false,
                  tags: existing?.tags ?? const [],
                );
                await FirebaseWorkoutService.upsertWorkout(model);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteWorkout(String id) async {
    await FirebaseWorkoutService.deleteWorkout(id);
  }

  // ignore: unused_element
  Future<void> _toggleCompleted(WorkoutModel w) async {
    await FirebaseWorkoutService.upsertWorkout(w.copyWith(completed: !w.completed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => setState(() => _selectedFilter = v),
            itemBuilder: (context) => _filters
                .map((f) => PopupMenuItem<String>(value: f, child: Text(f.toUpperCase())))
                .toList(),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: StreamBuilder<List<WorkoutModel>>(
        stream: FirebaseWorkoutService.streamWorkouts(type: _selectedFilter),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final workouts = snapshot.data ?? const <WorkoutModel>[];
          if (workouts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No workouts yet. Tap + to add your first workout.'),
                  ],
                ),
              ),
            );
          }
          final totalCalories = workouts.fold<int>(0, (sum, w) => sum + w.calories);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${workouts.length} workouts',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Total: $totalCalories kcal'),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final w = workouts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: w.completed ? Colors.green[100] : Colors.blue[100],
                          child: Icon(
                            w.isStrength ? Icons.fitness_center : Icons.directions_run,
                            color: w.completed ? Colors.green[800] : Colors.blue[800],
                          ),
                        ),
                        title: _buildTitle(w),
                        subtitle: _buildSubtitle(w),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                final isOngoing = w.hasActiveSession;
                                if (isOngoing) {
                                  _endWorkout(w);
                                } else {
                                  _startWorkout(w);
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: w.hasActiveSession
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              child: Text(w.hasActiveSession ? 'End' : 'Start'),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'edit') {
                                  _openEditDialog(existing: w);
                                } else if (v == 'delete') {
                                  _deleteWorkout(w.id);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                                PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                        onTap: null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
