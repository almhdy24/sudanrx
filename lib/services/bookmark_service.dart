import 'database_service.dart';

class BookmarkService {
  static final DatabaseService _db = DatabaseService();

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    return await _db.getBookmarks();
  }

  static Future<void> addBookmark(Map<String, dynamic> guideline) async {
    await _db.addBookmark(guideline);
  }

  static Future<void> removeBookmark(String slug) async {
    await _db.removeBookmark(slug);
  }

  static Future<bool> isBookmarked(String slug) async {
    return await _db.isBookmarked(slug);
  }
}
