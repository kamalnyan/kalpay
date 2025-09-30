import 'package:hive_flutter/hive_flutter.dart';

/// Local storage service using Hive
class StorageService {
  static const String _userBoxName = 'user_data';
  static const String _transactionsBoxName = 'transactions';
  static const String _customersBoxName = 'customers';
  static const String _settingsBoxName = 'settings';

  Box? _userBox;
  Box? _transactionsBox;
  Box? _customersBox;
  Box? _settingsBox;

  /// Initialize storage boxes
  Future<void> initialize() async {
    _userBox = await Hive.openBox(_userBoxName);
    _transactionsBox = await Hive.openBox(_transactionsBoxName);
    _customersBox = await Hive.openBox(_customersBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  /// User data operations
  Future<void> saveUserData(String key, dynamic value) async {
    await _userBox?.put(key, value);
  }

  T? getUserData<T>(String key) {
    return _userBox?.get(key) as T?;
  }

  Future<void> clearUserData() async {
    await _userBox?.clear();
  }

  /// Transaction operations
  Future<void> saveTransaction(String id, Map<String, dynamic> transaction) async {
    await _transactionsBox?.put(id, transaction);
  }

  Map<String, dynamic>? getTransaction(String id) {
    return _transactionsBox?.get(id) as Map<String, dynamic>?;
  }

  List<Map<String, dynamic>> getAllTransactions() {
    return _transactionsBox?.values
        .cast<Map<String, dynamic>>()
        .toList() ?? [];
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsBox?.delete(id);
  }

  /// Customer operations
  Future<void> saveCustomer(String id, Map<String, dynamic> customer) async {
    await _customersBox?.put(id, customer);
  }

  Map<String, dynamic>? getCustomer(String id) {
    return _customersBox?.get(id) as Map<String, dynamic>?;
  }

  List<Map<String, dynamic>> getAllCustomers() {
    return _customersBox?.values
        .cast<Map<String, dynamic>>()
        .toList() ?? [];
  }

  Future<void> deleteCustomer(String id) async {
    await _customersBox?.delete(id);
  }

  /// Settings operations
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox?.get(key, defaultValue: defaultValue) as T?;
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await _userBox?.clear();
    await _transactionsBox?.clear();
    await _customersBox?.clear();
    await _settingsBox?.clear();
  }

  /// Close all boxes
  Future<void> dispose() async {
    await _userBox?.close();
    await _transactionsBox?.close();
    await _customersBox?.close();
    await _settingsBox?.close();
  }
}
