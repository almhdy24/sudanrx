import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'medhive.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE guidelines (
        id INTEGER PRIMARY KEY,
        title TEXT,
        slug TEXT UNIQUE,
        category_id INTEGER,
        category_name TEXT,
        overview TEXT,
        diagnosis TEXT,
        management TEXT,
        complications TEXT,
        updated_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY,
        guideline_id INTEGER,
        slug TEXT UNIQUE,
        title TEXT,
        category_name TEXT
      )
    ''');
  }

  Future<void> insertGuidelines(List<dynamic> guidelines) async {
    final db = await database;
    final batch = db.batch();
    for (var g in guidelines) {
      batch.insert(
        'guidelines',
        {
          'id': g['id'],
          'title': g['title'],
          'slug': g['slug'],
          'category_id': g['category']['id'],
          'category_name': g['category']['name'],
          'overview': g['overview'] ?? '',
          'diagnosis': g['diagnosis'] ?? '',
          'management': g['management'] ?? '',
          'complications': g['complications'] ?? '',
          'updated_at': g['updated_at'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getGuidelines() async {
    final db = await database;
    return await db.query('guidelines', orderBy: 'title ASC');
  }

  Future<List<Map<String, dynamic>>> searchLocal(String query) async {
    final db = await database;
    return await db.query(
      'guidelines',
      where: 'title LIKE ? OR overview LIKE ? OR diagnosis LIKE ? OR management LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'title ASC',
    );
  }

  Future<Map<String, dynamic>?> getGuidelineBySlug(String slug) async {
    final db = await database;
    final result = await db.query(
      'guidelines',
      where: 'slug = ?',
      whereArgs: [slug],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> addBookmark(Map<String, dynamic> guideline) async {
    final db = await database;
    await db.insert(
      'bookmarks',
      {
        'guideline_id': guideline['id'],
        'slug': guideline['slug'],
        'title': guideline['title'],
        'category_name': guideline['category']['name'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeBookmark(String slug) async {
    final db = await database;
    await db.delete('bookmarks', where: 'slug = ?', whereArgs: [slug]);
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await database;
    return await db.query('bookmarks', orderBy: 'title ASC');
  }

  Future<bool> isBookmarked(String slug) async {
    final db = await database;
    final result = await db.query(
      'bookmarks',
      where: 'slug = ?',
      whereArgs: [slug],
    );
    return result.isNotEmpty;
  }

  Future<void> clearGuidelines() async {
    final db = await database;
    await db.delete('guidelines');
  }
}
