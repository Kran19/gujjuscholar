import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/features/cart/data/cart_repository.dart';
import 'package:edustream/features/cart/presentation/providers/cart_providers.dart';

class CartNotifier extends ChangeNotifier {
  final CartRepository _repository;
  List<dynamic> items = [];
  bool isLoading = false;
  String? error;

  CartNotifier(this._repository) {
    fetchCart();
  }

  Future<void> fetchCart() async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await _repository.fetchCart();
      items = data['items'] ?? [];
      isLoading = false;
      error = null;
    } catch (e) {
      isLoading = false;
      error = e.toString();
    }
    notifyListeners();
  }

  Future<void> addItem({
    required String type,
    int? itemId,
    List<int>? bundleSubjects,
    double? price,
  }) async {
    try {
      await _repository.addToCart(
        type: type,
        itemId: itemId,
        bundleSubjects: bundleSubjects,
        price: price,
      );
      await fetchCart();
    } catch (e, stack) {
      error = "Add failed: $e\n$stack";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      await _repository.removeFromCart(cartItemId);
      await fetchCart();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> initiatePayment() async {
    try {
      return await _repository.initiatePayment();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> verifyPayment(Map<String, dynamic> data) async {
    try {
      await _repository.verifyPayment(data);
      await fetchCart();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> clearCart() async {
    items = [];
    error = null;
    notifyListeners();
  }

  Future<void> checkout(String paymentMethod) async {
    try {
      await _repository.createOrder(paymentMethod);
      await fetchCart();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}

final cartControllerProvider = ChangeNotifierProvider<CartNotifier>((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  return CartNotifier(repo);
});
