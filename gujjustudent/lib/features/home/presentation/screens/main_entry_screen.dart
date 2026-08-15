import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/core/constants/app_images.dart';

import 'package:edustream/features/home/presentation/screens/home_screen.dart';
import 'package:edustream/features/my_courses/presentation/screens/my_courses_screen.dart';
import 'package:edustream/features/quiz/presentation/screens/quiz_list_screen.dart';
// import 'package:edustream/features/live_class/presentation/screens/live_class_screen.dart';
import 'package:edustream/features/explore/presentation/screens/standard_list_screen.dart';
import 'package:edustream/routes/app_routes.dart';
import 'package:edustream/features/cart/presentation/providers/cart_controller.dart';

/// A provider that controls which tab is currently selected in the bottom nav.
/// Other screens can write to this to force a tab switch.
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainEntryScreen extends ConsumerWidget {
  const MainEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> screens = [
      const HomeScreen(),
      const MyCoursesScreen(),
      const StandardListScreen(),
      // const LiveClassScreen(),
      const QuizListScreen(),
    ];

    return Scaffold(
      appBar: _buildPersistentAppBar(context, ref, currentIndex),
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey,
          onTap: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'My Courses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.live_tv_outlined),
            //   activeIcon: Icon(Icons.live_tv),
            //   label: 'Live',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.quiz_outlined),
              activeIcon: Icon(Icons.quiz),
              label: 'Quiz',
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildPersistentAppBar(BuildContext context, WidgetRef ref, int currentIndex) {
    final List<Map<String, String>> headerContent = [
      {"title": "GujjuScholar", "subtitle": "Learning made easy"},
      {"title": "My Courses", "subtitle": "Track your progress"},
      {"title": "Explore", "subtitle": "Discover new content"},
      // {"title": "Live Classes", "subtitle": "Join the session"},
      {"title": "Quiz Hub", "subtitle": "Test your knowledge"},
    ];

    final currentHeader = headerContent[currentIndex];
    final cartState = ref.watch(cartControllerProvider);
    final cartCount = cartState.items.length;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      toolbarHeight: 72,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // GujjuScholar Brand Logo
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                AppImages.logo,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.school_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentHeader["title"]!,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18),
                ),
                Text(
                  currentHeader["subtitle"]!,
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                currentIndex == 2 ? Icons.shopping_cart_outlined : Icons.notifications_none_rounded,
                size: 26,
                color: AppColors.black,
              ),
              onPressed: () {
                if (currentIndex == 2) {
                  Navigator.pushNamed(context, AppRoutes.cart);
                } else {
                  // Notification handler or toast
                }
              },
            ),
            if (currentIndex == 2 && cartCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            borderRadius: BorderRadius.circular(20),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.person, color: AppColors.primary, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
