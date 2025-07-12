import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class ApiClient {
  static const String baseUrl = 'https://shmr-finance.ru/api/v1';
  static const String authToken = 'M7vhrEa4oCP8NyeRAhzVSsjR';
  
  late final Dio _dio;
  
  static final ApiClient _instance = ApiClient._internal();
  
  factory ApiClient() => _instance;
  
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    ));
    
    // Добавляем подробные interceptors для логирования
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final timestamp = DateTime.now().toIso8601String();
          developer.log(
            '🚀 API REQUEST [$timestamp]',
            name: 'ApiClient',
          );
          developer.log(
            '📍 ${options.method.toUpperCase()} ${options.uri}',
            name: 'ApiClient',
          );
          
          if (options.headers.isNotEmpty) {
            developer.log(
              '📋 Headers: ${options.headers}',
              name: 'ApiClient',
            );
          }
          
          if (options.data != null) {
            developer.log(
              '📦 Request Body: ${options.data}',
              name: 'ApiClient',
            );
          }
          
          if (options.queryParameters.isNotEmpty) {
            developer.log(
              '🔍 Query Parameters: ${options.queryParameters}',
              name: 'ApiClient',
            );
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          final timestamp = DateTime.now().toIso8601String();
          developer.log(
            '✅ API RESPONSE [$timestamp]',
            name: 'ApiClient',
          );
          developer.log(
            '📍 ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}',
            name: 'ApiClient',
          );
          developer.log(
            '📊 Status: ${response.statusCode} ${response.statusMessage}',
            name: 'ApiClient',
          );
          
          // Анализируем данные ответа
          if (response.data != null) {
            if (response.data is Map<String, dynamic>) {
              final data = response.data as Map<String, dynamic>;
              developer.log(
                '📦 Response Data: ${data}',
                name: 'ApiClient',
              );
              
              // Подсчитываем количество записей для массивов
              data.forEach((key, value) {
                if (value is List) {
                  developer.log(
                    '📊 ${key}: ${value.length} записей',
                    name: 'ApiClient',
                  );
                }
              });
            } else if (response.data is List) {
              final list = response.data as List;
              developer.log(
                '📊 Response: ${list.length} записей',
                name: 'ApiClient',
              );
              developer.log(
                '📦 Response Data: ${response.data}',
                name: 'ApiClient',
              );
            } else {
              developer.log(
                '📦 Response Data: ${response.data}',
                name: 'ApiClient',
              );
            }
          }
          
          handler.next(response);
        },
        onError: (error, handler) {
          final timestamp = DateTime.now().toIso8601String();
          developer.log(
            '❌ API ERROR [$timestamp]',
            name: 'ApiClient',
            error: error,
          );
          developer.log(
            '📍 ${error.requestOptions.method.toUpperCase()} ${error.requestOptions.uri}',
            name: 'ApiClient',
          );
          developer.log(
            '📊 Status: ${error.response?.statusCode} ${error.response?.statusMessage}',
            name: 'ApiClient',
          );
          
          if (error.response?.data != null) {
            developer.log(
              '📦 Error Response: ${error.response?.data}',
              name: 'ApiClient',
            );
          }
          
          developer.log(
            '🔍 Error Type: ${error.type}',
            name: 'ApiClient',
          );
          developer.log(
            '💬 Error Message: ${error.message}',
            name: 'ApiClient',
          );
          
          handler.next(error);
        },
      ),
    );
  }
  
  Dio get dio => _dio;
  
  // Базовые методы для API запросов
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
} 