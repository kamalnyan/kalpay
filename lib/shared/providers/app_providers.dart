import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_service_locator.dart';
import '../../core/network/network_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/upi_service.dart';
import '../../core/services/notification_service.dart';

/// Provider for network service
final networkServiceProvider = Provider<NetworkService>((ref) {
  return AppServiceLocator.get<NetworkService>();
});

/// Provider for storage service
final storageServiceProvider = Provider<StorageService>((ref) {
  return AppServiceLocator.get<StorageService>();
});

/// Provider for UPI service
final upiServiceProvider = Provider<UpiService>((ref) {
  return AppServiceLocator.get<UpiService>();
});

/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return AppServiceLocator.get<NotificationService>();
});

/// Provider for network connectivity status
final connectivityProvider = StreamProvider<bool>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  return networkService.connectionStream;
});

/// Provider for current theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

/// Provider for current locale
final localeProvider = StateProvider<String>((ref) {
  return 'en';
});
