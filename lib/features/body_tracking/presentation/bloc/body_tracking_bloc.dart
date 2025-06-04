// lib/features/body_tracking/presentation/bloc/body_tracking_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Import events and states from their dedicated files
// The event file path is unusual but based on your project structure/error log.
import 'package:fwitgi_app/features/nutrition/body_tracking/presentation/bloc/body_tracking_event.dart';
import './body_tracking_state.dart';

import '../../domain/repositories/body_tracking_repository.dart';

class BodyTrackingBloc extends Bloc<BodyTrackingEvent, BodyTrackingState> {
  final BodyTrackingRepository repository;

  BodyTrackingBloc(this.repository) : super(BodyTrackingInitial()) {
    on<LogBodyStatsEvent>(_onLogBodyStats);
    on<LoadBodyStatsEvent>(_onLoadBodyStats);
  }

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