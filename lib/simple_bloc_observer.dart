// lib/simple_bloc_observer.dart

 import 'package:flutter_bloc/flutter_bloc.dart';
 import 'package:fwitgi_app/features/workout/presentation/bloc/workout_bloc.dart'; // Import your WorkoutBloc to access its states

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

        // Add detailed logging for WorkoutBloc state changes
        if (bloc is WorkoutBloc) {
          if (transition.nextState is WorkoutLoaded) {
            final workoutLoadedState = transition.nextState as WorkoutLoaded;
            print('WORKOUT BLOC DEBUG: WorkoutLoaded State Details:');
            print('  Workouts count: ${workoutLoadedState.workouts.length}');
            print('  Workout Summary: ${workoutLoadedState.workoutSummary}');
            print('  Templates count: ${workoutLoadedState.workoutTemplates.length}'); // Corrected access
          }
        }
      }

      @override
      void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
        print('BLOC DEBUG: onError -- ${bloc.runtimeType} -- $error');
        super.onError(bloc, error, stackTrace);
      }
    }