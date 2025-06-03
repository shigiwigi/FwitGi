import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import '../../../../core/theme/app_theme.dart'; // Adjust path as necessary
import '../../domain/entities/workout.dart'; // Import the workout entities

class WorkoutSessionPage extends StatefulWidget {
  final String? workoutTemplateId;

  const WorkoutSessionPage({Key? key, this.workoutTemplateId}) : super(key: key);

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  late DateTime startTime;
  Duration elapsedTime = Duration.zero;
  Timer? timer;
  List<Exercise> exercises = [];
  String workoutName = '';
  WorkoutType selectedType = WorkoutType.push;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _startTimer();
    _loadWorkoutTemplate();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime = DateTime.now().difference(startTime);
      });
    });
  }

  void _loadWorkoutTemplate() {
    if (widget.workoutTemplateId != null) {
      // Load template from repository
      // For now, add sample exercises
      setState(() {
        workoutName = 'Push Day';
        exercises = [
          Exercise(
            id: '1',
            name: 'Bench Press',
            category: 'Chest',
            sets: [
              ExerciseSet(
                  setNumber: 1,
                  reps: 8,
                  weight: 135,
                  isCompleted: false,
                  type: SetType.warmup),
              ExerciseSet(
                  setNumber: 2,
                  reps: 6,
                  weight: 185,
                  isCompleted: false,
                  type: SetType.normal),
              ExerciseSet(
                  setNumber: 3,
                  reps: 6,
                  weight: 185,
                  isCompleted: false,
                  type: SetType.normal),
            ],
          ),
          Exercise(
            id: '2',
            name: 'Shoulder Press',
            category: 'Shoulders',
            sets: [
              ExerciseSet(
                  setNumber: 1,
                  reps: 8,
                  weight: 65,
                  isCompleted: false,
                  type: SetType.normal),
              ExerciseSet(
                  setNumber: 2,
                  reps: 8,
                  weight: 65,
                  isCompleted: false,
                  type: SetType.normal),
              ExerciseSet(
                  setNumber: 3,
                  reps: 8,
                  weight: 65,
                  isCompleted: false,
                  type: SetType.normal),
            ],
          ),
        ];
      });
    }
  }

  void _showWorkoutOptions() {
    // Implement workout options logic (e.g., end workout, save template)
  }

  void _showExerciseOptions(int exerciseIndex) {
    // Implement exercise options logic (e.g., edit, delete, add note)
  }

  void _updateSet(int exerciseIndex, int setIndex,
      {int? reps, double? weight, bool? isCompleted}) {
    setState(() {
      final updatedSets = List<ExerciseSet>.from(exercises[exerciseIndex].sets);
      updatedSets[setIndex] = ExerciseSet(
        setNumber: updatedSets[setIndex].setNumber,
        reps: reps ?? updatedSets[setIndex].reps,
        weight: weight ?? updatedSets[setIndex].weight,
        isCompleted: isCompleted ?? updatedSets[setIndex].isCompleted,
        type: updatedSets[setIndex].type,
      );
      exercises[exerciseIndex] = Exercise(
        id: exercises[exerciseIndex].id,
        name: exercises[exerciseIndex].name,
        category: exercises[exerciseIndex].category,
        sets: updatedSets,
        notes: exercises[exerciseIndex].notes,
        restTime: exercises[exerciseIndex].restTime,
      );
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final currentSets = exercises[exerciseIndex].sets;
      final newSetNumber = currentSets.isNotEmpty ? currentSets.last.setNumber + 1 : 1;
      final newSet = ExerciseSet(
        setNumber: newSetNumber,
        reps: 0,
        weight: 0,
        isCompleted: false,
        type: SetType.normal,
      );
      final updatedSets = List<ExerciseSet>.from(currentSets)..add(newSet);
      exercises[exerciseIndex] = Exercise(
        id: exercises[exerciseIndex].id,
        name: exercises[exerciseIndex].name,
        category: exercises[exerciseIndex].category,
        sets: updatedSets,
        notes: exercises[exerciseIndex].notes,
        restTime: exercises[exerciseIndex].restTime,
      );
    });
  }

  void _addExercise() {
    setState(() {
      exercises.add(
        Exercise(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'New Exercise',
          category: 'Custom',
          sets: [],
        ),
      );
    });
  }

  Color _getSetTypeColor(SetType type) {
    switch (type) {
      case SetType.normal:
        return AppTheme.primaryColor;
      case SetType.warmup:
        return Colors.blueGrey;
      case SetType.dropset:
        return Colors.orange;
      case SetType.failure:
        return AppTheme.errorColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workoutName.isEmpty ? 'New Workout' : workoutName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${elapsedTime.inHours.toString().padLeft(2, '0')}:'
              '${(elapsedTime.inMinutes % 60).toString().padLeft(2, '0')}:'
              '${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showWorkoutOptions,
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildWorkoutHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length + 1,
              itemBuilder: (context, index) {
                if (index == exercises.length) {
                  return _buildAddExerciseButton();
                }
                return _buildExerciseCard(exercises[index], index);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildWorkoutControls(),
    );
  }

  Widget _buildWorkoutHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Workout',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedType.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fitness_center, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${exercises.length} exercises',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, int exerciseIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        exercise.category,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showExerciseOptions(exerciseIndex),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(
                        width: 40,
                        child: Text('SET',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12))),
                    const Expanded(
                        child: Text('REPS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12))),
                    const Expanded(
                        child: Text('WEIGHT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12))),
                    const SizedBox(
                        width: 40,
                        child: Text('✓',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                ),
                const SizedBox(height: 8),
                ...exercise.sets.asMap().entries.map((entry) {
                  final setIndex = entry.key;
                  final set = entry.value;
                  return _buildSetRow(exerciseIndex, setIndex, set);
                }).toList(),
                const SizedBox(height: 8),
                _buildAddSetButton(exerciseIndex),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int exerciseIndex, int setIndex, ExerciseSet set) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: set.isCompleted
            ? AppTheme.accentColor.withOpacity(0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: set.isCompleted ? AppTheme.accentColor : Colors.grey[300]!,
          width: set.isCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getSetTypeColor(set.type),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    set.setNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              initialValue: set.reps.toString(),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) =>
                  _updateSet(exerciseIndex, setIndex, reps: int.tryParse(value)),
            ),
          ),
          Expanded(
            child: TextFormField(
              initialValue: set.weight.toString(),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) => _updateSet(exerciseIndex, setIndex,
                  weight: double.tryParse(value)),
            ),
          ),
          SizedBox(
            width: 40,
            child: Checkbox(
              value: set.isCompleted,
              onChanged: (value) =>
                  _updateSet(exerciseIndex, setIndex, isCompleted: value),
              activeColor: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSetButton(int exerciseIndex) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _addSet(exerciseIndex),
        icon: const Icon(Icons.add),
        label: const Text('Add Set'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
          foregroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildAddExerciseButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _addExercise,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Exercise',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Implement end workout logic
                  timer?.cancel();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Workout Ended!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'End Workout',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                // Implement pause/resume logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.pause, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}