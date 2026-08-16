import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/core/constants/app_images.dart';

import 'package:edustream/features/home/presentation/screens/home_screen.dart';
import 'package:edustream/features/my_courses/presentation/screens/my_courses_screen.dart';
import 'package:edustream/features/quiz/presentation/screens/quiz_list_screen.dart';
import 'package:edustream/features/explore/presentation/screens/standard_list_screen.dart';
import 'package:edustream/routes/app_routes.dart';
import 'package:edustream/features/cart/presentation/providers/cart_controller.dart';

/// A provider that controls which tab is currently selected in the bottom nav.
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
          color: const Color(0xFF0F172A), // Premium Dark Slate
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDarkNavItem(
                  index: 0,
                  currentIndex: currentIndex,
                  label: 'Home',
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 0,
                ),
                _buildDarkNavItem(
                  index: 1,
                  currentIndex: currentIndex,
                  label: 'My Courses',
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book_rounded,
                  onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
                ),
                _buildDarkNavItem(
                  index: 2,
                  currentIndex: currentIndex,
                  label: 'Explore',
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                  onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
                ),
                _buildDarkNavItem(
                  index: 3,
                  currentIndex: currentIndex,
                  label: 'Quiz Hub',
                  icon: Icons.quiz_outlined,
                  activeIcon: Icons.quiz_rounded,
                  onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildPersistentAppBar(BuildContext context, WidgetRef ref, int currentIndex) {
    final List<Map<String, String>> headerContent = [
      {"title": "GujjuScholar", "subtitle": "Learning made easy"},
      {"title": "My Courses", "subtitle": "Track your progress"},
      {"title": "Explore", "subtitle": "Discover new content"},
      {"title": "Quiz Hub", "subtitle": "Test your knowledge"},
    ];

    final currentHeader = headerContent[currentIndex];
    final cartState = ref.watch(cartControllerProvider);
    final cartCount = cartState.items.length;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Slate
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // GujjuScholar Brand Logo
          Container(
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                AppImages.logo,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.school_rounded,
                  color: Color(0xFF38BDF8),
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: currentIndex == 0
                ? RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Gujju",
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: "Scholar",
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF38BDF8), // Electric Sky Blue
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentHeader["title"]!,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        currentHeader["subtitle"]!,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      actions: [
        // Cart / Explore Shortcut
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_bag_outlined,
                size: 22,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.cart);
              },
            ),
            if (cartCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF38BDF8),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(color: Color(0xFF0F172A), fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
          ],
        ),
        // Profile Avatar Button
        Padding(
          padding: const EdgeInsets.only(right: 14, left: 4),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
              ),
              child: const CircleAvatar(
                radius: 15,
                backgroundColor: Color(0xFF1E293B),
                child: Icon(Icons.person_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDarkNavItem({
    required int index,
    required int currentIndex,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 7)
            : const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
