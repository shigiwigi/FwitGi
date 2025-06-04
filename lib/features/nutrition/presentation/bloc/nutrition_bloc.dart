// lib/features/nutrition/presentation/bloc/nutrition_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Import events and states from their dedicated files
import './nutrition_event.dart'; // <-- Ensure this imports events
import './nutrition_state.dart';

import '../../domain/repositories/nutrition_repository.dart';

class NutritionBloc extends Bloc<NutritionEvent, NutritionState> {
  final NutritionRepository repository;

  NutritionBloc(this.repository) : super(NutritionInitial()) {
    on<LogMealEvent>(_onLogMeal);
    on<LoadDailyNutritionEvent>(_onLoadDailyNutrition);
  }

  Future<void> _onLogMeal(
    LogMealEvent event,
    Emitter<NutritionState> emit,
  ) async {
    try {
      await repository.logMeal(event.userId, event.meal);
      add(LoadDailyNutritionEvent(userId: event.userId, date: DateTime.now()));
    } catch (e) {
      emit(NutritionError(e.toString()));
    }
  }

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