import '../repositories/auth_repository.dart';

/// Use case for signing out a user.
///
/// This class encapsulates the business logic for user sign-out.
class SignOutUseCase {
  final AuthRepository repository;

  /// Constructs a [SignOutUseCase] with the given [repository].
  SignOutUseCase(this.repository);

  /// Executes the sign-out operation.
  Future<void> call() {
    return repository.signOut();
  }
}
