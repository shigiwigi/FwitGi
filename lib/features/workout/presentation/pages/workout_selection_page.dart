// lib/features/workout/presentation/pages/workout_selection_page.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fwitgi_app/core/di/dependency_injection.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fwitgi_app/features/workout/domain/entities/workout.dart';
import 'package:fwitgi_app/features/workout/presentation/pages/workout_session_page.dart';
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_state.dart';


// MOVE _TemplateGroup CLASS HERE (TO TOP-LEVEL)
class _TemplateGroup {
  final String name;
  final String description;
  final List<Workout> templates;
  bool isExpanded; // To manage the ExpansionTile's initial state

  _TemplateGroup({required this.name, this.description = '', required this.templates, this.isExpanded = false});
}


class WorkoutSelectionPage extends StatefulWidget {
  const WorkoutSelectionPage({Key? key}) : super(key: key);

  @override
  State<WorkoutSelectionPage> createState() => _WorkoutSelectionPageState();
}

class _WorkoutSelectionPageState extends State<WorkoutSelectionPage> {
  late WorkoutBloc _workoutBloc;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _workoutBloc = getlt<WorkoutBloc>();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
      _workoutBloc.add(LoadWorkoutTemplates(_currentUserId!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated. Cannot load templates.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start New Workout'),
      ),
      body: BlocBuilder<WorkoutBloc, WorkoutState>(
        bloc: _workoutBloc,
        builder: (context, state) {
          if (state is WorkoutLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkoutError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is WorkoutLoaded) {
            // Group templates
            final Map<String, List<Workout>> groupedTemplatesMap = {};

            // Populate groupedTemplatesMap based on template names or types
            for (var template in state.workoutTemplates) {
              if (template.name.startsWith('Beginner Full Body')) {
                groupedTemplatesMap.putIfAbsent('Beginner Full Body Programs', () => []).add(template);
              } else if (template.type == WorkoutType.push || template.type == WorkoutType.pull || template.type == WorkoutType.legs) {
                groupedTemplatesMap.putIfAbsent('Push/Pull/Legs Split', () => []).add(template);
              } else {
                groupedTemplatesMap.putIfAbsent('Other Templates', () => []).add(template);
              }
            }

            // Convert map to a list of _TemplateGroup objects
            final List<_TemplateGroup> templateGroups = groupedTemplatesMap.entries.map((entry) {
              return _TemplateGroup(name: entry.key, templates: entry.value);
            }).toList();

            // Sort individual templates within groups by name
            for (var group in templateGroups) {
                group.templates.sort((a, b) => a.name.compareTo(b.name));
            }
            // Sort groups for consistent display (e.g., alphabetically)
            templateGroups.sort((a, b) => a.name.compareTo(b.name));


            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Choose a Template',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: templateGroups.length,
                    itemBuilder: (context, groupIndex) {
                      final group = templateGroups[groupIndex];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ExpansionTile(
                          title: Text(group.name, style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text('${group.templates.length} templates'),
                          initiallyExpanded: group.isExpanded,
                          onExpansionChanged: (bool expanded) {
                            setState(() {
                              group.isExpanded = expanded;
                            });
                          },
                          children: group.templates.map((workout) {
                            return _buildTemplateListTile(context, workout, _currentUserId);
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _currentUserId == null ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WorkoutSessionPage(userId: _currentUserId)),
                      );
                    },
                    child: const Text('Start Empty Workout'),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('No workout templates available.'));
        },
      ),
    );
  }

  // Helper function to build individual template list tiles within expansion panels
  Widget _buildTemplateListTile(BuildContext context, Workout workout, String? currentUserId) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), // Adjusted padding for nested look
      title: Text(workout.name),
      subtitle: Text(
        '${workout.exercises.length} exercises', // Simplified subtitle for templates
      ),
      trailing: IconButton(
        icon: const Icon(Icons.play_arrow),
        onPressed: currentUserId == null ? null : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutSessionPage(
                workoutTemplateId: workout.id,
                userId: currentUserId!,
              ),
            ),
          );
        },
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tapped on template ${workout.name}')),
        );
      },
    );
  }
}