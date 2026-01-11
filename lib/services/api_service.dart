import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'api_exception.dart';

/// Base service for making API calls to the backend
class ApiService {
  final http.Client _client;

  /// Constructor with optional client injection for testing
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    return _request('GET', endpoint);
  }

  /// POST request with JSON body
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _request('POST', endpoint, body: body);
  }

  /// PUT request with JSON body
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _request('PUT', endpoint, body: body);
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    return _request('DELETE', endpoint);
  }

  /// Internal request handler
  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      http.Response response;

      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(Duration(seconds: AppConfig.connectTimeout));
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(Duration(seconds: AppConfig.connectTimeout));
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: jsonEncode(body))
              .timeout(Duration(seconds: AppConfig.connectTimeout));
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers)
              .timeout(Duration(seconds: AppConfig.connectTimeout));
          break;
        default:
          throw ApiException(message: 'Unsupported HTTP method: $method');
      }

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'Network error. Please check your connection.',
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timed out. Please try again.',
      );
    } on http.ClientException {
      throw ApiException(
        message: 'Connection failed. Please try again.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// Parse API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body);
    } catch (e) {
      throw ApiException(
        message: 'Invalid response from server',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data['success'] == true) {
        return data;
      }
    }

    // Handle error responses
    throw ApiException(
      message: data['error'] ?? data['message'] ?? 'Unknown error',
      statusCode: response.statusCode,
      errorCode: data['error'],
    );
  }

  void dispose() {
    _client.close();
  }
}
