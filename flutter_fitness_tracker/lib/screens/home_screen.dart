import 'package:flutter/material.dart';
import 'workouts_screen.dart';
import 'progress_screen.dart';
import 'exercise_plan_detail_screen.dart';
import '../services/firebase_workout_service.dart';
import '../services/exercise_plan_service.dart';
import '../models/workout_model.dart';
import '../models/exercise_plan_model.dart';
import 'package:intl/intl.dart';
import '../services/firebase_user_service.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _userData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _userData = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const _DashboardTab(),
      const WorkoutsScreen(),
      const ProgressScreen(),
      _ProfileTab(userData: _userData),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  DateTime get _startOfWeek {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  DateTime get _endOfWeek => _startOfWeek.add(const Duration(days: 7));

  Future<_WeeklySummary> _loadWeeklySummary() async {
    final workouts = await FirebaseWorkoutService.loadWorkoutsInRange(
      _startOfWeek,
      _endOfWeek,
    );
    int totalCalories = 0;
    int totalWorkouts = 0;
    int todayCalories = 0;
    int todayWorkouts = 0;
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (final w in workouts) {
      totalCalories += w.calories;
      totalWorkouts += 1;
      final k = DateFormat('yyyy-MM-dd').format(w.date);
      if (k == todayKey) {
        todayCalories += w.calories;
        todayWorkouts += 1;
      }
    }
    return _WeeklySummary(
      todayCalories: todayCalories,
      todayWorkouts: todayWorkouts,
      weekCalories: totalCalories,
      weekWorkouts: totalWorkouts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FitTracker Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _greetingCard(),
            const SizedBox(height: 16),
            _exercisePlansSection(context),
            const SizedBox(height: 16),
            FutureBuilder<_WeeklySummary>(
              future: _loadWeeklySummary(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final data = snapshot.data ?? const _WeeklySummary();
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _StatCard(
                      title: 'Today Workouts',
                      value: '${data.todayWorkouts}',
                      icon: Icons.checklist_rtl,
                      color: Colors.teal,
                    ),
                    _StatCard(
                      title: 'Today Calories',
                      value: '${data.todayCalories}',
                      icon: Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: 'Week Workouts',
                      value: '${data.weekWorkouts}',
                      icon: Icons.fitness_center,
                      color: Colors.indigo,
                    ),
                    _StatCard(
                      title: 'Week Calories',
                      value: '${data.weekCalories}',
                      icon: Icons.bolt,
                      color: Colors.purple,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _quickActions(context),
            const SizedBox(height: 16),
            const Text(
              'Recent Workouts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _recentWorkoutsList(),
          ],
        ),
      ),
    );
  }

  Widget _greetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[800]!, Colors.blue[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Let\'s hit your goals today.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const WorkoutsScreen())),
            icon: const Icon(Icons.add),
            label: const Text('Add Workout'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProgressScreen())),
            icon: const Icon(Icons.trending_up),
            label: const Text('View Progress'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _exercisePlansSection(BuildContext context) {
    final plans = ExercisePlanService.getPredefinedPlans();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exercise Plans',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose from our curated workout plans designed for different fitness levels',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(
                  right: index < plans.length - 1 ? 16 : 0,
                ),
                child: _buildExercisePlanCard(context, plan),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildExercisePlanCard(BuildContext context, ExercisePlan plan) {
    Color levelColor = _getLevelColor(plan.level);
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExercisePlanDetailScreen(plan: plan),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              image: plan.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(plan.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  levelColor,
                  // ignore: deprecated_member_use
                  levelColor.withOpacity(0.6),
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.2),
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            plan.level.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _getCategoryIcon(plan.category),
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      plan.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _buildPlanInfo(
                          Icons.calendar_today,
                          '${plan.durationWeeks}w',
                        ),
                        const SizedBox(width: 16),
                        _buildPlanInfo(
                          Icons.fitness_center,
                          '${plan.workoutsPerWeek}x/w',
                        ),
                        const SizedBox(width: 16),
                        _buildPlanInfo(
                          Icons.local_fire_department,
                          '~${plan.estimatedCaloriesPerSession}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }


  Color _getLevelColor(String level) {
    // Use a uniform light blue color for all levels
    return Colors.blue.shade400;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'yoga':
        return Icons.self_improvement;
      case 'hiit':
        return Icons.flash_on;
      case 'full_body':
        return Icons.accessibility_new;
      default:
        return Icons.fitness_center;
    }
  }


  Widget _recentWorkoutsList() {
    final dateFmt = DateFormat('EEE, MMM d');
    return StreamBuilder<List<WorkoutModel>>(
      stream: FirebaseWorkoutService.streamWorkouts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final workouts = (snapshot.data ?? const <WorkoutModel>[])
            .take(5)
            .toList();
        if (workouts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No workouts yet. Tap "Add Workout" to get started!'),
          );
        }
        return Column(
          children: workouts
              .map(
                (w) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          w.isStrength
                              ? Icons.fitness_center
                              : Icons.directions_run,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${w.type.toUpperCase()} • ${w.primaryDisplayDetail} • ${dateFmt.format(w.date)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${w.calories} kcal',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const _ProfileTab({this.userData});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final DateFormat _dobFmt = DateFormat('yyyy-MM-dd');

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _openEditProfile(UserModel? user) {
    final formKey = GlobalKey<FormState>();
    String firstName = user?.firstName ?? '';
    String lastName = user?.lastName ?? '';
    String email = user?.email ?? '';
    String gender = user?.gender ?? 'other';
    String activity = user?.activityLevel ?? 'moderate';
    String height = (user?.heightCm ?? 0).toString();
    String weight = (user?.weightKg ?? 0).toString();
    DateTime? dob = user?.dateOfBirth;
    String stepsTarget = (user?.dailyStepsTarget ?? 8000).toString();
    String caloriesTarget = (user?.dailyCaloriesTarget ?? 2200).toString();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 48,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: firstName,
                          decoration: const InputDecoration(
                            labelText: 'First name',
                          ),
                          onSaved: (v) => firstName = v?.trim() ?? '',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: lastName,
                          decoration: const InputDecoration(
                            labelText: 'Last name',
                          ),
                          onSaved: (v) => lastName = v?.trim() ?? '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    onSaved: (v) => email = v?.trim() ?? '',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: height,
                          decoration: const InputDecoration(
                            labelText: 'Height (cm)',
                          ),
                          keyboardType: TextInputType.number,
                          onSaved: (v) => height = v?.trim() ?? '',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: weight,
                          decoration: const InputDecoration(
                            labelText: 'Weight (kg)',
                          ),
                          keyboardType: TextInputType.number,
                          onSaved: (v) => weight = v?.trim() ?? '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: gender,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (v) => gender = v ?? 'other',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: activity,
                          decoration: const InputDecoration(
                            labelText: 'Activity',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'sedentary',
                              child: Text('Sedentary'),
                            ),
                            DropdownMenuItem(
                              value: 'light',
                              child: Text('Light'),
                            ),
                            DropdownMenuItem(
                              value: 'moderate',
                              child: Text('Moderate'),
                            ),
                            DropdownMenuItem(
                              value: 'active',
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: 'very_active',
                              child: Text('Very Active'),
                            ),
                          ],
                          onChanged: (v) => activity = v ?? 'moderate',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            dob ?? DateTime(now.year - 25, now.month, now.day),
                        firstDate: DateTime(1900),
                        lastDate: now,
                      );
                      if (picked != null) {
                        setState(() {
                          dob = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dob == null ? 'Select date' : _dobFmt.format(dob!),
                          ),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: stepsTarget,
                          decoration: const InputDecoration(
                            labelText: 'Daily Steps Target',
                          ),
                          keyboardType: TextInputType.number,
                          onSaved: (v) => stepsTarget = v?.trim() ?? '8000',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: caloriesTarget,
                          decoration: const InputDecoration(
                            labelText: 'Daily Calories Target',
                          ),
                          keyboardType: TextInputType.number,
                          onSaved: (v) => caloriesTarget = v?.trim() ?? '2200',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            formKey.currentState!.save();
                            final parsedHeight = double.tryParse(height) ?? 0;
                            final parsedWeight = double.tryParse(weight) ?? 0;
                            final uid = FirebaseAuth.instance.currentUser!.uid;
                            final userModel = UserModel(
                              id: user?.id.isNotEmpty == true ? user!.id : uid,
                              email: email,
                              firstName: firstName,
                              lastName: lastName,
                              dateOfBirth: dob,
                              heightCm: parsedHeight,
                              weightKg: parsedWeight,
                              gender: gender,
                              activityLevel: activity,
                              dailyStepsTarget:
                                  int.tryParse(stepsTarget) ?? 8000,
                              dailyCaloriesTarget:
                                  int.tryParse(caloriesTarget) ?? 2200,
                            );
                            await FirebaseUserService.upsertUser(userModel);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<UserModel?>(
        stream: FirebaseUserService.streamUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          final displayName = user?.fullName.isNotEmpty == true
              ? user!.fullName
              : (widget.userData?['firstName'] ?? 'User').toString();
          final email = user?.email.isNotEmpty == true
              ? user!.email
              : (widget.userData?['email'] ?? '').toString();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[800]!, Colors.blue[600]!],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName.substring(0, 1).toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _metricCard(
                      'BMI',
                      user == null ? '-' : user.bmi.toStringAsFixed(1),
                    ),
                    _metricCard(
                      'BMR',
                      user == null ? '-' : user.bmr.toStringAsFixed(0),
                    ),
                    _metricCard(
                      'Maintain',
                      user == null
                          ? '-'
                          : user.maintenanceCalories.toStringAsFixed(0),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (user != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('BMI Category: ${user.bmiCategory}'),
                        Text('Age: ${user.age}'),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                _profileOption(
                  context,
                  'Edit Profile',
                  'Update your personal information',
                  Icons.edit,
                  () {
                    _openEditProfile(user);
                  },
                ),
                _profileOption(
                  context,
                  'Goals',
                  'Set steps and calorie targets',
                  Icons.flag,
                  () {
                    _openEditProfile(user);
                  },
                ),
                _profileOption(
                  context,
                  'About',
                  'App version and information',
                  Icons.info,
                  () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'FitTracker',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2024 FitTracker',
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _metricCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _profileOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[800]),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class _WeeklySummary {
  final int todayCalories;
  final int todayWorkouts;
  final int weekCalories;
  final int weekWorkouts;
  const _WeeklySummary({
    this.todayCalories = 0,
    this.todayWorkouts = 0,
    this.weekCalories = 0,
    this.weekWorkouts = 0,
  });
}
