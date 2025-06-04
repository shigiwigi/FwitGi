// lib/features/workout/presentation/pages/workout_session_page.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fwitgi_app/core/di/dependency_injection.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/workout.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/repositories/exercise_definition_repository.dart';
import '../../domain/entities/exercise_definition.dart';


class SessionExerciseDisplayData extends Equatable {
  final WorkoutExercise workoutExercise;
  final ExerciseDefinition exerciseDefinition;

  const SessionExerciseDisplayData({
    required this.workoutExercise,
    required this.exerciseDefinition,
  });

  @override
  List<Object?> get props => [workoutExercise, exerciseDefinition];
}


class WorkoutSessionPage extends StatefulWidget {
  final String? workoutTemplateId;
  final String? userId;

  const WorkoutSessionPage({Key? key, this.workoutTemplateId, this.userId}) : super(key: key);

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  final Uuid _uuid = const Uuid();
  late String _currentWorkoutId;
  late DateTime startTime;
  Duration elapsedTime = Duration.zero;
  Timer? timer;
  List<SessionExerciseDisplayData> exercises = [];
  String workoutName = '';
  WorkoutType selectedType = WorkoutType.push;
  bool _isPaused = false;

  late WorkoutBloc _workoutBloc;
  late WorkoutRepository _workoutRepository;
  late ExerciseDefinitionRepository _exerciseDefinitionRepository;
  String? _currentUserId;

  late TextEditingController _workoutNameController;

  @override
  void initState() {
    super.initState();
    _workoutBloc = getlt<WorkoutBloc>();
    _workoutRepository = getlt<WorkoutRepository>();
    _exerciseDefinitionRepository = getlt<ExerciseDefinitionRepository>();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
    } else {
      _currentUserId = widget.userId ?? 'anonymous_user';
      if (widget.userId == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Warning: User not authenticated for workout saving. Workout will be saved as anonymous.')),
          );
        });
      }
    }

    _currentWorkoutId = _uuid.v4();
    startTime = DateTime.now();
    _startTimer();
    _initializeWorkoutSession();

    _workoutNameController = TextEditingController(text: workoutName);
    _workoutNameController.addListener(_updateWorkoutNameFromController);
  }

  @override
  void dispose() {
    timer?.cancel();
    _workoutNameController.removeListener(_updateWorkoutNameFromController);
    _workoutNameController.dispose();
    super.dispose();
  }

  void _updateWorkoutNameFromController() {
    setState(() {
      workoutName = _workoutNameController.text;
    });
  }

  void _startTimer() {
    if (timer != null && timer!.isActive) return;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          elapsedTime = DateTime.now().difference(startTime);
        });
      }
    });
  }

  void _stopTimer() {
    timer?.cancel();
  }

  void _togglePauseResume() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _stopTimer();
      } else {
        startTime = DateTime.now().subtract(elapsedTime);
        _startTimer();
      }
    });
  }

  Future<void> _initializeWorkoutSession() async {
    if (widget.workoutTemplateId != null) {
      try {
        final List<Workout> templates = await _workoutRepository.getWorkoutTemplates();
        final Workout? template = templates.any((t) => t.id == widget.workoutTemplateId)
            ? templates.firstWhereOrNull((t) => t.id == widget.workoutTemplateId)
            : null;

        if (template != null) {
          final List<ExerciseDefinition> allExerciseDefinitions = await _exerciseDefinitionRepository.getExerciseDefinitions();

          List<SessionExerciseDisplayData> sessionExercises = [];
          for (var woExercise in template.exercises) {
            final ExerciseDefinition? def = allExerciseDefinitions.firstWhereOrNull(
              (def) => def.id == woExercise.exerciseDefinitionId,
            );
            if (def != null) {
              sessionExercises.add(
                SessionExerciseDisplayData(
                  workoutExercise: WorkoutExercise(
                    id: _uuid.v4(),
                    exerciseDefinitionId: woExercise.exerciseDefinitionId,
                    sets: woExercise.sets.map((s) => ExerciseSet(
                      setNumber: s.setNumber,
                      reps: s.reps,
                      weight: s.weight,
                      isCompleted: false,
                      type: s.type,
                    )).toList(),
                    notes: woExercise.notes,
                    restTime: woExercise.restTime,
                  ),
                  exerciseDefinition: def,
                ),
              );
            } else {
              print('Warning: ExerciseDefinition not found for ID: ${woExercise.exerciseDefinitionId}');
              sessionExercises.add(
                SessionExerciseDisplayData(
                  workoutExercise: WorkoutExercise(
                    id: _uuid.v4(),
                    exerciseDefinitionId: woExercise.exerciseDefinitionId,
                    sets: woExercise.sets.map((s) => ExerciseSet(
                      setNumber: s.setNumber,
                      reps: s.reps,
                      weight: s.weight,
                      isCompleted: false,
                      type: s.type,
                    )).toList(),
                    notes: woExercise.notes,
                    restTime: woExercise.restTime,
                  ),
                  exerciseDefinition: ExerciseDefinition(id: woExercise.exerciseDefinitionId, name: 'Unknown Exercise', category: 'N/A'),
                ),
              );
            }
          }

          setState(() {
            workoutName = template.name;
            _workoutNameController.text = template.name;
            selectedType = template.type;
            exercises = sessionExercises;
          });
        }
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load workout template: ${e.toString()}')),
          );
        });
        setState(() {
          workoutName = 'New Workout Session';
          _workoutNameController.text = workoutName;
          selectedType = WorkoutType.custom;
          exercises = [];
        });
      }
    } else {
      setState(() {
        workoutName = 'New Workout Session';
        _workoutNameController.text = workoutName;
        selectedType = WorkoutType.custom;
        exercises = [];
      });
    }
  }


  void _showWorkoutOptions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout Options Tapped')),
    );
  }

  void _deleteExercise(int exerciseIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise?'),
        content: Text('Are you sure you want to delete "${exercises[exerciseIndex].exerciseDefinition.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                exercises.removeAt(exerciseIndex);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exercise deleted.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteSet(int exerciseIndex, int setIndex) {
    setState(() {
      final updatedSets = List<ExerciseSet>.from(exercises[exerciseIndex].workoutExercise.sets);
      if (updatedSets.length > 1) {
        updatedSets.removeAt(setIndex);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot delete the last set. Delete the exercise instead.')),
        );
        return;
      }

      exercises[exerciseIndex] = SessionExerciseDisplayData(
        workoutExercise: exercises[exerciseIndex].workoutExercise.copyWith(sets: updatedSets),
        exerciseDefinition: exercises[exerciseIndex].exerciseDefinition,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Set deleted.')),
    );
  }


  void _updateSet(int exerciseIndex, int setIndex,
      {int? reps, double? weight, bool? isCompleted}) {
    setState(() {
      final currentWorkoutExercise = exercises[exerciseIndex].workoutExercise;
      final updatedSets = List<ExerciseSet>.from(currentWorkoutExercise.sets);
      updatedSets[setIndex] = ExerciseSet(
        setNumber: updatedSets[setIndex].setNumber,
        reps: reps ?? updatedSets[setIndex].reps,
        weight: weight ?? updatedSets[setIndex].weight,
        isCompleted: isCompleted ?? updatedSets[setIndex].isCompleted,
        type: updatedSets[setIndex].type,
      );

      exercises[exerciseIndex] = SessionExerciseDisplayData(
        workoutExercise: currentWorkoutExercise.copyWith(sets: updatedSets),
        exerciseDefinition: exercises[exerciseIndex].exerciseDefinition,
      );
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final currentWorkoutExercise = exercises[exerciseIndex].workoutExercise;
      final currentSets = currentWorkoutExercise.sets;
      final newSetNumber = currentSets.isNotEmpty ? currentSets.last.setNumber + 1 : 1;
      final newSet = ExerciseSet(
        setNumber: newSetNumber,
        reps: 0,
        weight: 0.0,
        isCompleted: false,
        type: SetType.normal,
      );
      final updatedSets = List<ExerciseSet>.from(currentSets)..add(newSet);
      exercises[exerciseIndex] = SessionExerciseDisplayData(
        workoutExercise: currentWorkoutExercise.copyWith(sets: updatedSets),
        exerciseDefinition: exercises[exerciseIndex].exerciseDefinition,
      );
    });
  }

  void _addExercise() {
    setState(() {
      final String newExerciseDefId = _uuid.v4();
      exercises.add(
        SessionExerciseDisplayData(
          workoutExercise: WorkoutExercise(
            id: _uuid.v4(),
            exerciseDefinitionId: newExerciseDefId,
            sets: [
              ExerciseSet(setNumber: 1, reps: 0, weight: 0.0, isCompleted: false, type: SetType.normal),
            ],
            notes: null,
            restTime: null,
          ),
          exerciseDefinition: ExerciseDefinition(
            id: newExerciseDefId,
            name: 'New Custom Exercise',
            category: 'Custom',
            measurementType: ExerciseMeasurementType.reps,
          ),
        ),
      );
    });
  }

  // Re-added the missing _buildAddExerciseButton method
  Widget _buildAddExerciseButton(BuildContext context) {
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

  // Re-added the missing _buildExerciseCard method
  Widget _buildExerciseCard(BuildContext context, SessionExerciseDisplayData sessionExercise, int exerciseIndex) {
    final ExerciseDefinition exerciseDef = sessionExercise.exerciseDefinition;
    final WorkoutExercise workoutEx = sessionExercise.workoutExercise;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                        exerciseDef.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        exerciseDef.category,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                  onPressed: () => _deleteExercise(exerciseIndex),
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
                    Expanded(
                        child: Text(
                            exerciseDef.measurementType == ExerciseMeasurementType.time ? 'TIME' : 'REPS',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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
                    const SizedBox(
                        width: 40,
                        child: Text('',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                ),
                const SizedBox(height: 8),
                ...workoutEx.sets.asMap().entries.map((entry) {
                  final setIndex = entry.key;
                  final set = entry.value;
                  return _buildSetRow(context, exerciseIndex, setIndex, set, exerciseDef.measurementType);
                }).toList(),
                const SizedBox(height: 8),
                _buildAddSetButton(context, exerciseIndex),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Re-added the missing _buildSetRow method
  Widget _buildSetRow(BuildContext context, int exerciseIndex, int setIndex, ExerciseSet set, ExerciseMeasurementType measurementType) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: set.isCompleted
            ? AppTheme.accentColor.withOpacity(0.1)
            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: set.isCompleted ? AppTheme.accentColor : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
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
            child: measurementType == ExerciseMeasurementType.reps
                ? TextFormField(
                    initialValue: set.reps.toString(),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                      ),
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    onChanged: (value) =>
                        _updateSet(exerciseIndex, setIndex, reps: int.tryParse(value)),
                  )
                : Text(
                    '${set.reps} ${measurementType == ExerciseMeasurementType.time ? 's' : ''}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
          ),
          Expanded(
            child: TextFormField(
              initialValue: set.weight.toString(),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                ),
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: true,
                fillColor: Colors.transparent,
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
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              onPressed: () => _deleteSet(exerciseIndex, setIndex),
            ),
          ),
        ],
      ),
    );
  }

  // Re-added the missing _buildAddSetButton method
  Widget _buildAddSetButton(BuildContext context, int exerciseIndex) {
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

  double _calculateExerciseTotalWeight(SessionExerciseDisplayData sessionExercise) {
    return sessionExercise.workoutExercise.sets.fold(0.0, (sum, set) => sum + (set.reps * set.weight));
  }

  int _calculateExerciseTotalSets(SessionExerciseDisplayData sessionExercise) {
    return sessionExercise.workoutExercise.sets.length;
  }

  int _calculateExerciseTotalReps(SessionExerciseDisplayData sessionExercise) {
    return sessionExercise.workoutExercise.sets.fold(0, (sum, set) => sum + set.reps);
  }

  double _calculateWorkoutTotalWeight() {
    return exercises.fold(0.0, (sum, sessionExercise) => sum + _calculateExerciseTotalWeight(sessionExercise));
  }

  int _calculateWorkoutTotalSets() {
    return exercises.fold(0, (sum, sessionExercise) => sum + _calculateExerciseTotalSets(sessionExercise));
  }

  int _calculateWorkoutTotalReps() {
    return exercises.fold(0, (sum, sessionExercise) => sum + _calculateExerciseTotalReps(sessionExercise));
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
            TextFormField(
              controller: _workoutNameController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1,
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
          _buildWorkoutSummary(context),
          _buildWorkoutHeader(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length + 1,
              itemBuilder: (context, index) {
                if (index == exercises.length) {
                  return _buildAddExerciseButton(context);
                }
                return _buildExerciseCard(context, exercises[index], index);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildWorkoutControls(context),
    );
  }


  Widget _buildWorkoutSummary(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Weight', '${_calculateWorkoutTotalWeight().toStringAsFixed(1)} kg'),
          _buildStatItem('Total Sets', '${_calculateWorkoutTotalSets()}'),
          _buildStatItem('Total Reps', '${_calculateWorkoutTotalReps()}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }


  Widget _buildWorkoutHeader(BuildContext context) {
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

  Widget _buildWorkoutControls(BuildContext context) {
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
                onPressed: () async {
                  _stopTimer();

                  final List<WorkoutExercise> exercisesToSave = exercises.map((e) => e.workoutExercise).toList();

                  double totalWeightLifted = exercisesToSave.fold(0.0, (sum, woExercise) => sum + woExercise.sets.fold(0.0, (setSum, set) => setSum + (set.reps * set.weight)));
                  int totalSets = exercisesToSave.fold(0, (sum, woExercise) => sum + woExercise.sets.length);
                  int totalReps = exercisesToSave.fold(0, (sum, woExercise) => sum + woExercise.sets.fold(0, (setSum, set) => setSum + set.reps));

                  final workout = Workout(
                    id: _currentWorkoutId,
                    userId: _currentUserId!,
                    name: workoutName.isNotEmpty ? workoutName : 'Untitled Workout',
                    type: selectedType,
                    exercises: exercisesToSave,
                    startTime: startTime,
                    endTime: DateTime.now(),
                    duration: elapsedTime,
                    notes: null,
                    totalWeight: totalWeightLifted,
                    totalSets: totalSets,
                    totalReps: totalReps,
                  );

                  _workoutBloc.add(SaveWorkout(workout));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Workout Ended and Saved!')),
                  );
                  Navigator.of(context).pop();
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
              onPressed: _togglePauseResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPaused ? AppTheme.primaryColor : Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Icon(
                _isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

extension WorkoutExerciseCopyWith on WorkoutExercise {
  WorkoutExercise copyWith({
    String? id,
    String? exerciseDefinitionId,
    List<ExerciseSet>? sets,
    String? notes,
    Duration? restTime,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      exerciseDefinitionId: exerciseDefinitionId ?? this.exerciseDefinitionId,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      restTime: restTime ?? this.restTime,
    );
  }
}