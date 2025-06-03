import 'package:get_it/get_it.dart'; // Should now work after adding to pubspec.yaml

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Ensure these paths are correct relative to dependency_injection.dart
import '../../features/user/data/repositories/user_repository_impl.dart';
import '../../features/user/domain/repositories/user_repository.dart';
import '../../features/workout/data/repositories/workout_repository_impl.dart';
import '../../features/workout/domain/repositories/workout_repository.dart';
import '../../features/nutrition/data/repositories/nutrition_repository_impl.dart';
import '../../features/nutrition/domain/repositories/nutrition_repository.dart';
import '../../features/body_tracking/data/repositories/body_tracking_repository_impl.dart';
import '../../features/body_tracking/domain/repositories/body_tracking_repository.dart';

// Make sure these BLoC imports are also correct
import '../../features/nutrition/presentation/bloc/nutrition_bloc.dart';
import '../../features/body_tracking/presentation/bloc/body_tracking_bloc.dart';
import '../../features/workout/presentation/bloc/workout_bloc.dart'; // Add this if missing

final getlt = GetIt.instance;

class DependencyInjection {
  static Future<void> init() async {
    // Repositories
    getlt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
    getlt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());
    getlt.registerLazySingleton<WorkoutRepository>(() => WorkoutRepositoryImpl());
    getlt.registerLazySingleton<NutritionRepository>(() => NutritionRepositoryImpl());
    getlt.registerLazySingleton<BodyTrackingRepository>(() => BodyTrackingRepositoryImpl());

    // Use Cases
    getlt.registerLazySingleton(() => SignInUseCase(getlt()));
    getlt.registerLazySingleton(() => SignUpUseCase(getlt()));
    getlt.registerLazySingleton(() => SignOutUseCase(getlt()));
    getlt.registerLazySingleton(() => GetUserUseCase(getlt()));

    // Blocs
    getlt.registerFactory(() => AuthBloc(
          signInUseCase: getlt(),
          signUpUseCase: getlt(),
          signOutUseCase: getlt(),
          getUserUseCase: getlt(),
        ));
    getlt.registerFactory(() => WorkoutBloc(getlt()));
    getlt.registerFactory(() => NutritionBloc(getlt()));
    getlt.registerFactory(() => BodyTrackingBloc(getlt()));
  }
}