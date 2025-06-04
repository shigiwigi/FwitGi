// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/di/dependency_injection.dart' as di;
import 'simple_bloc_observer.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'core/common/widgets/auth_wrapper.dart';
import 'features/workout/presentation/bloc/workout_bloc.dart';
import 'features/nutrition/presentation/bloc/nutrition_bloc.dart';
import 'features/body_tracking/presentation/bloc/body_tracking_bloc.dart';
import 'core/theme/theme_cubit.dart';

// Import ExerciseDefinitionRepository to call seed method
import 'features/workout/domain/repositories/exercise_definition_repository.dart'; // ADD THIS


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await Hive.initFlutter();
  await di.DependencyInjection.init();

  // Call the data seeding function here
  // Ensure ExerciseDefinitionRepository is initialized before calling seed
  final ExerciseDefinitionRepository exerciseDefRepo = di.getlt<ExerciseDefinitionRepository>();
  await exerciseDefRepo.seedInitialDefinitions(); // ADD THIS LINE

  Bloc.observer = SimpleBlocObserver();

  runApp(const FwitGiApp());
}

class FwitGiApp extends StatelessWidget {
  const FwitGiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.getlt<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<WorkoutBloc>(
          create: (context) => di.getlt<WorkoutBloc>(),
        ),
        BlocProvider<NutritionBloc>(
          create: (context) => di.getlt<NutritionBloc>(),
        ),
        BlocProvider<BodyTrackingBloc>(
          create: (context) => di.getlt<BodyTrackingBloc>(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => di.getlt<ThemeCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}