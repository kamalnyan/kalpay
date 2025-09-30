import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';

/// Responsive builder widget for handling different screen sizes
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)? tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  ScreenType _getScreenType(double width) {
    if (width >= AppDimensions.desktopBreakpoint) {
      return ScreenType.desktop;
    } else if (width >= AppDimensions.tabletBreakpoint) {
      return ScreenType.tablet;
    } else {
      return ScreenType.mobile;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = _getScreenType(constraints.maxWidth);
        
        switch (screenType) {
          case ScreenType.mobile:
            return mobile(context, constraints);
          case ScreenType.tablet:
            return tablet?.call(context, constraints) ?? mobile(context, constraints);
          case ScreenType.desktop:
            return desktop?.call(context, constraints) ?? tablet?.call(context, constraints) ?? mobile(context, constraints);
        }
      },
    );
  }
}

/// Screen type enum
enum ScreenType { mobile, tablet, desktop }

/// Extension to get screen type from context
extension ScreenTypeExtension on BuildContext {
  ScreenType get screenType {
    final width = MediaQuery.of(this).size.width;
    if (width >= AppDimensions.desktopBreakpoint) {
      return ScreenType.desktop;
    } else if (width >= AppDimensions.tabletBreakpoint) {
      return ScreenType.tablet;
    } else {
      return ScreenType.mobile;
    }
  }

  bool get isMobile => screenType == ScreenType.mobile;
  bool get isTablet => screenType == ScreenType.tablet;
  bool get isDesktop => screenType == ScreenType.desktop;
}

/// Static access to responsive builder  
class ResponsiveBuilderHelper {
  static BuildContext of(BuildContext context) {
    return context;
  }
}

/// Responsive value helper
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T getValue(BuildContext context) {
    switch (context.screenType) {
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.mobile:
        return mobile;
    }
  }
}
