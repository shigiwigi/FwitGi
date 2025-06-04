// lib/simple_bloc_observer.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_state.dart'; // <-- ADD THIS IMPORT

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('BLOC DEBUG: onEvent -- ${bloc.runtimeType} -- $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('BLOC DEBUG: onTransition -- ${bloc.runtimeType} -- from ${transition.currentState} to ${transition.nextState}');

    if (bloc is WorkoutBloc) {
      if (transition.nextState is WorkoutLoaded) { // Now WorkoutLoaded type should be recognized
        final workoutLoadedState = transition.nextState as WorkoutLoaded;
        print('WORKOUT BLOC DEBUG: WorkoutLoaded State Details:');
        print('  Workouts count: ${workoutLoadedState.workouts.length}');
        print('  Workout Summary: ${workoutLoadedState.workoutSummary}');
        print('  Templates count: ${workoutLoadedState.workoutTemplates.length}');
      }
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('BLOC DEBUG: onError -- ${bloc.runtimeType} -- $error');
    super.onError(bloc, error, stackTrace);
  }
}