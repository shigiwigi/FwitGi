// lib/features/auth/presentation/bloc/auth_state.dart

import 'package:equatable/equatable.dart'; // Make sure this is imported
import 'package:meta/meta.dart'; // Make sure this is imported if you use @immutable
import 'package:fwitgi_app/core/models/user_model.dart'; // Make sure your UserModel is imported here

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user; // Ensure UserModel is correctly imported above
  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

// Define AuthSuccess if you want a distinct success state before Authenticated
// If your BLoC directly emits AuthAuthenticated on success, you might not need this.
// For consistency with previous suggestions, let's keep it but know AuthAuthenticated is final success.
class AuthSuccess extends AuthState {
  final String message;
  const AuthSuccess({this.message = 'Authentication successful'});

  @override
  List<Object> get props => [message];
}

// Renamed from AuthError to AuthFailure for consistency
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}