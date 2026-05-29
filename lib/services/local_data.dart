import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalData {
  static const String _cacheKey = 'guidelines_cache';

  static Future<void> saveGuidelines(List<dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(data));
  }

  static Future<List<dynamic>> getGuidelines() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_cacheKey);
    if (data == null) return [];
    return jsonDecode(data);
  }
}
