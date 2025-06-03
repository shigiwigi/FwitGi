 import 'package:flutter_bloc/flutter_bloc.dart';

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
      }

      @override
      void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
        print('BLOC DEBUG: onError -- ${bloc.runtimeType} -- $error');
        super.onError(bloc, error, stackTrace);
      }
    }