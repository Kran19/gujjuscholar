import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late Dio _dio;
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  Future<void> init() async {
    final baseUrl = dotenv.env['API_URL'] ?? 'http://127.0.0.1:8000/api/';
    
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('API_LOG: $obj'),
    ));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
      return await _dio.get(normalizedPath, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
      return await _dio.post(normalizedPath, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
      return await _dio.put(normalizedPath, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
      return await _dio.delete(normalizedPath);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token.isEmpty) {
      _dio.options.headers.remove('Authorization');
      await prefs.remove('jwt_token');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      await prefs.setString('jwt_token', token);
    }
  }

  String _handleError(DioException error) {
    String message = 'Something went wrong';
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map) {
            message = errors.values.map((v) => (v as List).first).join('\n');
          } else {
            message = errors.toString();
          }
        } else {
          message = data['message'] ?? data['error'] ?? message;
        }
      }
    } else {
      message = error.message ?? message;
    }
    return message;
  }
}
