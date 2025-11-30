import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_record.dart';
import '../models/user_profile.dart';

class WebDatabaseHelper {
  static final WebDatabaseHelper instance = WebDatabaseHelper._init();
  static const String _recordsKey = 'health_records';
  static const String _profileKey = 'user_profile';
  static const String _nextIdKey = 'next_id';
  int _nextId = 1;
  bool _initialized = false;

  WebDatabaseHelper._init();

  Future<void> _initialize() async {
    if (_initialized) return;
    
    debugPrint(' Initializing WebDatabaseHelper...');
    
    final prefs = await SharedPreferences.getInstance();
    
    // Load next ID from storage
    _nextId = prefs.getInt(_nextIdKey) ?? 1;
    debugPrint(' Loaded next ID: $_nextId');
    
    _initialized = true;
    debugPrint(' WebDatabaseHelper initialized');
  }

  Future<List<HealthRecord>> _loadRecords() async {
    await _initialize();
    
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_recordsKey);
    
    debugPrint(' Loading records from storage...');
    
    if (jsonString == null || jsonString.isEmpty) {
      debugPrint('No records found in storage');
      return [];
    }
    
    final List<dynamic> jsonList = json.decode(jsonString);
    final records = jsonList.map((json) => HealthRecord.fromMap(json)).toList();
    
    debugPrint(' Loaded ${records.length} records from storage');
    
    // Update _nextId to be higher than any existing ID
    if (records.isNotEmpty) {
      final maxId = records.map((r) => r.id ?? 0).reduce((a, b) => a > b ? a : b);
      if (maxId >= _nextId) {
        _nextId = maxId + 1;
        await prefs.setInt(_nextIdKey, _nextId);
      }
    }
    
    return records;
  }

  Future<void> _saveRecords(List<HealthRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((r) => r.toMap()).toList();
    final jsonString = json.encode(jsonList);
    final success = await prefs.setString(_recordsKey, jsonString);
    
    debugPrint(' Saving ${records.length} records to storage... ${success ? " Success" : " Failed"}');
  }

  Future<HealthRecord> create(HealthRecord record) async {
    final records = await _loadRecords();
    final newRecord = record.copyWith(id: _nextId);
    _nextId++;
    
    // Save the next ID to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_nextIdKey, _nextId);
    
    records.add(newRecord);
    await _saveRecords(records);
    
    // Debug: Verify save
    debugPrint(' Record saved: ID=${newRecord.id}, Steps=${newRecord.steps}');
    debugPrint('Total records: ${records.length}');
    debugPrint('Next ID: $_nextId');
    
    return newRecord;
  }

  Future<HealthRecord?> readRecord(int id) async {
    final records = await _loadRecords();
    try {
      return records.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<HealthRecord>> readAllRecords() async {
    return await _loadRecords();
  }

  Future<List<HealthRecord>> readRecordsByDate(DateTime date) async {
    final records = await _loadRecords();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return records.where((record) {
      return record.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
          record.date.isBefore(endOfDay);
    }).toList();
  }

  Future<int> update(HealthRecord record) async {
    final records = await _loadRecords();
    final index = records.indexWhere((r) => r.id == record.id);
    
    if (index != -1) {
      records[index] = record;
      await _saveRecords(records);
      return 1;
    }
    return 0;
  }

  Future<int> delete(int id) async {
    final records = await _loadRecords();
    final initialLength = records.length;
    records.removeWhere((r) => r.id == id);
    
    if (records.length < initialLength) {
      await _saveRecords(records);
      return 1;
    }
    return 0;
  }

  Future<void> close() async {
    // No-op for web storage
  }

  // User Profile operations
  Future<UserProfile> createProfile(UserProfile profile) async {
    await _initialize();
    final prefs = await SharedPreferences.getInstance();
    final newProfile = profile.copyWith(id: 1); // Only one profile for web
    final jsonString = json.encode(newProfile.toMap());
    await prefs.setString(_profileKey, jsonString);
    return newProfile;
  }

  Future<UserProfile?> readProfile() async {
    await _initialize();
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_profileKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return UserProfile.fromMap(map);
  }

  Future<int> updateProfile(UserProfile profile) async {
    await _initialize();
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(profile.toMap());
    final success = await prefs.setString(_profileKey, jsonString);
    return success ? 1 : 0;
  }

  Future<int> deleteProfile(int id) async {
    await _initialize();
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.remove(_profileKey);
    return success ? 1 : 0;
  }
}
