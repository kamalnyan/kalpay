// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KalPay';

  @override
  String get tagline => 'Smart PayLater for Shops';

  @override
  String get welcome => 'Welcome';

  @override
  String get continueText => 'Continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get otp => 'OTP';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String otpSent(String phoneNumber) {
    return 'OTP sent to $phoneNumber';
  }

  @override
  String get selectRole => 'Select your role';

  @override
  String get shopkeeper => 'I\'m a shopkeeper';

  @override
  String get customer => 'I\'m a customer';

  @override
  String get termsConditions => 'By continuing, you agree to Terms & Conditions';

  @override
  String get home => 'Home';

  @override
  String get customers => 'Customers';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get outstanding => 'Outstanding';

  @override
  String get dueToday => 'Due Today';

  @override
  String get paidThisMonth => 'Paid This Month';

  @override
  String get totalSales => 'Total Sales';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get totalOutstanding => 'Total Outstanding';

  @override
  String get addSale => 'Add Sale';

  @override
  String get scanQr => 'Scan QR';

  @override
  String get requestPayment => 'Request Payment';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get markPaid => 'Mark as Paid';

  @override
  String get remind => 'Remind';

  @override
  String get customerName => 'Customer Name';

  @override
  String get customerPhone => 'Customer Phone';

  @override
  String get amount => 'Amount';

  @override
  String get note => 'Note';

  @override
  String get item => 'Item';

  @override
  String get dueDate => 'Due Date';

  @override
  String get payNow => 'Pay Now';

  @override
  String get payLater => 'Pay Later';

  @override
  String get cash => 'Cash';

  @override
  String get upi => 'UPI';

  @override
  String get other => 'Other';

  @override
  String get paid => 'Paid';

  @override
  String get pending => 'Pending';

  @override
  String get overdue => 'Overdue';

  @override
  String get partial => 'Partial';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get allTransactions => 'All Transactions';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get searchCustomers => 'Search customers...';

  @override
  String get noCustomersFound => 'No customers found';

  @override
  String get addNewCustomer => 'Add New Customer';

  @override
  String get customerLedger => 'Customer Ledger';

  @override
  String get customerDetails => 'Customer Details';

  @override
  String get sendPaymentRequest => 'Send Payment Request';

  @override
  String get shareViaWhatsapp => 'Share via WhatsApp';

  @override
  String get shareViaSms => 'Share via SMS';

  @override
  String get paymentLink => 'Payment Link';

  @override
  String paymentMessage(String amount) {
    return 'Please pay your pending balance of ₹$amount';
  }

  @override
  String get profile => 'Profile';

  @override
  String get shopName => 'Shop Name';

  @override
  String get upiId => 'UPI ID';

  @override
  String get notifications => 'Notifications';

  @override
  String get paymentReminders => 'Payment Reminders';

  @override
  String get dataBackup => 'Data Backup';

  @override
  String get dataRestore => 'Data Restore';

  @override
  String get help => 'Help';

  @override
  String get faq => 'FAQ';

  @override
  String get logout => 'Logout';

  @override
  String get dateRange => 'Date Range';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get noCustomersYet => 'No customers yet';

  @override
  String get addYourFirstCustomer => 'Add your first customer';

  @override
  String get paymentSuccessful => 'Payment Successful';

  @override
  String get paymentFailed => 'Payment Failed';

  @override
  String get paymentPending => 'Payment Pending';

  @override
  String get confirmPayment => 'Confirm Payment';

  @override
  String get didYouReceivePayment => 'Did you receive payment?';

  @override
  String get addTxnId => 'Add TXN ID to auto-match';

  @override
  String get upiAppNotFound => 'UPI app not found - try QR or share pay link';

  @override
  String get tapTransactionToEdit => 'Tap a transaction to edit note or mark as paid';

  @override
  String get openUpiApp => 'Open UPI app → Complete payment → Return and confirm';

  @override
  String get currency => '₹';

  @override
  String get rupees => 'Rupees';

  @override
  String get paise => 'Paise';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get lastWeek => 'Last Week';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get cameraPermission => 'Camera permission is required to scan QR codes';

  @override
  String get storagePermission => 'Storage permission is required to save receipts';

  @override
  String get notificationPermission => 'Notification permission is required for payment reminders';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get syncWhenOnline => 'Data will sync when you\'re back online';

  @override
  String get connectionRestored => 'Connection restored. Syncing data...';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationInvalidPhone => 'Please enter a valid phone number';

  @override
  String get validationInvalidAmount => 'Please enter a valid amount';

  @override
  String get validationAmountTooLow => 'Amount must be greater than ₹1';

  @override
  String get validationAmountTooHigh => 'Amount cannot exceed ₹1,00,000';
}
