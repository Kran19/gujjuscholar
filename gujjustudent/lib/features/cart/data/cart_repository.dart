import 'package:edustream/core/services/api_service.dart';

class CartRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> fetchCart() async {
    try {
      final response = await _apiService.get('cart');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addToCart({
    required String type,
    int? itemId,
    List<int>? bundleSubjects,
    double? price,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'item_type': type,
      };
      
      if (itemId != null) data['item_id'] = itemId;
      if (bundleSubjects != null) data['bundle_subjects'] = bundleSubjects;
      if (price != null) data['price'] = price;

      final response = await _apiService.post('cart/add', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    try {
      await _apiService.delete('cart/remove/$cartItemId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> initiatePayment() async {
    try {
      final response = await _apiService.post('orders/initiate-payment');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyPayment(Map<String, dynamic> data) async {
    try {
      await _apiService.post('orders/verify-payment', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createOrder(String paymentMethod) async {
    try {
      final response = await _apiService.post('orders/create', data: {
        'payment_method': paymentMethod,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
