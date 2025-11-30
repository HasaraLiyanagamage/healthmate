import 'package:flutter/foundation.dart';
import '../models/health_record.dart';
import '../database/database_helper.dart';
import '../database/web_database_helper.dart';

class HealthProvider with ChangeNotifier {
  // Use web helper if on web, otherwise use SQLite helper
  final bool _isWeb = kIsWeb;
  List<HealthRecord> _records = [];
  bool _isLoading = false;

  List<HealthRecord> get records => _records;
  bool get isLoading => _isLoading;

  // Get today's record
  HealthRecord? get todayRecord {
    final today = DateTime.now();
    final todayRecords = _records.where((record) {
      return record.date.year == today.year &&
          record.date.month == today.month &&
          record.date.day == today.day;
    }).toList();
    
    return todayRecords.isNotEmpty ? todayRecords.first : null;
  }

  // Calculate total steps for today
  int get todaySteps {
    final record = todayRecord;
    return record?.steps ?? 0;
  }

  // Calculate total calories for today
  double get todayCalories {
    final record = todayRecord;
    return record?.calories ?? 0.0;
  }

  // Calculate total water intake for today
  double get todayWater {
    final record = todayRecord;
    return record?.waterIntake ?? 0.0;
  }

  // Calculate weekly average steps
  double get weeklyAverageSteps {
    if (_records.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final weekRecords = _records.where((record) {
      return record.date.isAfter(weekAgo);
    }).toList();
    
    if (weekRecords.isEmpty) return 0.0;
    
    final totalSteps = weekRecords.fold<int>(0, (sum, record) => sum + record.steps);
    return totalSteps / weekRecords.length;
  }

  // Load all records from database
  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isWeb) {
        _records = await WebDatabaseHelper.instance.readAllRecords();
      } else {
        _records = await DatabaseHelper.instance.readAllRecords();
      }
    } catch (e) {
      debugPrint('Error loading records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new record
  Future<void> addRecord(HealthRecord record) async {
    try {
      final newRecord = _isWeb
          ? await WebDatabaseHelper.instance.create(record)
          : await DatabaseHelper.instance.create(record);
      _records.insert(0, newRecord);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding record: $e');
      rethrow;
    }
  }

  // Update an existing record
  Future<void> updateRecord(HealthRecord record) async {
    try {
      if (_isWeb) {
        await WebDatabaseHelper.instance.update(record);
      } else {
        await DatabaseHelper.instance.update(record);
      }
      final index = _records.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _records[index] = record;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating record: $e');
      rethrow;
    }
  }

  // Delete a record
  Future<void> deleteRecord(int id) async {
    try {
      if (_isWeb) {
        await WebDatabaseHelper.instance.delete(id);
      } else {
        await DatabaseHelper.instance.delete(id);
      }
      _records.removeWhere((record) => record.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting record: $e');
      rethrow;
    }
  }

  // Search records by date
  Future<List<HealthRecord>> searchByDate(DateTime date) async {
    try {
      return _isWeb
          ? await WebDatabaseHelper.instance.readRecordsByDate(date)
          : await DatabaseHelper.instance.readRecordsByDate(date);
    } catch (e) {
      debugPrint('Error searching records: $e');
      return [];
    }
  }
}
