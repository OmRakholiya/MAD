import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firebase_workout_service.dart';
import '../services/diet_plan_service.dart';
import '../models/workout_model.dart';
import '../models/diet_plan_model.dart';
import 'diet_plan_detail_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  DateTime get _startOfWeek {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  DateTime get _endOfWeek => _startOfWeek.add(const Duration(days: 7));

  Future<_WeeklyData> _loadWeekly() async {
    final workouts = await FirebaseWorkoutService.loadWorkoutsInRange(
      _startOfWeek,
      _endOfWeek,
    );
    final totals = List<double>.filled(7, 0);
    final counts = List<int>.filled(7, 0);

    for (final WorkoutModel w in workouts) {
      final idx = w.date.difference(_startOfWeek).inDays;
      if (idx >= 0 && idx < 7) {
        totals[idx] += w.calories.toDouble();
        counts[idx] += 1;
      }
    }

    final totalWeekCalories = totals.fold<double>(0, (a, b) => a + b);
    final totalWorkouts = counts.fold<int>(0, (a, b) => a + b);

    final spots = List<FlSpot>.generate(
      7,
      (i) => FlSpot((i + 1).toDouble(), totals[i]),
    );
    final bars = List<BarChartGroupData>.generate(
      7,
      (i) => BarChartGroupData(
        x: i + 1,
        barRods: [
          BarChartRodData(toY: counts[i].toDouble(), color: Colors.blue),
        ],
      ),
    );

    return _WeeklyData(
      totals: totals,
      counts: counts,
      spots: spots,
      bars: bars,
      totalWeekCalories: totalWeekCalories,
      totalWorkouts: totalWorkouts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: FutureBuilder<_WeeklyData>(
        future: _loadWeekly(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data ?? _WeeklyData.empty();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        title: 'Weekly Calories',
                        value:
                            '${data.totalWeekCalories.toStringAsFixed(0)} kcal',
                        color: Colors.orange,
                        icon: Icons.local_fire_department,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        title: 'Total Workouts',
                        value: '${data.totalWorkouts}',
                        color: Colors.blue,
                        icon: Icons.fitness_center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calories Burned',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            minX: 1,
                            maxX: 7,
                            gridData: FlGridData(
                              show: true,
                              horizontalInterval: 100,
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                axisNameWidget: const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Text(
                                    'Calories (kcal)',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                axisNameSize: 24,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 44,
                                  interval: 100,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                axisNameWidget: const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Day of Week',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                axisNameSize: 22,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const labels = [
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat',
                                      'Sun',
                                    ];
                                    final idx = value.toInt() - 1;
                                    return Text(
                                      idx >= 0 && idx < labels.length
                                          ? labels[idx]
                                          : '',
                                    );
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: data.spots,
                                isCurved: true,
                                barWidth: 3,
                                color: Colors.orange,
                                dotData: FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Workouts per Day',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            barGroups: data.bars,
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                axisNameWidget: const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Text(
                                    'Workouts',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                axisNameSize: 22,
                                sideTitles: const SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: 1,
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                axisNameWidget: const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Day',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                axisNameSize: 20,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const labels = [
                                      'M',
                                      'T',
                                      'W',
                                      'T',
                                      'F',
                                      'S',
                                      'S',
                                    ];
                                    final idx = value.toInt() - 1;
                                    return Text(
                                      idx >= 0 && idx < labels.length
                                          ? labels[idx]
                                          : '',
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _dietPlansSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dietPlansSection(BuildContext context) {
    final plans = DietPlanService.getPredefinedPlans();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diet Plans',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Discover nutrition plans tailored to your health and fitness goals',
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
                child: _buildDietPlanCard(context, plan),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDietPlanCard(BuildContext context, DietPlan plan) {
    Color goalColor = _getDietGoalColor(plan.goal);
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DietPlanDetailScreen(plan: plan),
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
                  goalColor,
                  // ignore: deprecated_member_use
                  goalColor.withOpacity(0.6),
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
                            plan.goal.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _getDietGoalIcon(plan.goal),
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
                          '${plan.durationDays}d',
                        ),
                        const SizedBox(width: 16),
                        _buildPlanInfo(
                          Icons.trending_up,
                          plan.difficulty,
                        ),
                        const SizedBox(width: 16),
                        _buildPlanInfo(
                          Icons.local_fire_department,
                          '${plan.dailyTargets.calories}',
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

  Color _getDietGoalColor(String goal) {
    switch (goal) {
      case 'weight_loss':
        return Colors.orange;
      case 'muscle_gain':
        return Colors.red;
      case 'maintenance':
        return Colors.blue;
      case 'healthy_eating':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getDietGoalIcon(String goal) {
    switch (goal) {
      case 'weight_loss':
        return Icons.trending_down;
      case 'muscle_gain':
        return Icons.fitness_center;
      case 'maintenance':
        return Icons.balance;
      case 'healthy_eating':
        return Icons.eco;
      default:
        return Icons.restaurant;
    }
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          // ignore: deprecated_member_use
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyData {
  final List<double> totals;
  final List<int> counts;
  final List<FlSpot> spots;
  final List<BarChartGroupData> bars;
  final double totalWeekCalories;
  final int totalWorkouts;

  const _WeeklyData({
    required this.totals,
    required this.counts,
    required this.spots,
    required this.bars,
    required this.totalWeekCalories,
    required this.totalWorkouts,
  });

  factory _WeeklyData.empty() => _WeeklyData(
    totals: List<double>.filled(7, 0),
    counts: List<int>.filled(7, 0),
    spots: List<FlSpot>.generate(7, (i) => FlSpot((i + 1).toDouble(), 0)),
    bars: List<BarChartGroupData>.generate(
      7,
      (i) => BarChartGroupData(
        x: i + 1,
        barRods: [BarChartRodData(toY: 0, color: Colors.blue)],
      ),
    ),
    totalWeekCalories: 0,
    totalWorkouts: 0,
  );
}
