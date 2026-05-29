import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database_service.dart';

class ApiService {
  static String baseUrl = 'http://10.64.0.94:3000/api/v1';
  static final DatabaseService _db = DatabaseService();
  static const Duration _timeout = Duration(seconds: 10);

  static Future<void> syncGuidelines() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/guidelines?per_page=100'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List data = json['data'];
        await _db.clearGuidelines();
        await _db.insertGuidelines(data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Silent fail; keep old cache
    }
  }

  static Future<List<Map<String, dynamic>>> getGuidelines({int? categoryId}) async {
    final cached = await _db.getGuidelines();
    // If cache exists, return it immediately
    if (cached.isNotEmpty) {
      // Try to sync in background
      syncGuidelines();
      if (categoryId != null) {
        return cached.where((g) => g['category_id'] == categoryId).toList();
      }
      return cached;
    }
    // No cache: try network
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/guidelines?per_page=100'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List data = json['data'];
        await _db.insertGuidelines(data);
        final fresh = await _db.getGuidelines();
        if (categoryId != null) {
          return fresh.where((g) => g['category_id'] == categoryId).toList();
        }
        return fresh;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      // No cache and network fails -> rethrow
      throw Exception('Unable to load data. Check your connection and server.\nError: $e');
    }
  }

  static Future<Map<String, dynamic>> getGuideline(String slug) async {
    final cached = await _db.getGuidelineBySlug(slug);
    if (cached != null) {
      return cached;
    }
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/guidelines/$slug'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'];
        await _db.insertGuidelines([data]);
        return data;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Cannot load guideline: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> search(String query) async {
    final localResults = await _db.searchLocal(query);
    if (localResults.isNotEmpty) {
      return localResults;
    }
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/search?q=$query'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(json['data']);
      }
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/categories'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'];
      }
    } catch (_) {}
    return [];
  }
}
