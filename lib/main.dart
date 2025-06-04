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
// Add these imports for WorkoutBloc and NutritionBloc
import 'features/workout/presentation/bloc/workout_bloc.dart';
import 'features/nutrition/presentation/bloc/nutrition_bloc.dart';
import 'features/body_tracking/presentation/bloc/body_tracking_bloc.dart'; // Make sure this is also imported if used


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize dependency injection
  await di.DependencyInjection.init();

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
        // UNCOMMENTED: WorkoutBloc and NutritionBloc
        BlocProvider<WorkoutBloc>(
          create: (context) => di.getlt<WorkoutBloc>(),
        ),
        BlocProvider<NutritionBloc>(
          create: (context) => di.getlt<NutritionBloc>(),
        ),
        BlocProvider<BodyTrackingBloc>( // Assuming you also want to provide this
          create: (context) => di.getlt<BodyTrackingBloc>(),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
      ),
    );
  }
}