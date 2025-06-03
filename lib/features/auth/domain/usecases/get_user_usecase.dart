import '../repositories/auth_repository.dart';
import '../../../../core/models/user_model.dart'; // Ensure this path is correct

/// Use case for retrieving the current authenticated user.
///
/// This class encapsulates the business logic for fetching user information.
class GetUserUseCase {
  final AuthRepository repository;

  /// Constructs a [GetUserUseCase] with the given [repository].
  GetUserUseCase(this.repository);

  /// Executes the get user operation.
  ///
  /// Returns a [UserModel] if a user is authenticated, otherwise `null`.
  Future<UserModel?> call() {
    return repository.getCurrentUser();
  }
}
