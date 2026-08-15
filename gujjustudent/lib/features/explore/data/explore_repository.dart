
import 'package:edustream/core/services/api_service.dart';
import 'package:edustream/features/explore/data/models/explore_models.dart';

class ExploreRepository {
  final ApiService _apiService = ApiService();

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _apiService.get('content/categories');
      return (response.data as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CourseModel>> fetchCategoryCourses(int categoryId) async {
    try {
      final response = await _apiService.get('content/categories/$categoryId/courses');
      return (response.data as List)
          .map((json) => CourseModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CourseModel>> fetchAllCourses() async {
    try {
      final response = await _apiService.get('public/courses');
      return (response.data as List)
          .map((json) => CourseModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchHomeData() async {
    try {
      final response = await _apiService.get('content/home');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CartItemModel>> fetchCart() async {
    try {
      final response = await _apiService.get('cart');
      return (response.data['items'] as List)
          .map((json) => CartItemModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToCart({
    required String type,
    int? itemId,
    List<int>? bundleSubjects,
    double? price,
  }) async {
    try {
      await _apiService.post('cart/add', data: {
        'item_type': type,
        'item_id': itemId,
        'bundle_subjects': bundleSubjects,
        'price': price,
      });
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

  Future<Map<String, dynamic>> fetchCourseSubjects(int courseId) async {
    try {
      final response = await _apiService.get('content/courses/$courseId/subjects');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> fetchQuizHub() async {
    try {
      final response = await _apiService.get('content/quiz-hub');
      return response.data as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
