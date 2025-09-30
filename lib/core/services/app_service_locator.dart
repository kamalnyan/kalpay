import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/network_service.dart';
import '../services/storage_service.dart';
import '../services/upi_service.dart';
import '../services/notification_service.dart';

/// Service locator for dependency injection
class AppServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  
  static GetIt get instance => _getIt;

  /// Initialize all services
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();
    
    // Core services
    _getIt.registerLazySingleton<Connectivity>(() => Connectivity());
    _getIt.registerLazySingleton<NetworkService>(() => NetworkService());
    _getIt.registerLazySingleton<StorageService>(() => StorageService());
    _getIt.registerLazySingleton<UpiService>(() => UpiService());
    _getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  }

  /// Get service instance
  static T get<T extends Object>() => _getIt.get<T>();

  /// Reset all services (for testing)
  static Future<void> reset() async {
    await _getIt.reset();
  }
}
