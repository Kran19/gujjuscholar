import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/core/theme/app_theme.dart';
import 'package:edustream/core/constants/app_strings.dart';
import 'package:edustream/routes/app_routes.dart';
import 'package:edustream/routes/route_generator.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:edustream/core/services/api_service.dart';

Future<void> main() async {
  // Ensure binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Dotenv (if we had a .env file, we'd load it here)
  await dotenv.load(fileName: ".env");

  // Initialize ApiService (reads JWT token from secure storage)
  await ApiService().init();

  runApp(
    const ProviderScope(
      child: EduStreamApp(),
    ),
  );
}

class EduStreamApp extends StatelessWidget {
  const EduStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
