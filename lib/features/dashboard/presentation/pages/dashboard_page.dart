import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart'; // For the bar chart
import 'package:intl/intl.dart'; // For date formatting

// Core and Theme
import 'package:fwitgi_app/core/theme/app_theme.dart';
import 'package:fwitgi_app/core/di/dependency_injection.dart';
import 'package:fwitgi_app/core/models/user_model.dart';

// Auth Feature
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_state.dart';

// Workout Feature
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fwitgi_app/features/workout/domain/entities/workout.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_state.dart';
import 'package:fwitgi_app/features/workout/presentation/pages/workout_selection_page.dart';
import 'package:fwitgi_app/features/workout/presentation/pages/workout_session_page.dart';
import 'package:fwitgi_app/features/workout/presentation/pages/workout_history_page.dart';

// Nutrition Feature
import 'package:fwitgi_app/features/nutrition/presentation/bloc/nutrition_bloc.dart';
import 'package:fwitgi_app/features/nutrition/presentation/bloc/nutrition_event.dart';
import 'package:fwitgi_app/features/nutrition/presentation/bloc/nutrition_state.dart';
import 'package:fwitgi_app/features/nutrition/presentation/pages/nutrition_page.dart';

// Body Tracking Feature
import 'package:fwitgi_app/features/body_tracking/presentation/bloc/body_tracking_bloc.dart';
import 'package:fwitgi_app/features/nutrition/body_tracking/presentation/bloc/body_tracking_event.dart';
import 'package:fwitgi_app/features/body_tracking/presentation/bloc/body_tracking_state.dart';
import 'package:fwitgi_app/features/body_tracking/presentation/pages/body_tracking_page.dart';

// User Feature
import 'package:fwitgi_app/features/user/presentation/pages/user_profile_page.dart';

// New imports for ExerciseDefinition and its Repository
import 'package:fwitgi_app/features/workout/domain/repositories/exercise_definition_repository.dart';
import 'package:fwitgi_app/features/workout/domain/entities/exercise_definition.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Color _getOnSurfaceColor(BuildContext context) => Theme.of(context).colorScheme.onSurface;
  Color _getOnSurfaceVariantColor(BuildContext context) => Theme.of(context).colorScheme.onSurfaceVariant;
  Color _getCardColor(BuildContext context) => Theme.of(context).colorScheme.surfaceContainerHighest;
  Color _getNavigationBarBackgroundColor(BuildContext context) => Theme.of(context).navigationBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest;
  Color _getOnBackgroundColor(BuildContext context) => Theme.of(context).colorScheme.onBackground;

  late AuthBloc _authBloc;
  late WorkoutBloc _workoutBloc;
  late NutritionBloc _nutritionBloc;
  late BodyTrackingBloc _bodyTrackingBloc;
  late ExerciseDefinitionRepository _exerciseDefinitionRepository;

  // Store fetched exercise definitions in a map for quick lookup
  Map<String, ExerciseDefinition> _exerciseDefinitionsMap = {};

  @override
  void initState() {
    super.initState();
    _authBloc = getlt<AuthBloc>();
    _workoutBloc = getlt<WorkoutBloc>();
    _nutritionBloc = getlt<NutritionBloc>();
    _bodyTrackingBloc = getlt<BodyTrackingBloc>();
    _exerciseDefinitionRepository = getlt<ExerciseDefinitionRepository>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Fetch all exercise definitions once when the dashboard loads
      try {
        final List<ExerciseDefinition> definitions = await _exerciseDefinitionRepository.getExerciseDefinitions();
        setState(() {
          _exerciseDefinitionsMap = { for (var def in definitions) def.id: def };
        });
      } catch (e) {
        print('Error fetching exercise definitions: $e');
        // Optionally show a snackbar or error message if definitions can't be loaded
      }

      final authState = _authBloc.state;
      if (authState is AuthAuthenticated) {
        final String userId = authState.user.id;
        _workoutBloc.add(LoadWorkouts(userId));
        _nutritionBloc.add(LoadDailyNutritionEvent(userId: userId, date: DateTime.now()));
        _bodyTrackingBloc.add(LoadBodyStatsEvent(userId));
        _workoutBloc.add(LoadWorkoutTemplates(userId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const int currentIndex = 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BlocBuilder<AuthBloc, AuthState>(
            bloc: _authBloc,
            builder: (context, authState) {
              UserModel? currentUser;
              if (authState is AuthAuthenticated) {
                currentUser = authState.user;
              }
              return _buildAppBar(context, currentUser);
            },
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: BlocBuilder<WorkoutBloc, WorkoutState>(
              bloc: _workoutBloc,
              builder: (context, workoutState) {
                final nutritionState = context.watch<NutritionBloc>().state;
                final bodyTrackingState = context.watch<BodyTrackingBloc>().state;

                if (workoutState is WorkoutLoading || nutritionState is NutritionLoading || bodyTrackingState is BodyTrackingLoading) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        )),
                  );
                } else if (workoutState is WorkoutError) {
                  return SliverToBoxAdapter(
                      child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text('Error loading workouts: ${workoutState.message}'),
                          )));
                } else if (nutritionState is NutritionError) {
                  return SliverToBoxAdapter(
                      child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text('Error loading nutrition: ${nutritionState.message}'),
                          )));
                } else if (bodyTrackingState is BodyTrackingError) {
                  return SliverToBoxAdapter(
                      child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text('Error loading body stats: ${bodyTrackingState.message}'),
                          )));
                }

                final authBlocState = context.read<AuthBloc>().state;
                if (authBlocState is! AuthAuthenticated) {
                    return const SliverFillRemaining(
                        child: Center(child: Text("User not authenticated.")));
                }
                final currentUser = authBlocState.user;


                final List<Workout> recentWorkouts = (workoutState is WorkoutLoaded) ? workoutState.workouts.take(2).toList() : [];
                final int workoutsToday = (workoutState is WorkoutLoaded) ? workoutState.workouts.where((w) {
                  final now = DateTime.now();
                  final workoutDate = DateTime(w.startTime.year, w.startTime.month, w.startTime.day);
                  final todayDate = DateTime(now.year, now.month, now.day);
                  return workoutDate.isAtSameMomentAs(todayDate);
                }).length : 0;

                final Map<String, double> weeklyWorkoutSummary = (workoutState is WorkoutLoaded) ? workoutState.workoutSummary : {};

                return SliverList(
                  delegate: SliverChildListDelegate([
                    _buildStatsGrid(context, workoutsToday, currentUser),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    // Pass the map of exercise definitions to _buildRecentWorkouts
                    _buildRecentWorkouts(context, recentWorkouts),
                    const SizedBox(height: 24),
                    _buildProgressChart(context, weeklyWorkoutSummary, currentUser),
                    const SizedBox(height: 100),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFAB(context),
      bottomNavigationBar: _buildBottomNavBar(context, currentIndex),
    );
  }

  Widget _buildAppBar(BuildContext context, UserModel? currentUser) {
    String greetingName = currentUser?.name ?? 'User';

    return SliverAppBar(
      expandedHeight: 180,
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, $greetingName',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            Text(
              'Ready to crush your goals?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications not implemented yet.')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, int workoutsToday, UserModel currentUser) {
    double dailyCalories = 0;
    final nutritionState = context.watch<NutritionBloc>().state;
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
            'Today\'s Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Workouts',
                  '$workoutsToday',
                  '/ ? planned',
                  Icons.fitness_center,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Calories',
                  '${dailyCalories.toStringAsFixed(0)}',
                  '/ $dailyCalorieGoal goal',
                  Icons.local_fire_department,
                  Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Start Workout',
                Icons.play_arrow,
                AppTheme.primaryColor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WorkoutSelectionPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'Log Meal',
                Icons.restaurant,
                AppTheme.accentColor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NutritionPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'Body Stats',
                Icons.monitor_weight,
                AppTheme.secondaryColor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BodyTrackingPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: _getOnSurfaceColor(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentWorkouts(BuildContext context, List<Workout> recentWorkouts) {
    // Helper to get exercise name from its definition ID
    String getExerciseName(String exerciseDefinitionId) {
      return _exerciseDefinitionsMap[exerciseDefinitionId]?.name ?? 'Unknown Exercise';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Workouts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutHistoryPage()),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentWorkouts.isEmpty)
          Center(
            child: Text(
              'No recent workouts. Start a new one!',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          )
        else
          Column(
            children: recentWorkouts.map((workout) {
              // Get names of the first 2 exercises from the workout
              // Now workout.exercises is List<WorkoutExercise>
              final String exerciseSummary = workout.exercises.take(2).map((woExercise) {
                return getExerciseName(woExercise.exerciseDefinitionId); // Use helper function
              }).join(', ') + (workout.exercises.length > 2 ? '...' : '');

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildWorkoutCard(
                  context,
                  workout.name,
                  exerciseSummary, // Pass the formatted exercise summary
                  '${workout.duration.inMinutes}m',
                  '${(workout.totalWeight).toStringAsFixed(1)} kg',
                  Icons.fitness_center,
                  Theme.of(context).colorScheme.primary,
                  workout.endTime != null,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildWorkoutCard(
    BuildContext context,
    String title,
    String subtitle,
    String duration,
    String weight,
    IconData icon,
    Color color,
    bool isCompleted,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getOnSurfaceColor(context),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCompleted)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.check_circle,
                          color: AppTheme.accentColor,
                          size: 18,
                        ),
                      ),
                  ],
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getOnSurfaceVariantColor(context),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: _getOnSurfaceVariantColor(context)),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getOnSurfaceVariantColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.fitness_center, size: 16, color: _getOnSurfaceVariantColor(context)),
                  const SizedBox(width: 4),
                  Text(
                    weight,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getOnSurfaceVariantColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
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
                toY: (currentUser.stats.totalWeightLifted > 0 ? currentUser.stats.totalWeightLifted / 7 : 100.0),
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
    if (maxY < 200) maxY = 200;

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
                      '+12%',
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

  Widget _buildFAB(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String? currentUserId;
    if (authState is AuthAuthenticated) {
      currentUserId = authState.user.id;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: currentUserId == null ? null : () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WorkoutSessionPage(userId: currentUserId!)),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'New Workout',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: _getNavigationBarBackgroundColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home, 'Home', 0, currentIndex, () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardPage()),
                  );
              }),
              _buildNavItem(context, Icons.fitness_center, 'Workouts', 1, currentIndex, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutHistoryPage()),
                );
              }),
              _buildNavItem(context, Icons.restaurant, 'Nutrition', 2, currentIndex, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NutritionPage()),
                );
              }),
              _buildNavItem(context, Icons.analytics, 'Progress', 3, currentIndex, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutHistoryPage()),
                );
              }),
              _buildNavItem(context, Icons.person, 'Profile', 4, currentIndex, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserProfilePage()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, int itemIndex, int currentIndex, VoidCallback onTap) {
    final bool isSelected = itemIndex == currentIndex;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to find first element or return null (similar to .firstWhereOrNull in newer Dart)
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}