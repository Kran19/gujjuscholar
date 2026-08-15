import 'package:flutter/material.dart';
import 'package:edustream/routes/app_routes.dart';
import 'package:edustream/features/auth/presentation/screens/splash_screen.dart';
import 'package:edustream/features/auth/presentation/screens/login_screen.dart';
import 'package:edustream/features/auth/presentation/screens/signup_screen.dart';
import 'package:edustream/features/auth/presentation/screens/signup_email_screen.dart';
import 'package:edustream/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:edustream/features/home/presentation/screens/main_entry_screen.dart';
import 'package:edustream/features/home/presentation/screens/home_screen.dart';
import 'package:edustream/features/course/presentation/screens/course_detail_screen.dart';
import 'package:edustream/features/subject/presentation/screens/video_player_screen.dart';
import 'package:edustream/features/course/presentation/screens/notes_screen.dart';
import 'package:edustream/features/quiz/presentation/screens/quiz_list_screen.dart';
import 'package:edustream/features/quiz/presentation/screens/quiz_attempt_screen.dart';
import 'package:edustream/features/subject/presentation/screens/subject_detail_screen.dart';


import 'package:edustream/features/profile/presentation/screens/profile_screen.dart';
import 'package:edustream/features/cart/presentation/screens/checkout_screen.dart';
import 'package:edustream/features/explore/presentation/screens/standard_list_screen.dart';
import 'package:edustream/features/explore/presentation/screens/standard_detail_screen.dart';
import 'package:edustream/features/explore/presentation/screens/course_subjects_screen.dart';
import 'package:edustream/features/video_player/presentation/screens/video_player_demo_screen.dart';
import 'package:edustream/features/explore/data/models/explore_models.dart';
import 'package:edustream/features/cart/presentation/screens/cart_screen.dart';
import 'package:edustream/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:edustream/features/profile/presentation/screens/my_purchases_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen());
      case AppRoutes.login:
        return _buildRoute(const LoginScreen());
      case AppRoutes.signup:
        return _buildRoute(const SignupEmailScreen());
      case AppRoutes.profileSetup:
        final args = settings.arguments;
        final email = args is String ? args : "";
        return _buildRoute(SignupScreen(email: email));
      case AppRoutes.otpVerification:
        final dynamic args = settings.arguments;
        final String email = args is Map ? (args['email'] ?? "") : (args is String ? args : "");
        final bool isSignup = args is Map ? (args['isSignup'] ?? false) : false;
        final String purpose = args is Map ? (args['purpose'] ?? "login") : "login";
        return _buildRoute(OtpVerificationScreen(
          email: email,
          isSignup: isSignup,
          purpose: purpose,
        ));
      case AppRoutes.entry:
        return _buildRoute(const MainEntryScreen());
      case AppRoutes.courseDetail:
        return _buildRoute(const CourseDetailScreen());
      case AppRoutes.videoPlayer:
        final dynamic args = settings.arguments;
        int videoId = 1;
        String videoName = 'Video Lesson';
        if (args is Map) {
          videoId = args['videoId'] is int ? args['videoId'] : (int.tryParse(args['videoId']?.toString() ?? '1') ?? 1);
          videoName = args['videoName']?.toString() ?? 'Video Lesson';
        } else if (args is int) {
          videoId = args;
        }
        return _buildRoute(VideoPlayerScreen(
          videoId: videoId,
          videoName: videoName,
        ));
      case AppRoutes.content: // Used for notes placeholder in my logic
        return _buildRoute(const NotesScreen());
      case AppRoutes.quizList:
        return _buildRoute(const QuizListScreen());
      case AppRoutes.quizAttempt:
        final quizId = settings.arguments as int;
        return _buildRoute(QuizAttemptScreen(quizId: quizId));
      case AppRoutes.subjectDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(SubjectDetailScreen(
          subjectId: args['subjectId'] as int,
          subjectName: args['subjectName'] as String,
        ));
      case AppRoutes.home:
        return _buildRoute(const HomeScreen());
      case AppRoutes.explore:
        return _buildRoute(const StandardListScreen());
      case AppRoutes.standardDetail:
        final standard = settings.arguments as CategoryModel;
        return _buildRoute(StandardDetailScreen(standard: standard));
      case AppRoutes.coursePreview:
        final course = settings.arguments as CourseModel;
        return _buildRoute(CourseSubjectsScreen(course: course));
      case AppRoutes.profile:
        return _buildRoute(const ProfileScreen());
      case AppRoutes.cart:
        return _buildRoute(const CartScreen());
      case AppRoutes.checkout:
        return _buildRoute(const CheckoutScreen());
      case AppRoutes.videoDemo:
        return _buildRoute(const VideoPlayerDemoScreen());
      case AppRoutes.editProfile:
        return _buildRoute(const EditProfileScreen());
      case AppRoutes.myPurchases:
        return _buildRoute(const MyPurchasesScreen());
      default:
        return _buildRoute(const Scaffold(body: Center(child: Text("Route not found"))));
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
