import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/repositories/body_tracking_repository.dart';

// Body Tracking Events
abstract class BodyTrackingEvent extends Equatable {
  const BodyTrackingEvent();
  @override
  List<Object> get props => [];
}

class LogBodyStatsEvent extends BodyTrackingEvent {
  final String userId;
  final Map<String, dynamic> stats;
  const LogBodyStatsEvent({required this.userId, required this.stats});
  @override
  List<Object> get props => [userId, stats];
}

class LoadBodyStatsEvent extends BodyTrackingEvent {
  final String userId;
  const LoadBodyStatsEvent(this.userId);
  @override
  List<Object> get props => [userId];
}

// Body Tracking States
abstract class BodyTrackingState extends Equatable {
  const BodyTrackingState();
  @override
  List<Object> get props => [];
}

class BodyTrackingInitial extends BodyTrackingState {}
class BodyTrackingLoading extends BodyTrackingState {}
class BodyTrackingLoaded extends BodyTrackingState {
  final List<Map<String, dynamic>> statsHistory;
  const BodyTrackingLoaded(this.statsHistory);
  @override
  List<Object> get props => [statsHistory];
}
class BodyTrackingError extends BodyTrackingState {
  final String message;
  const BodyTrackingError(this.message);
  @override
  List<Object> get props => [message];
}

/// BLoC for managing body tracking-related states and events.
class BodyTrackingBloc extends Bloc<BodyTrackingEvent, BodyTrackingState> {
  final BodyTrackingRepository repository;

  /// Constructs a [BodyTrackingBloc] with the given [repository].
  BodyTrackingBloc(this.repository) : super(BodyTrackingInitial()) {
    on<LogBodyStatsEvent>(_onLogBodyStats);
    on<LoadBodyStatsEvent>(_onLoadBodyStats);
  }

  /// Handles the [LogBodyStatsEvent].
  Future<void> _onLogBodyStats(
    LogBodyStatsEvent event,
    Emitter<BodyTrackingState> emit,
  ) async {
    try {
      await repository.logBodyStats(event.userId, event.stats);
      // Optionally, reload body stats after logging
      add(LoadBodyStatsEvent(event.userId));
    } catch (e) {
      emit(BodyTrackingError(e.toString()));
    }
  }

  /// Handles the [LoadBodyStatsEvent].
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
