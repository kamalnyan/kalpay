import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../auth/providers/auth_providers.dart';

/// Settings screen for app configuration and user preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.settings),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            _buildUserProfileSection(context, currentUser),
            const SizedBox(height: AppDimensions.spacingLarge),

            // App Preferences Section
            _buildAppPreferencesSection(context, ref, themeMode, locale),
            const SizedBox(height: AppDimensions.spacingLarge),

            // Business Settings Section
            _buildBusinessSettingsSection(context),
            const SizedBox(height: AppDimensions.spacingLarge),

            // Support & Info Section
            _buildSupportSection(context),
            const SizedBox(height: AppDimensions.spacingLarge),

            // Logout Section
            _buildLogoutSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context, user) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              child: Icon(
                Icons.person,
                color: AppColors.white,
              ),
            ),
            title: Text(user?.phoneNumber ?? 'Not logged in'),
            subtitle: const Text('Merchant Account'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to profile edit screen
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferencesSection(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
    String locale,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Preferences',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Theme Selection
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: Text(_getThemeModeText(themeMode)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showThemeDialog(context, ref, themeMode),
          ),
          
          const Divider(),
          
          // Language Selection
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(locale == 'en' ? 'English' : 'हिंदी'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showLanguageDialog(context, ref, locale),
          ),
          
          const Divider(),
          
          // Notifications
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Payment reminders, updates'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Toggle notifications
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessSettingsSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Settings',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Business Profile'),
            subtitle: const Text('Shop name, address, UPI ID'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to business profile
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Invoice Settings'),
            subtitle: const Text('Templates, numbering, GST'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to invoice settings
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Data Backup'),
            subtitle: const Text('Auto backup to cloud'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Toggle backup
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support & Information',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & FAQ'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to help
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.contact_support),
            title: const Text('Contact Support'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Open support chat/email
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Show about dialog
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Open privacy policy
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          
          AppButton.danger(
            text: 'Logout',
            onPressed: () => _showLogoutDialog(context, ref),
            isFullWidth: true,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).state = value;
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).state = value;
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).state = value;
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, String currentLocale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLocale,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).state = value;
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('हिंदी'),
              value: 'hi',
              groupValue: currentLocale,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).state = value;
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          AppButton.danger(
            text: 'Logout',
            onPressed: () async {
              Navigator.pop(context);
              // Perform logout
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}
