// lib/features/nutrition/presentation/bloc/nutrition_state.dart

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

// Assuming you might need to represent meals or daily summary objects here
// For now, these are the basic states as implied by NutritionBloc

@immutable
abstract class NutritionState extends Equatable {
  const NutritionState();

  @override
  List<Object> get props => [];
}

class NutritionInitial extends NutritionState {}
class NutritionLoading extends NutritionState {}
class NutritionLoaded extends NutritionState {
  final Map<String, double> dailySummary;
  final List<Map<String, dynamic>> meals; // Assuming meals are returned as list of maps
  const NutritionLoaded({required this.dailySummary, required this.meals});

  @override
  List<Object> get props => [dailySummary, meals];
}
class NutritionError extends NutritionState {
  final String message;
  const NutritionError(this.message);

  @override
  List<Object> get props => [message];
}