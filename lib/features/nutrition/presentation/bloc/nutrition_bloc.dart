import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/repositories/nutrition_repository.dart';
import 'package:fwitgi_app/features/nutrition/presentation/bloc/nutrition_state.dart'; // Import the new state file

// Nutrition Events
abstract class NutritionEvent extends Equatable {
  const NutritionEvent();
  @override
  List<Object> get props => [];
}

class LogMealEvent extends NutritionEvent {
  final String userId;
  final Map<String, dynamic> meal;
  const LogMealEvent({required this.userId, required this.meal});
  @override
  List<Object> get props => [userId, meal];
}

class LoadDailyNutritionEvent extends NutritionEvent {
  final String userId;
  final DateTime date;
  const LoadDailyNutritionEvent({required this.userId, required this.date});
  @override
  List<Object> get props => [userId, date];
}

// REMOVED: Nutrition States definitions are now in nutrition_state.dart
// abstract class NutritionState extends Equatable { ... }
// class NutritionInitial extends NutritionState { ... }
// class NutritionLoading extends NutritionState { ... }
// class NutritionLoaded extends NutritionState { ... }
// class NutritionError extends NutritionState { ... }


/// BLoC for managing nutrition-related states and events.
class NutritionBloc extends Bloc<NutritionEvent, NutritionState> {
  final NutritionRepository repository;

  /// Constructs a [NutritionBloc] with the given [repository].
  NutritionBloc(this.repository) : super(NutritionInitial()) {
    on<LogMealEvent>(_onLogMeal);
    on<LoadDailyNutritionEvent>(_onLoadDailyNutrition);
  }

  /// Handles the [LogMealEvent].
  Future<void> _onLogMeal(
    LogMealEvent event,
    Emitter<NutritionState> emit,
  ) async {
    try {
      await repository.logMeal(event.userId, event.meal);
      // Optionally, reload daily nutrition after logging a meal
      add(LoadDailyNutritionEvent(userId: event.userId, date: DateTime.now()));
    } catch (e) {
      emit(NutritionError(e.toString()));
    }
  }

  /// Handles the [LoadDailyNutritionEvent].
  Future<void> _onLoadDailyNutrition(
    LoadDailyNutritionEvent event,
    Emitter<NutritionState> emit,
  ) async {
    emit(NutritionLoading());
    try {
      final dailySummary = await repository.getDailyNutrition(event.userId, event.date);
      final meals = await repository.getMeals(event.userId, event.date);
      emit(NutritionLoaded(dailySummary: dailySummary, meals: meals));
    } catch (e) {
      emit(NutritionError(e.toString()));
    }
  }
}