// lib/features/body_tracking/presentation/bloc/body_tracking_state.dart

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
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