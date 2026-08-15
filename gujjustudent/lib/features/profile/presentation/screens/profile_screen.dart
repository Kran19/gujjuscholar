import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/routes/app_routes.dart';
import 'package:edustream/features/auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        data: (user) => SingleChildScrollView(
          child: Column(
            children: [
              _buildPremiumHeader(context, user),
              const SizedBox(height: 24),
              _buildProfileMenu(context),
              const SizedBox(height: 32),
              _buildLogoutButton(context, ref),
              const SizedBox(height: 40),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, dynamic user) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.royalBlue, AppColors.royalPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            user['name'] ?? "Student",
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user['email'] ?? "",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 20),
          _buildPremiumBadge(),
        ],
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text("PREMIUM STUDENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuSection(context, "Account", [
            _MenuItem(icon: Icons.school_rounded, title: "My Standard / Course", color: AppColors.primary),
            _MenuItem(icon: Icons.shopping_bag, title: "My Purchases", color: Colors.indigo),
            _MenuItem(icon: Icons.edit, title: "Edit Profile", color: Colors.orange),
          ]),
          const SizedBox(height: 20),
          _buildMenuSection(context, "Settings", [
            _MenuItem(icon: Icons.notifications, title: "Notifications", color: AppColors.secondary),
            _MenuItem(icon: Icons.help, title: "Support", color: Colors.green),
          ]),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: items
                .map((item) => ListTile(
                      leading: Icon(item.icon, color: item.color),
                      title: Text(item.title),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (item.title == "Edit Profile") {
                          Navigator.pushNamed(context, AppRoutes.editProfile);
                        } else if (item.title == "My Purchases") {
                          Navigator.pushNamed(context, AppRoutes.myPurchases);
                        } else if (item.title == "My Standard / Course") {
                          Navigator.pushNamed(context, AppRoutes.explore);
                        }
                      },
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showLogoutConfirmation(context, ref),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red),
          child: const Text("Logout"),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              ref.read(authRepositoryProvider).logout();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Yes, Logout"),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Color color;
  _MenuItem({required this.icon, required this.title, required this.color});
}
