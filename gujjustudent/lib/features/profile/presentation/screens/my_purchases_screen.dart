import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/auth/presentation/providers/auth_providers.dart';

class MyPurchasesScreen extends ConsumerWidget {
  const MyPurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: We'll reuse AuthRepository.myCourses which returns enrollments

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Purchases', style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ref.read(authRepositoryProvider).fetchMyCourses(), // Assuming we add this to repo
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final enrollment = items[index];
              final item = enrollment['course'] ?? enrollment['subject'];
              final isCourse = enrollment['course'] != null;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCourse ? Icons.school_rounded : Icons.menu_book_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(item['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(isCourse ? 'Full Course' : 'Single Subject'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to detail if needed
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No purchases yet', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Your purchased courses will appear here', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// Add fetchMyCourses to AuthRepository
extension AuthRepositoryExtra on dynamic {
  // This is a temporary way to add the method without editing the file immediately
  // But I will edit the actual file.
}
