// lib/core/di/dependency_injection.dart

import 'package:get_it/get_it.dart';

import '../../core/theme/theme_cubit.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/auth/data/repositories/user_repository_impl.dart';
import '../../features/user/domain/repositories/user_repository.dart';
import '../../features/workout/data/repositories/workout_repository_impl.dart';
import '../../features/workout/domain/repositories/workout_repository.dart';
import '../../features/nutrition/data/repositories/nutrition_repository_impl.dart';
import '../../features/nutrition/domain/repositories/nutrition_repository.dart';
import '../../features/body_tracking/data/repositories/body_tracking_repository_impl.dart';
import '../../features/body_tracking/domain/repositories/body_tracking_repository.dart';

import '../../features/workout/domain/repositories/exercise_definition_repository.dart';
import '../../features/workout/data/repositories/exercise_definition_repository_impl.dart';

import '../../features/nutrition/presentation/bloc/nutrition_bloc.dart';
import '../../features/body_tracking/presentation/bloc/body_tracking_bloc.dart';
import '../../features/workout/presentation/bloc/workout_bloc.dart';

final getlt = GetIt.instance;

class DependencyInjection {
  static Future<void> init() async {
    // Repositories
    getlt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
    getlt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());
    // FIX: Pass ExerciseDefinitionRepositoryImpl instance to WorkoutRepositoryImpl
    getlt.registerLazySingleton<WorkoutRepository>(() => WorkoutRepositoryImpl(getlt()));
    getlt.registerLazySingleton<NutritionRepository>(() => NutritionRepositoryImpl());
    getlt.registerLazySingleton<BodyTrackingRepository>(() => BodyTrackingRepositoryImpl());
    getlt.registerLazySingleton<ExerciseDefinitionRepository>(() => ExerciseDefinitionRepositoryImpl());

    // Use Cases
    getlt.registerLazySingleton(() => SignInUseCase(getlt()));
    getlt.registerLazySingleton(() => SignUpUseCase(getlt()));
    getlt.registerLazySingleton(() => SignOutUseCase(getlt()));
    getlt.registerLazySingleton(() => GetUserUseCase(getlt()));

    // Blocs
    getlt.registerSingleton<AuthBloc>(AuthBloc(
          signInUseCase: getlt(),
          signUpUseCase: getlt(),
          signOutUseCase: getlt(),
          getUserUseCase: getlt(),
        ));
    getlt.registerFactory(() => WorkoutBloc(getlt()));
    getlt.registerFactory(() => NutritionBloc(getlt()));
    getlt.registerFactory(() => BodyTrackingBloc(getlt()));
    getlt.registerSingleton<ThemeCubit>(ThemeCubit());
  }
}