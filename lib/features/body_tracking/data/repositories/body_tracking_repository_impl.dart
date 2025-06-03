import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/repositories/body_tracking_repository.dart';

/// Concrete implementation of [BodyTrackingRepository] using Firestore.
class BodyTrackingRepositoryImpl implements BodyTrackingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> logBodyStats(String userId, Map<String, dynamic> stats) async {
    try {
      await _firestore.collection(AppConfig.bodyTrackingCollection).add({
        'userId': userId,
        'timestamp': Timestamp.now(),
        ...stats,
      });
    } catch (e) {
      throw Exception('Failed to log body stats: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBodyStats(String userId) async {
    try {
      final query = await _firestore
          .collection(AppConfig.bodyTrackingCollection)
          .where('userId', isEqualTo: userId)
          // .orderBy('timestamp', descending: true) // Removed orderBy to avoid index issues
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get body stats: ${e.toString()}');
    }
  }
}
