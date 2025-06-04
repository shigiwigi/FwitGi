// lib/features/user/domain/repositories/user_repository.dart
import '../../../../core/models/user_model.dart'; // Ensure this path is correct

/// Abstract interface for user data operations.
///
/// This defines the contract for managing user profiles,
/// separate from authentication concerns.
abstract class UserRepository {
  /// Retrieves a user model by their [userId].
  ///
  /// Throws an [Exception] if the user is not found or retrieval fails.
  Future<UserModel> getUser(String userId);

  /// Updates an existing [user] model.
  ///
  /// Throws an [Exception] if the update fails.
  Future<void> updateUser(UserModel user);

  /// Deletes a user by their [userId].
  ///
  /// Throws an [Exception] if deletion fails.
  Future<void> deleteUser(String userId);
}