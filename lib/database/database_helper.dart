import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/health_record.dart';
import '../models/user_profile.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();
  // Check if running on web and delegate to web helper
  static bool get isWeb => kIsWeb;
  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web. Use WebDatabaseHelper instead.');
    }
    if (_database != null) return _database!;
    _database = await _initDB('health_mate.db');
    return _database!;
  }
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Create health_records table
    await db.execute('''
      CREATE TABLE health_records (
        id $idType,
        date $textType,
        steps $intType,
        calories $realType,
        waterIntake $realType
      )
    ''');
    // Create user_profile table
    await db.execute('''
      CREATE TABLE user_profile (
        id $idType,
        name $textType,
        age $intType,
        gender $textType,
        height $realType,
        weight $realType,
        dailyStepsGoal $intType,
        dailyWaterGoal $realType,
        dailyCaloriesGoal $realType,
        activityLevel $textType,
        createdAt $textType,
        updatedAt $textType
      )
    ''');
  }

  Future<HealthRecord> create(HealthRecord record) async {
    final db = await instance.database;
    final id = await db.insert('health_records', record.toMap());
    return record.copyWith(id: id);
  }

  Future<HealthRecord?> readRecord(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'health_records',
      columns: ['id', 'date', 'steps', 'calories', 'waterIntake'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return HealthRecord.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<HealthRecord>> readAllRecords() async {
    final db = await instance.database;
    const orderBy = 'date DESC';
    final result = await db.query('health_records', orderBy: orderBy);
    return result.map((json) => HealthRecord.fromMap(json)).toList();
  }

  Future<List<HealthRecord>> readRecordsByDate(DateTime date) async {
    final db = await instance.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.query(
      'health_records',
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'date DESC',
    );

    return result.map((json) => HealthRecord.fromMap(json)).toList();
  }

  Future<int> update(HealthRecord record) async {
    final db = await instance.database;
    return db.update(
      'health_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // User Profile CRUD operations
  Future<UserProfile> createProfile(UserProfile profile) async {
    final db = await instance.database;
    final id = await db.insert('user_profile', profile.toMap());
    return profile.copyWith(id: id);
  }

  Future<UserProfile?> readProfile() async {
    final db = await instance.database;
    final maps = await db.query('user_profile', limit: 1);
    
    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProfile(UserProfile profile) async {
    final db = await instance.database;
    return db.update(
      'user_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteProfile(int id) async {
    final db = await instance.database;
    return await db.delete(
      'user_profile',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
