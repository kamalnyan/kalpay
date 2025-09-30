import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimation extends StatelessWidget {
  final String animationPath;
  final double? width;
  final double? height;
  final bool repeat;
  final bool reverse;
  final AnimationController? controller;
  final VoidCallback? onLoaded;

  const LottieAnimation({
    super.key,
    required this.animationPath,
    this.width,
    this.height,
    this.repeat = true,
    this.reverse = false,
    this.controller,
    this.onLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      animationPath,
      width: width,
      height: height,
      repeat: repeat,
      reverse: reverse,
      controller: controller,
      onLoaded: (composition) {
        if (onLoaded != null) {
          onLoaded!();
        }
      },
    );
  }
}

class SuccessAnimation extends StatelessWidget {
  final double size;
  final VoidCallback? onCompleted;

  const SuccessAnimation({
    super.key,
    this.size = 120.0,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      animationPath: 'assets/animations/success.json',
      width: size,
      height: size,
      repeat: false,
      onLoaded: () {
        if (onCompleted != null) {
          Future.delayed(const Duration(seconds: 2), onCompleted!);
        }
      },
    );
  }
}

class FailedAnimation extends StatelessWidget {
  final double size;
  final VoidCallback? onCompleted;

  const FailedAnimation({
    super.key,
    this.size = 120.0,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      animationPath: 'assets/animations/Failed.json',
      width: size,
      height: size,
      repeat: false,
      onLoaded: () {
        if (onCompleted != null) {
          Future.delayed(const Duration(seconds: 2), onCompleted!);
        }
      },
    );
  }
}

class LoadingAnimation extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingAnimation({
    super.key,
    this.size = 60.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

// Animation dialog helper
class AnimationDialog {
  static Future<void> showSuccess(
    BuildContext context, {
    String title = 'Success!',
    String message = 'Operation completed successfully',
    VoidCallback? onDismiss,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SuccessAnimation(
                onCompleted: () {
                  Navigator.of(context).pop();
                  if (onDismiss != null) onDismiss();
                },
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showFailed(
    BuildContext context, {
    String title = 'Failed!',
    String message = 'Operation failed. Please try again.',
    VoidCallback? onDismiss,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FailedAnimation(
                onCompleted: () {
                  Navigator.of(context).pop();
                  if (onDismiss != null) onDismiss();
                },
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
