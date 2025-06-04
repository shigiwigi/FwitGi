// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

// Import your user model
import '../../../../core/models/user_model.dart';
// Import your use cases
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/get_user_usecase.dart';

// Import your Auth States from the dedicated file
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_state.dart'; // <--- Ensure this is here

// Auth Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

class SignOutRequested extends AuthEvent {}

// Auth Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetUserUseCase getUserUseCase;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getUserUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: AuthCheckRequested received. Emitting AuthLoading.');
    emit(AuthLoading());
    try {
      final user = await getUserUseCase();
      if (user != null) {
        print('AuthBloc: AuthCheck success. User authenticated: ${user.email}. Emitting AuthAuthenticated.');
        emit(AuthAuthenticated(user: user));
      } else {
        print('AuthBloc: AuthCheck failed. No user found. Emitting AuthUnauthenticated.');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('AuthBloc: AuthCheck failed with error: $e. Emitting AuthFailure.');
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: SignInRequested received for email: ${event.email}. Emitting AuthLoading.');
    emit(AuthLoading());
    try {
      final user = await signInUseCase(event.email, event.password);
      print('AuthBloc: SignIn successful. User authenticated: ${user.email}. Emitting AuthAuthenticated.');
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      print('AuthBloc: SignIn failed with error: $e. Emitting AuthFailure.');
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: SignUpRequested received for email: ${event.email}. Emitting AuthLoading.');
    emit(AuthLoading());
    try {
      final user = await signUpUseCase(event.email, event.password, event.name);
      print('AuthBloc: SignUp successful. User authenticated: ${user.email}. Emitting AuthAuthenticated.');
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      print('AuthBloc: SignUp failed with error: $e. Emitting AuthFailure.');
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: SignOutRequested received. Attempting sign out.');
    try {
      await signOutUseCase();
      print('AuthBloc: SignOut successful. Emitting AuthUnauthenticated.');
      emit(AuthUnauthenticated());
    } catch (e) {
      print('AuthBloc: SignOut failed with error: $e. Emitting AuthFailure.');
      emit(AuthFailure(e.toString()));
    }
  }
}