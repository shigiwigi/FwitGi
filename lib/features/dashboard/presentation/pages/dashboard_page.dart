import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:fwitgi_app/features/workout/presentation/pages/workout_selection_page.dart';
import 'package:fwitgi_app/features/workout/presentation/pages/workout_session_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  // Helper getters to access theme colors using BuildContext
  Color _getOnSurfaceColor(BuildContext context) => Theme.of(context).colorScheme.onSurface;
  Color _getOnSurfaceVariantColor(BuildContext context) => Theme.of(context).colorScheme.onSurfaceVariant;
  Color _getCardColor(BuildContext context) => Theme.of(context).cardColor;
  Color _getNavigationBarBackgroundColor(BuildContext context) => Theme.of(context).navigationBarTheme.backgroundColor ?? Theme.of(context).cardColor;
  Color _getOnBackgroundColor(BuildContext context) => Theme.of(context).colorScheme.onBackground;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsGrid(context),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildRecentWorkouts(context),
                const SizedBox(height: 24),
                _buildProgressChart(context),
                // REMOVED: Temporary "Go to Workout Session (Test)" button
                const SizedBox(height: 100), // Original bottom padding
              ]),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFAB(context), // FAB logic moved to this method
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container( // Gradient AppBar Background
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, Alex',
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
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
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
                  '2',
                  '/ 3 planned',
                  Icons.fitness_center,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Calories',
                  '1,850',
                  '/ 2,200 goal',
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
                  // Navigate to the new WorkoutSelectionPage
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
                  // TODO: Implement navigation to log meal page
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
                  // TODO: Implement navigation to body stats page
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

  Widget _buildRecentWorkouts(BuildContext context) {
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
                // TODO: Implement navigation to view all workouts
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildWorkoutCard(
          context,
          'Push Day',
          'Chest, Shoulders, Triceps',
          '1h 15m',
          '12.5k lbs',
          Icons.fitness_center,
          AppTheme.primaryColor,
          true,
        ),
        const SizedBox(height: 12),
        _buildWorkoutCard(
          context,
          'Pull Day',
          'Back, Biceps',
          '1h 5m',
          '10.2k lbs',
          Icons.fitness_center,
          AppTheme.accentColor,
          false,
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
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getOnSurfaceColor(context),
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
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCardColor(context),
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
              Text(
                'Weekly Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.accentColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Chart Placeholder\n(FL Chart Integration)',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _getOnBackgroundColor(context).withOpacity(0.6),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            // CONNECTING FAB TO START NEW WORKOUT SESSION
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WorkoutSessionPage()),
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

  Widget _buildBottomNavBar(BuildContext context) {
    // Current selected index - for demonstration, you'd manage this with state
    const int currentIndex = 0; // Home is selected

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
                // TODO: Implement navigation to Home page
              }),
              _buildNavItem(context, Icons.fitness_center, 'Workouts', 1, currentIndex, () {
                // TODO: Implement navigation to Workouts list page
              }),
              _buildNavItem(context, Icons.restaurant, 'Nutrition', 2, currentIndex, () {
                // TODO: Implement navigation to Nutrition page
              }),
              _buildNavItem(context, Icons.analytics, 'Progress', 3, currentIndex, () {
                // TODO: Implement navigation to Progress page
              }),
              _buildNavItem(context, Icons.person, 'Profile', 4, currentIndex, () {
                // TODO: Implement navigation to Profile page
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              color: isSelected ? AppTheme.primaryColor : _getOnSurfaceVariantColor(context),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : _getOnSurfaceVariantColor(context),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}