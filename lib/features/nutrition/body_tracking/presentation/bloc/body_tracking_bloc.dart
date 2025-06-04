// lib/features/body_tracking/presentation/bloc/body_tracking_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Import events and states from their dedicated files
// Note: The event file is currently in an unusual path.
import 'package:fwitgi_app/features/nutrition/body_tracking/presentation/bloc/body_tracking_event.dart';
import './body_tracking_state.dart'; // Already correctly importing state

import '../../domain/repositories/body_tracking_repository.dart';

// BLoC for managing body tracking-related states and events.
class BodyTrackingBloc extends Bloc<BodyTrackingEvent, BodyTrackingState> {
  final BodyTrackingRepository repository;

  // Constructs a [BodyTrackingBloc] with the given [repository].
  BodyTrackingBloc(this.repository) : super(BodyTrackingInitial()) {
    on<LogBodyStatsEvent>(_onLogBodyStats);
    on<LoadBodyStatsEvent>(_onLoadBodyStats);
  }

  // Handles the [LogBodyStatsEvent].
  Future<void> _onLogBodyStats(
    LogBodyStatsEvent event,
    Emitter<BodyTrackingState> emit,
  ) async {
    try {
      await repository.logBodyStats(event.userId, event.stats);
      add(LoadBodyStatsEvent(event.userId));
    } catch (e) {
      emit(BodyTrackingError(e.toString()));
    }
  }

  // Handles the [LoadBodyStatsEvent].
  Future<void> _onLoadBodyStats(
    LoadBodyStatsEvent event,
    Emitter<BodyTrackingState> emit,
  ) async {
    emit(BodyTrackingLoading());
    try {
      final stats = await repository.getBodyStats(event.userId);
      emit(BodyTrackingLoaded(stats));
    } catch (e) {
      emit(BodyTrackingError(e.toString()));
    }
  }
}