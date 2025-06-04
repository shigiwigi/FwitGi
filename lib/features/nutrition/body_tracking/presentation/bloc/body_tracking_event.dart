// lib/features/body_tracking/presentation/bloc/body_tracking_event.dart

import 'package:equatable/equatable.dart';

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