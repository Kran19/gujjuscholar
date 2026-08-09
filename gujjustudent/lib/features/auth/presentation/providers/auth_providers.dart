import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/features/auth/data/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authStateProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.fetchProfile();
});
