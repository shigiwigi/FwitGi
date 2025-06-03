/// Abstract interface for nutrition data operations.
///
/// Defines methods for logging meals and retrieving nutrition data.
abstract class NutritionRepository {
  /// Logs a [meal] for a specific [userId].
  ///
  /// The [meal] map should contain details like calories, protein, etc.
  Future<void> logMeal(String userId, Map<String, dynamic> meal);

  /// Retrieves a list of meals logged by a [userId] for a specific [date].
  Future<List<Map<String, dynamic>>> getMeals(String userId, DateTime date);

  /// Calculates and retrieves daily nutrition totals (calories, protein, etc.)
  /// for a [userId] on a specific [date].
  Future<Map<String, double>> getDailyNutrition(String userId, DateTime date);
}
