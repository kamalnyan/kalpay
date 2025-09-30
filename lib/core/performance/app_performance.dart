import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Performance optimization utilities for high-traffic handling
class AppPerformance {
  static Timer? _memoryTimer;
  static int _frameCount = 0;
  static DateTime _lastFrameTime = DateTime.now();

  /// Initialize performance monitoring
  static void initialize() {
    if (kDebugMode) {
      _startMemoryMonitoring();
      _startFrameRateMonitoring();
    }
  }

  /// Start monitoring memory usage
  static void _startMemoryMonitoring() {
    _memoryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkMemoryUsage();
    });
  }

  /// Monitor frame rate for performance issues
  static void _startFrameRateMonitoring() {
    WidgetsBinding.instance.addPostFrameCallback(_onFrameEnd);
  }

  static void _onFrameEnd(Duration timestamp) {
    _frameCount++;
    final now = DateTime.now();
    
    if (now.difference(_lastFrameTime).inSeconds >= 1) {
      if (kDebugMode && _frameCount < 55) {
        debugPrint('Performance Warning: Low frame rate detected: $_frameCount FPS');
      }
      _frameCount = 0;
      _lastFrameTime = now;
    }
    
    WidgetsBinding.instance.addPostFrameCallback(_onFrameEnd);
  }

  /// Check memory usage and warn if high
  static void _checkMemoryUsage() {
    // This is a placeholder - actual memory monitoring would require platform channels
    if (kDebugMode) {
      debugPrint('Performance: Memory check completed');
    }
  }

  /// Optimize image loading for better performance
  static ImageProvider optimizeImage(String imagePath, {double? width, double? height}) {
    return ResizeImage(
      AssetImage(imagePath),
      width: width?.round(),
      height: height?.round(),
    );
  }

  /// Debounce function for search and input fields
  static Timer? _debounceTimer;
  
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 300)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle function for scroll events
  static DateTime? _lastThrottleTime;
  
  static void throttle(VoidCallback callback, {Duration delay = const Duration(milliseconds: 100)}) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || now.difference(_lastThrottleTime!) >= delay) {
      _lastThrottleTime = now;
      callback();
    }
  }

  /// Preload critical assets
  static Future<void> preloadAssets(BuildContext context) async {
    final assetPaths = [
      'assets/icons/logo_with_tagline.png',
      'assets/icons/logo.png',
      'assets/animations/loading.json',
    ];

    for (final path in assetPaths) {
      try {
        await precacheImage(AssetImage(path), context);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to preload asset: $path');
        }
      }
    }
  }

  /// Optimize list performance with item extent
  static Widget buildOptimizedListView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    double? itemExtent,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
  }) {
    if (itemExtent != null) {
      return ListView.builder(
        controller: controller,
        padding: padding,
        itemCount: itemCount,
        itemExtent: itemExtent,
        itemBuilder: itemBuilder,
        cacheExtent: 500, // Preload items for smooth scrolling
      );
    }
    
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      cacheExtent: 500,
    );
  }

  /// Build optimized grid view for better performance
  static Widget buildOptimizedGridView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    required int crossAxisCount,
    double childAspectRatio = 1.0,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
  }) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      cacheExtent: 500,
    );
  }

  /// Memory-efficient image widget
  static Widget buildOptimizedImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image(
      image: optimizeImage(imagePath, width: width, height: height),
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        );
      },
    );
  }

  /// Dispose performance monitoring
  static void dispose() {
    _memoryTimer?.cancel();
    _debounceTimer?.cancel();
  }
}

/// Mixin for widgets that need performance optimization
mixin PerformanceOptimizedWidget<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppPerformance.preloadAssets(context);
    });
  }
}

/// Custom scroll physics for better performance
class OptimizedScrollPhysics extends BouncingScrollPhysics {
  const OptimizedScrollPhysics({super.parent});

  @override
  OptimizedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OptimizedScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingVelocity => 50.0; // Reduced for better control

  @override
  double get maxFlingVelocity => 8000.0; // Increased for smoother scrolling
}
