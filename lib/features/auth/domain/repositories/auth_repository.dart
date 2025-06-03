import '../../../../core/models/user_model.dart';

/// Abstract interface for authentication operations.
///
/// This defines the contract for any authentication repository
/// implementation, ensuring consistency across different data sources
/// (e.g., Firebase, custom backend).
abstract class AuthRepository {
  /// Signs in a user with the given [email] and [password].
  ///
  /// Throws an [Exception] if sign-in fails.
  Future<UserModel> signIn(String email, String password);

  /// Signs up a new user with the given [email], [password], and [name].
  ///
  /// Throws an [Exception] if sign-up fails.
  Future<UserModel> signUp(String email, String password, String name);

  /// Signs out the currently authenticated user.
  ///
  /// Throws an [Exception] if sign-out fails.
  Future<void> signOut();

  /// Retrieves the currently authenticated user.
  ///
  /// Returns `null` if no user is authenticated.
  Future<UserModel?> getCurrentUser();
}
