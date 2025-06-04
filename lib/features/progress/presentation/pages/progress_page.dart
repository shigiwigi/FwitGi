// lib/features/progress/presentation/pages/progress_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart'; // For the bar chart
import 'package:intl/intl.dart'; // For date formatting

// Core and Theme
import 'package:fwitgi_app/core/theme/app_theme.dart';
import 'package:fwitgi_app/core/models/user_model.dart';

// Auth Feature (to get current user)
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_state.dart';

// Workout Feature (to get workout history and summary)
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_state.dart';

// Nutrition Feature (for daily calorie goal/summary)
import 'package:fwitgi_app/features/nutrition/presentation/bloc/nutrition_bloc.dart';
import 'package:fwitgi_app/features/nutrition/presentation/bloc/nutrition_state.dart';

// Body Tracking Feature (for body stats history)
import 'package:fwitgi_app/features/body_tracking/presentation/bloc/body_tracking_bloc.dart';
import 'package:fwitgi_app/features/body_tracking/presentation/bloc/body_tracking_state.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final String userId = authState.user.id;
        context.read<WorkoutBloc>().add(LoadWorkouts(userId));
        context.read<NutritionBloc>().add(LoadDailyNutritionEvent(userId: userId, date: DateTime.now()));
        context.read<BodyTrackingBloc>().add(LoadBodyStatsEvent(userId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient, // Apply gradient background
          ),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: Text("Please log in to view your progress."));
          }
          final UserModel currentUser = authState.user;

          return BlocBuilder<WorkoutBloc, WorkoutState>(
            builder: (context, workoutState) {
              final nutritionState = context.watch<NutritionBloc>().state;
              final bodyTrackingState = context.watch<BodyTrackingBloc>().state;

              if (workoutState is WorkoutLoading || nutritionState is NutritionLoading || bodyTrackingState is BodyTrackingLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final Map<String, double> weeklyWorkoutSummary = (workoutState is WorkoutLoaded) ? workoutState.workoutSummary : {};
              final List<Map<String, dynamic>> bodyStatsHistory = (bodyTrackingState is BodyTrackingLoaded) ? bodyTrackingState.statsHistory : [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverallStatsCard(context, currentUser, nutritionState),
                    const SizedBox(height: 24),
                    _buildProgressChart(context, weeklyWorkoutSummary, currentUser),
                    const SizedBox(height: 24),
                    _buildBodyStatsHistory(context, bodyStatsHistory),
                    const SizedBox(height: 100), // Extra space for FAB
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOverallStatsCard(BuildContext context, UserModel currentUser, NutritionState nutritionState) {
    double dailyCalories = 0;
    if (nutritionState is NutritionLoaded) {
      dailyCalories = nutritionState.dailySummary['calories'] ?? 0;
    }
    int dailyCalorieGoal = currentUser.preferences.dailyCalorieGoal;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Total Workouts', currentUser.stats.totalWorkouts.toString(), Icons.fitness_center),
          _buildStatRow('Total Weight Lifted', '${currentUser.stats.totalWeightLifted.toStringAsFixed(1)} kg', Icons.scale),
          _buildStatRow('Total Calories Logged', currentUser.stats.totalCaloriesLogged.toString(), Icons.local_fire_department),
          _buildStatRow('Current Weight', (bodyTrackingState is BodyTrackingLoaded && bodyTrackingState.statsHistory.isNotEmpty)
              ? '${bodyTrackingState.statsHistory.first['weight']?.toStringAsFixed(1) ?? 'N/A'} kg'
              : 'N/A', Icons.monitor_weight),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }


  Widget _buildProgressChart(BuildContext context, Map<String, double> weeklyWorkoutSummary, UserModel currentUser) {
    final Map<String, double> workoutSummary = weeklyWorkoutSummary;

    final List<BarChartGroupData> barGroups = [];
    final now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final List<String> xAxisLabels = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final String formattedDate = formatter.format(date);
      final double totalWeight = workoutSummary[formattedDate] ?? 0.0;
      final int dayIndex = 6 - i;

      barGroups.add(
        BarChartGroupData(
          x: dayIndex,
          barRods: [
            BarChartRodData(
              toY: totalWeight,
              color: Theme.of(context).colorScheme.primary,
              width: 8,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: (currentUser.stats.totalWeightLifted > 0 ? currentUser.stats.totalWeightLifted / 7 : 100.0), // Baseline based on average or fixed
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      );
      xAxisLabels.add(DateFormat('E').format(date));
    }

    double maxY = 0;
    if (workoutSummary.isNotEmpty) {
      maxY = workoutSummary.values.reduce((a, b) => a > b ? a : b) * 1.5;
      if (maxY < 100) maxY = 100;
    } else {
      maxY = 100;
    }
    if (maxY < 200) maxY = 200; // Ensure a minimum scale for visibility

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Weekly Progress (Total Weight Lifted)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // You can add a dynamic percentage change here if you implement it
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+XX%', // Replace with actual calculated percentage change
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: (workoutSummary.isEmpty || barGroups.isEmpty)
                ? Center(
              child: Text(
                'No workout data for this week yet.',
                style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
              ),
            )
                : BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: barGroups,
                borderData: FlBorderData(
                  show: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(xAxisLabels[value.toInt()], style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('');
                        return Text(value.toInt().toString(), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 10));
                      },
                      interval: maxY / 4,
                      reservedSize: 25,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 0.5,
                    );
                  },
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String weekDay = xAxisLabels[group.x.toInt()];
                      return BarTooltipItem(
                        '$weekDay\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: rod.toY.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(
                            text: ' kg',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyStatsHistory(BuildContext context, List<Map<String, dynamic>> bodyStatsHistory) {
    if (bodyStatsHistory.isEmpty) {
      return Center(
        child: Text(
          'No body stats logged yet.',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
        ),
      );
    }
    // Sort by timestamp descending
    bodyStatsHistory.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Body Stats History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bodyStatsHistory.length,
          itemBuilder: (context, index) {
            final stat = bodyStatsHistory[index];
            final timestamp = (stat['timestamp'] as Timestamp).toDate();
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('Weight: ${stat['weight']?.toStringAsFixed(1) ?? 'N/A'} kg'),
                subtitle: Text(
                  'Logged on: ${DateFormat('MMM d, yyyy HH:mm').format(timestamp)}\n'
                      'Neck: ${stat['neck']?.toStringAsFixed(1) ?? 0} cm | '
                      'Chest: ${stat['chest']?.toStringAsFixed(1) ?? 0} cm | '
                      'Waist: ${stat['waist']?.toStringAsFixed(1) ?? 0} cm | '
                      'Hips: ${stat['hips']?.toStringAsFixed(1) ?? 0} cm',
                ),
                isThreeLine: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tapped on stats from ${DateFormat('MMM d, yyyy').format(timestamp)}')),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}