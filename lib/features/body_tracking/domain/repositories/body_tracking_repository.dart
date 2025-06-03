/// Abstract interface for body tracking data operations.
///
/// Defines methods for logging and retrieving body statistics.
abstract class BodyTrackingRepository {
  /// Logs body [stats] for a specific [userId].
  ///
  /// The [stats] map should contain details like weight, measurements, etc.
  Future<void> logBodyStats(String userId, Map<String, dynamic> stats);

  /// Retrieves a list of body statistics logged by a [userId].
  Future<List<Map<String, dynamic>>> getBodyStats(String userId);
}
