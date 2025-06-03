import '../repositories/auth_repository.dart';
import '../../../../core/models/user_model.dart'; // Ensure this path is correct

/// Use case for signing up a new user.
///
/// This class encapsulates the business logic for user registration.
class SignUpUseCase {
  final AuthRepository repository;

  /// Constructs a [SignUpUseCase] with the given [repository].
  SignUpUseCase(this.repository);

  /// Executes the sign-up operation.
  ///
  /// Takes [email], [password], and [name] as input and returns a [UserModel]
  /// upon successful registration.
  Future<UserModel> call(String email, String password, String name) {
    return repository.signUp(email, password, name);
  }
}
