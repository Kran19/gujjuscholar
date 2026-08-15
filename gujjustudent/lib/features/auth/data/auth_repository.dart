
import 'package:edustream/core/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post('auth/login', data: {
        'email': email,
        'password': password,
      });
      
      final token = response.data['token'];
      if (token != null) {
        await _apiService.setToken(token);
      }
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('auth/register', data: data);
      
      final token = response.data['token'];
      if (token != null) {
        await _apiService.setToken(token);
      }
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('profile', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getPublicCourses() async {
    try {
      final response = await _apiService.get('public/courses');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> fetchMyCourses() async {
    try {
      final response = await _apiService.get('learning/my-courses');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final response = await _apiService.get('auth/me');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendOtp(String email, String purpose) async {
    try {
      final response = await _apiService.post('auth/send-otp', data: {
        'email': email,
        'purpose': purpose,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp, String purpose) async {
    try {
      final response = await _apiService.post('auth/verify-otp', data: {
        'email': email,
        'otp': otp,
        'purpose': purpose,
      });
      
      final token = response.data['token'];
      if (token != null) {
        await _apiService.setToken(token);
      }
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> switchCourse(int courseId) async {
    try {
      final response = await _apiService.post('auth/switch-course', data: {
        'course_id': courseId,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _apiService.setToken('');
  }
}
