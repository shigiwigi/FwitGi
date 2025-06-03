import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure this package is in pubspec.yaml
import 'package:fwitgi_app/simple_bloc_observer.dart';

// Core imports
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/di/dependency_injection.dart' as di; // Alias for clarity and to avoid name conflicts

// Feature imports
import 'features/auth/presentation/bloc/auth_bloc.dart';
// Using the AuthWrapper from core/common/widgets as intended for general app flow
import 'core/common/widgets/auth_wrapper.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize dependency injection
  await di.DependencyInjection.init(); // Use the aliased DependencyInjection

  Bloc.observer = SimpleBlocObserver();

  runApp(const FwitGiApp());
}

class FwitGiApp extends StatelessWidget {
  const FwitGiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>( // Explicitly define the type for BlocProvider
          create: (context) => di.getlt<AuthBloc>()..add(AuthCheckRequested()), // Use aliased getlt
        ),
        // You would add other BlocProviders here as needed, e.g.:
        // BlocProvider<WorkoutBloc>(
        //   create: (context) => di.getlt<WorkoutBloc>(),
        // ),
        // BlocProvider<NutritionBloc>(
        //   create: (context) => di.getlt<NutritionBloc>(),
        // ),
        // BlocProvider<BodyTrackingBloc>(
        //   create: (context) => di.getlt<BodyTrackingBloc>(),
        // ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Or ThemeMode.light/dark based on user preference
        home: const AuthWrapper(), // Use the AuthWrapper from core/common/widgets
      ),
    );
  }
}