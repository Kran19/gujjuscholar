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
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Dotenv loading exception: $e');
  }

  try {
    await ApiService().init();
  } catch (e) {
    debugPrint('ApiService initialization exception: $e');
  }

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
