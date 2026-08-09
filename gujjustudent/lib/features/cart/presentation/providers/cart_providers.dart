import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/features/cart/data/cart_repository.dart';

final cartRepositoryProvider = Provider((ref) => CartRepository());

final cartProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(cartRepositoryProvider);
  return repo.fetchCart();
});
