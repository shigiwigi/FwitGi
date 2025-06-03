import '../repositories/auth_repository.dart';
import '../../../../core/models/user_model.dart'; // Ensure this path is correct

/// Use case for signing in a user.
///
/// This class encapsulates the business logic for user sign-in,
/// abstracting away the underlying repository implementation.
class SignInUseCase {
  final AuthRepository repository;

  /// Constructs a [SignInUseCase] with the given [repository].
  SignInUseCase(this.repository);

  /// Executes the sign-in operation.
  ///
  /// Takes [email] and [password] as input and returns a [UserModel]
  /// upon successful sign-in.
  Future<UserModel> call(String email, String password) {
    return repository.signIn(email, password);
  }
}
