import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/import_models.dart';
import 'api_exception.dart';

/// Service for logbook import operations
class ImportService {
  final http.Client _client;

  ImportService({http.Client? client}) : _client = client ?? http.Client();

  /// Analyze a CSV file for import
  ///
  /// Returns an [ImportAnalysis] with parsed flights, issues, and duplicates.
  Future<ImportAnalysis> analyzeImport({
    required String userId,
    required ImportProvider provider,
    required File file,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/import/analyze?userId=$userId',
      );

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      request.fields['provider'] = provider.name;
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      // Send request
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60), // Longer timeout for large files
          );

      final response = await http.Response.fromStream(streamedResponse);
      final data = _handleResponse(response);

      return ImportAnalysis.fromJson(data['data']);
    } on SocketException {
      throw ApiException(message: 'Network error. Please check your connection.');
    } on http.ClientException {
      throw ApiException(message: 'Connection failed. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// Analyze CSV content directly (for testing or when file is already read)
  Future<ImportAnalysis> analyzeImportContent({
    required String userId,
    required ImportProvider provider,
    required String csvContent,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/import/analyze?userId=$userId',
      );

      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'provider': provider.name,
          'csvContent': csvContent,
        }),
      ).timeout(
        const Duration(seconds: 60),
      );

      final data = _handleResponse(response);
      return ImportAnalysis.fromJson(data['data']);
    } on SocketException {
      throw ApiException(message: 'Network error. Please check your connection.');
    } on http.ClientException {
      throw ApiException(message: 'Connection failed. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// Execute an import after user confirmation
  ///
  /// Returns an [ImportReport] with the results of the import.
  Future<ImportReport> executeImport({
    required String userId,
    required ImportProvider provider,
    required List<ImportFlightPreview> flights,
    required List<String> createCrewMembers,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/import/execute?userId=$userId',
      );

      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'provider': provider.name,
          'flights': flights.map((f) => f.toJson()).toList(),
          'createCrewMembers': createCrewMembers,
          'resolutions': [], // No manual resolutions for now
        }),
      ).timeout(
        const Duration(seconds: 120), // Longer timeout for large imports
      );

      final data = _handleResponse(response);
      return ImportReport.fromJsonWithFlightStats(data['data'], flights);
    } on SocketException {
      throw ApiException(message: 'Network error. Please check your connection.');
    } on http.ClientException {
      throw ApiException(message: 'Connection failed. Please try again.');
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

    throw ApiException(
      message: data['message'] ?? data['error'] ?? 'Import failed',
      statusCode: response.statusCode,
      errorCode: data['error'],
    );
  }

  void dispose() {
    _client.close();
  }
}
