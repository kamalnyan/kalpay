import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';

/// Custom bottom sheet widget following the app design system
class AppBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool isDismissible;
  final bool enableDrag;
  final double? height;

  const AppBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.isDismissible = true,
    this.enableDrag = true,
    this.height,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        title: title,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        height: height,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = screenHeight * 0.9;
    final actualHeight = height ?? maxHeight;

    return Container(
      height: actualHeight + keyboardHeight,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusLarge),
          topRight: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          if (enableDrag) ...[
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
          
          // Header
          if (title != null) ...[
            const SizedBox(height: AppDimensions.paddingBase),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingBase),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTextStyles.h3,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (isDismissible)
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      iconSize: AppDimensions.iconMedium,
                    ),
                ],
              ),
            ),
            const Divider(),
          ] else if (isDismissible) ...[
            const SizedBox(height: AppDimensions.paddingBase),
            Row(
              children: [
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  iconSize: AppDimensions.iconMedium,
                ),
              ],
            ),
          ],
          
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick action bottom sheet
class QuickActionBottomSheet extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionBottomSheet({
    super.key,
    required this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required List<QuickAction> actions,
  }) {
    return AppBottomSheet.show<T>(
      context: context,
      title: 'Quick Actions',
      child: QuickActionBottomSheet(actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(AppDimensions.paddingBase),
      itemCount: actions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final action = actions[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
            ),
            child: Icon(
              action.icon,
              color: action.color,
              size: AppDimensions.iconMedium,
            ),
          ),
          title: Text(
            action.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: action.subtitle != null
              ? Text(
                  action.subtitle!,
                  style: AppTextStyles.bodySmall,
                )
              : null,
          onTap: () {
            Navigator.of(context).pop();
            action.onTap();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
          ),
        );
      },
    );
  }
}

/// Quick action model
class QuickAction {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
