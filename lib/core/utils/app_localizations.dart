import 'package:flutter/material.dart';

/// Extension to easily access app localizations
extension AppLocalizationsX on BuildContext {
  // Temporary implementation - will be replaced with generated localizations
  dynamic get l10n => _TempLocalizations();
}

class _TempLocalizations {
  String get appTitle => 'KalPay';
  String get tagline => 'Smart PayLater for Shops';
  String get welcome => 'Welcome';
  String get continueText => 'Continue';
  String get selectRole => 'Select your role';
  String get shopkeeper => "I'm a shopkeeper";
  String get customer => "I'm a customer";
  String get termsConditions => 'By continuing, you agree to Terms & Conditions';
  String get phoneNumber => 'Phone Number';
  String get enterPhoneNumber => 'Enter your phone number';
  String get otp => 'OTP';
  String get enterOtp => 'Enter OTP';
  String get verifyOtp => 'Verify OTP';
  String get resendOtp => 'Resend OTP';
  String otpSent(String phone) => 'OTP sent to $phone';
  String get home => 'Home';
  String get customers => 'Customers';
  String get reports => 'Reports';
  String get settings => 'Settings';
  String get dashboard => 'Dashboard';
  String get outstanding => 'Outstanding';
  String get dueToday => 'Due Today';
  String get paidThisMonth => 'Paid This Month';
  String get addSale => 'Add Sale';
  String get scanQr => 'Scan QR';
  String get requestPayment => 'Request Payment';
  String get addCustomer => 'Add Customer';
  String get recentTransactions => 'Recent Transactions';
  String get paid => 'Paid';
  String get pending => 'Pending';
  String get searchCustomers => 'Search customers...';
  String get noCustomersFound => 'No customers found';
  String get noCustomersYet => 'No customers yet';
  String get addYourFirstCustomer => 'Add your first customer';
  String get today => 'Today';
  String get yesterday => 'Yesterday';
  String get payNow => 'Pay Now';
  String get payLater => 'Pay Later';
  String get save => 'Save';
}

/// Utility class for localization helpers
class LocalizationHelper {
  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('hi', ''),
  ];

  static const Locale fallbackLocale = Locale('en', '');

  /// Get locale from language code
  static Locale getLocaleFromLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return const Locale('hi', '');
      case 'en':
      default:
        return const Locale('en', '');
    }
  }

  /// Get language name from locale
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'hi':
        return 'हिंदी';
      case 'en':
      default:
        return 'English';
    }
  }

  /// Check if locale is supported
  static bool isLocaleSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode);
  }
}
