// lib/features/nutrition/presentation/bloc/nutrition_event.dart

import 'package:equatable/equatable.dart';

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