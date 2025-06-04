// lib/features/nutrition/data/repositories/nutrition_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../../../../core/config/app_config.dart'; // Import AppConfig
import '../../domain/repositories/nutrition_repository.dart';

/// Concrete implementation of [NutritionRepository] using Firestore.
class NutritionRepositoryImpl implements NutritionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> logMeal(String userId, Map<String, dynamic> meal) async {
    try {
      await _firestore.collection(AppConfig.nutritionCollection).add({
        'userId': userId,
        'timestamp': Timestamp.now(),
        ...meal,
      });
    } catch (e) {
      throw Exception('Failed to log meal: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMeals(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final query = await _firestore
          .collection(AppConfig.nutritionCollection)
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get meals: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, double>> getDailyNutrition(String userId, DateTime date) async {
    try {
      final meals = await getMeals(userId, date);

      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (final meal in meals) {
        totalCalories += meal['calories']?.toDouble() ?? 0;
        totalProtein += meal['protein']?.toDouble() ?? 0;
        totalCarbs += meal['carbs']?.toDouble() ?? 0;
        totalFat += meal['fat']?.toDouble() ?? 0;
      }

      return {
        'calories': totalCalories,
        'protein': totalProtein,
        'carbs': totalCarbs,
        'fat': totalFat,
      };
    } catch (e) {
      throw Exception('Failed to get daily nutrition: ${e.toString()}');
    }
  }
}