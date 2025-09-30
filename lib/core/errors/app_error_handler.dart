import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../services/firebase_service.dart';

/// Global error handler for the application
class AppErrorHandler {
  static bool _isInitialized = false;

  /// Initialize error handling
  static void initialize() {
    if (_isInitialized) return;
    
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack, 'Flutter Framework Error');
    };

    // Handle async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack, 'Async Error');
      return true;
    };

    _isInitialized = true;
  }

  /// Log error to Firebase Crashlytics and console
  static void _logError(dynamic error, StackTrace? stackTrace, String context) {
    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('[$context] Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }

    // Log to Firebase Crashlytics
    try {
      FirebaseService.recordError(error, stackTrace);
      FirebaseService.log('$context: $error');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log error to Crashlytics: $e');
      }
    }
  }

  /// Handle and log custom errors
  static void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final errorContext = context ?? 'Application Error';
    
    _logError(error, stackTrace, errorContext);
    
    // Log additional data if provided
    if (additionalData != null && additionalData.isNotEmpty) {
      for (final entry in additionalData.entries) {
        FirebaseService.log('${entry.key}: ${entry.value}');
      }
    }
  }

  /// Handle network errors
  static AppException handleNetworkError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return const AppException.network('No internet connection');
    } else if (error.toString().contains('TimeoutException')) {
      return const AppException.network('Request timeout');
    } else if (error.toString().contains('HandshakeException')) {
      return const AppException.network('SSL handshake failed');
    } else {
      return AppException.network('Network error: ${error.toString()}');
    }
  }

  /// Handle Firebase errors
  static AppException handleFirebaseError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();
    
    if (errorMessage.contains('permission-denied')) {
      return const AppException.permission('Access denied');
    } else if (errorMessage.contains('not-found')) {
      return const AppException.notFound('Data not found');
    } else if (errorMessage.contains('already-exists')) {
      return const AppException.validation('Data already exists');
    } else if (errorMessage.contains('invalid-argument')) {
      return const AppException.validation('Invalid data provided');
    } else if (errorMessage.contains('unauthenticated')) {
      return const AppException.authentication('Authentication required');
    } else {
      return AppException.server('Server error: ${error.toString()}');
    }
  }

  /// Handle authentication errors
  static AppException handleAuthError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();
    
    if (errorMessage.contains('invalid-phone-number')) {
      return const AppException.authentication('Invalid phone number');
    } else if (errorMessage.contains('invalid-verification-code')) {
      return const AppException.authentication('Invalid OTP code');
    } else if (errorMessage.contains('session-expired')) {
      return const AppException.authentication('Session expired');
    } else if (errorMessage.contains('too-many-requests')) {
      return const AppException.authentication('Too many attempts. Try again later');
    } else {
      return AppException.authentication('Authentication failed: ${error.toString()}');
    }
  }
}

/// Custom application exceptions
class AppException implements Exception {
  final String message;
  final AppExceptionType type;
  final dynamic originalError;

  const AppException._(this.message, this.type, [this.originalError]);

  const AppException.network(String message) : this._(message, AppExceptionType.network);
  const AppException.authentication(String message) : this._(message, AppExceptionType.authentication);
  const AppException.permission(String message) : this._(message, AppExceptionType.permission);
  const AppException.validation(String message) : this._(message, AppExceptionType.validation);
  const AppException.notFound(String message) : this._(message, AppExceptionType.notFound);
  const AppException.server(String message) : this._(message, AppExceptionType.server);
  const AppException.unknown(String message) : this._(message, AppExceptionType.unknown);

  @override
  String toString() => message;
}

/// Exception types for better error categorization
enum AppExceptionType {
  network,
  authentication,
  permission,
  validation,
  notFound,
  server,
  unknown,
}

/// Error result wrapper for operations
class Result<T> {
  final T? data;
  final AppException? error;
  final bool isSuccess;

  const Result._(this.data, this.error, this.isSuccess);

  const Result.success(T data) : this._(data, null, true);
  const Result.failure(AppException error) : this._(null, error, false);

  /// Execute callback based on result
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    if (isSuccess && data != null) {
      return success(data!);
    } else if (error != null) {
      return failure(error!);
    } else {
      return failure(const AppException.unknown('Unknown error occurred'));
    }
  }

  /// Map success data to another type
  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        return Result.success(mapper(data!));
      } catch (e) {
        return Result.failure(AppException.unknown('Mapping failed: $e'));
      }
    } else {
      return Result.failure(error ?? const AppException.unknown('No data to map'));
    }
  }
}

/// Safe execution wrapper for async operations
class SafeExecution {
  /// Execute async operation with error handling
  static Future<Result<T>> execute<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Result.success(result);
    } catch (error, stackTrace) {
      AppErrorHandler.handleError(error, stackTrace: stackTrace);
      
      if (error is AppException) {
        return Result.failure(error);
      } else {
        return Result.failure(AppException.unknown(error.toString()));
      }
    }
  }

  /// Execute sync operation with error handling
  static Result<T> executeSync<T>(T Function() operation) {
    try {
      final result = operation();
      return Result.success(result);
    } catch (error, stackTrace) {
      AppErrorHandler.handleError(error, stackTrace: stackTrace);
      
      if (error is AppException) {
        return Result.failure(error);
      } else {
        return Result.failure(AppException.unknown(error.toString()));
      }
    }
  }
}
