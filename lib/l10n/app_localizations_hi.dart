// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'कलपे';

  @override
  String get tagline => 'दुकानों के लिए स्मार्ट पेलेटर';

  @override
  String get welcome => 'स्वागत';

  @override
  String get continueText => 'जारी रखें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सेव करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get edit => 'संपादित करें';

  @override
  String get done => 'हो गया';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get refresh => 'रिफ्रेश करें';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get error => 'त्रुटि';

  @override
  String get success => 'सफलता';

  @override
  String get warning => 'चेतावनी';

  @override
  String get info => 'जानकारी';

  @override
  String get phoneNumber => 'फोन नंबर';

  @override
  String get enterPhoneNumber => 'अपना फोन नंबर दर्ज करें';

  @override
  String get otp => 'ओटीपी';

  @override
  String get enterOtp => 'ओटीपी दर्ज करें';

  @override
  String get verifyOtp => 'ओटीपी सत्यापित करें';

  @override
  String get resendOtp => 'ओटीपी पुनः भेजें';

  @override
  String otpSent(String phoneNumber) {
    return '$phoneNumber पर ओटीपी भेजा गया';
  }

  @override
  String get selectRole => 'अपनी भूमिका चुनें';

  @override
  String get shopkeeper => 'मैं एक दुकानदार हूं';

  @override
  String get customer => 'मैं एक ग्राहक हूं';

  @override
  String get termsConditions => 'जारी रखकर, आप नियम और शर्तों से सहमत हैं';

  @override
  String get home => 'होम';

  @override
  String get customers => 'ग्राहक';

  @override
  String get reports => 'रिपोर्ट';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get dashboard => 'डैशबोर्ड';

  @override
  String get outstanding => 'बकाया';

  @override
  String get dueToday => 'आज देय';

  @override
  String get paidThisMonth => 'इस महीने भुगतान';

  @override
  String get totalSales => 'कुल बिक्री';

  @override
  String get totalPaid => 'कुल भुगतान';

  @override
  String get totalOutstanding => 'कुल बकाया';

  @override
  String get addSale => 'बिक्री जोड़ें';

  @override
  String get scanQr => 'क्यूआर स्कैन करें';

  @override
  String get requestPayment => 'भुगतान का अनुरोध करें';

  @override
  String get addCustomer => 'ग्राहक जोड़ें';

  @override
  String get markPaid => 'भुगतान के रूप में चिह्नित करें';

  @override
  String get remind => 'याद दिलाएं';

  @override
  String get customerName => 'ग्राहक का नाम';

  @override
  String get customerPhone => 'ग्राहक का फोन';

  @override
  String get amount => 'राशि';

  @override
  String get note => 'नोट';

  @override
  String get item => 'वस्तु';

  @override
  String get dueDate => 'देय तिथि';

  @override
  String get payNow => 'अभी भुगतान करें';

  @override
  String get payLater => 'बाद में भुगतान करें';

  @override
  String get cash => 'नकद';

  @override
  String get upi => 'यूपीआई';

  @override
  String get other => 'अन्य';

  @override
  String get paid => 'भुगतान किया गया';

  @override
  String get pending => 'लंबित';

  @override
  String get overdue => 'अतिदेय';

  @override
  String get partial => 'आंशिक';

  @override
  String get recentTransactions => 'हाल की लेनदेन';

  @override
  String get allTransactions => 'सभी लेनदेन';

  @override
  String get addTransaction => 'लेनदेन जोड़ें';

  @override
  String get transactionDetails => 'लेनदेन विवरण';

  @override
  String get paymentMethod => 'भुगतान विधि';

  @override
  String get transactionId => 'लेनदेन आईडी';

  @override
  String get searchCustomers => 'ग्राहक खोजें...';

  @override
  String get noCustomersFound => 'कोई ग्राहक नहीं मिला';

  @override
  String get addNewCustomer => 'नया ग्राहक जोड़ें';

  @override
  String get customerLedger => 'ग्राहक खाता';

  @override
  String get customerDetails => 'ग्राहक विवरण';

  @override
  String get sendPaymentRequest => 'भुगतान अनुरोध भेजें';

  @override
  String get shareViaWhatsapp => 'व्हाट्सऐप के माध्यम से साझा करें';

  @override
  String get shareViaSms => 'एसएमएस के माध्यम से साझा करें';

  @override
  String get paymentLink => 'भुगतान लिंक';

  @override
  String paymentMessage(String amount) {
    return 'कृपया अपनी बकाया राशि ₹$amount का भुगतान करें';
  }

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get shopName => 'दुकान का नाम';

  @override
  String get upiId => 'यूपीआई आईडी';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get paymentReminders => 'भुगतान अनुस्मारक';

  @override
  String get dataBackup => 'डेटा बैकअप';

  @override
  String get dataRestore => 'डेटा रिस्टोर';

  @override
  String get help => 'सहायता';

  @override
  String get faq => 'अक्सर पूछे जाने वाले प्रश्न';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get dateRange => 'दिनांक सीमा';

  @override
  String get exportCsv => 'सीएसवी निर्यात करें';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String get lastMonth => 'पिछले महीने';

  @override
  String get thisYear => 'इस साल';

  @override
  String get noDataAvailable => 'कोई डेटा उपलब्ध नहीं';

  @override
  String get noTransactionsFound => 'कोई लेनदेन नहीं मिला';

  @override
  String get noCustomersYet => 'अभी तक कोई ग्राहक नहीं';

  @override
  String get addYourFirstCustomer => 'अपना पहला ग्राहक जोड़ें';

  @override
  String get paymentSuccessful => 'भुगतान सफल';

  @override
  String get paymentFailed => 'भुगतान असफल';

  @override
  String get paymentPending => 'भुगतान लंबित';

  @override
  String get confirmPayment => 'भुगतान की पुष्टि करें';

  @override
  String get didYouReceivePayment => 'क्या आपको भुगतान मिला?';

  @override
  String get addTxnId => 'ऑटो-मैच के लिए टीएक्सएन आईडी जोड़ें';

  @override
  String get upiAppNotFound => 'यूपीआई ऐप नहीं मिला - क्यूआर आज़माएं या पे लिंक साझा करें';

  @override
  String get tapTransactionToEdit => 'नोट संपादित करने या भुगतान के रूप में चिह्नित करने के लिए लेनदेन पर टैप करें';

  @override
  String get openUpiApp => 'यूपीआई ऐप खोलें → भुगतान पूरा करें → वापस आएं और पुष्टि करें';

  @override
  String get currency => '₹';

  @override
  String get rupees => 'रुपये';

  @override
  String get paise => 'पैसे';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String get thisWeek => 'इस सप्ताह';

  @override
  String get lastWeek => 'पिछले सप्ताह';

  @override
  String get permissionRequired => 'अनुमति आवश्यक';

  @override
  String get cameraPermission => 'क्यूआर कोड स्कैन करने के लिए कैमरा अनुमति आवश्यक है';

  @override
  String get storagePermission => 'रसीदें सेव करने के लिए स्टोरेज अनुमति आवश्यक है';

  @override
  String get notificationPermission => 'भुगतान अनुस्मारक के लिए सूचना अनुमति आवश्यक है';

  @override
  String get grantPermission => 'अनुमति दें';

  @override
  String get offlineMode => 'ऑफलाइन मोड';

  @override
  String get syncWhenOnline => 'जब आप ऑनलाइन वापस आएंगे तो डेटा सिंक हो जाएगा';

  @override
  String get connectionRestored => 'कनेक्शन बहाल हुआ। डेटा सिंक हो रहा है...';

  @override
  String get validationRequired => 'यह फील्ड आवश्यक है';

  @override
  String get validationInvalidPhone => 'कृपया एक वैध फोन नंबर दर्ज करें';

  @override
  String get validationInvalidAmount => 'कृपया एक वैध राशि दर्ज करें';

  @override
  String get validationAmountTooLow => 'राशि ₹1 से अधिक होनी चाहिए';

  @override
  String get validationAmountTooHigh => 'राशि ₹1,00,000 से अधिक नहीं हो सकती';
}
