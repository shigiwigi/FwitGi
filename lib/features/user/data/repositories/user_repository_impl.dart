// lib/features/user/data/repositories/user_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../../../../core/config/app_config.dart'; // Import AppConfig
import '../../../../core/models/user_model.dart'; // Import UserModel
import '../../domain/repositories/user_repository.dart';

/// Concrete implementation of [UserRepository] using Firestore.
class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConfig.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('User with ID $userId not found.');
      }

      return UserModel.fromJson({
        'id': userId,
        ...doc.data()!,
      });
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConfig.usersCollection)
          .doc(user.id)
          .update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(AppConfig.usersCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }
}