import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase service for authentication, database, and cloud services
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Initialize Firebase services
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      
      // Enable offline persistence for Firestore (web only)
      // For mobile platforms, persistence is enabled by default
      try {
        await FirebaseFirestore.instance.enablePersistence();
      } catch (e) {
        // enablePersistence() is only available for web
        // For mobile platforms, persistence is enabled by default
        print('Firestore persistence: ${e.toString()}');
      }
      
      // Initialize Firebase Analytics
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      
      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization error: $e');
      print('Running in demo mode without Firebase');
      // Don't rethrow - allow app to continue without Firebase
    }
  }

  /// Configure Firebase Cloud Messaging
  static Future<void> _configureMessaging() async {
    // Request notification permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Get FCM token
    final token = await _messaging.getToken();
    print('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Authentication methods
  static Future<UserCredential?> signInWithPhone(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Firestore operations
  static Future<void> saveUserData(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userId).set(userData, SetOptions(merge: true));
      _analytics.logEvent(name: 'user_data_saved');
    } catch (e) {
      _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  static Future<DocumentSnapshot> getUserData(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  static Future<void> saveTransaction(String userId, Map<String, dynamic> transaction) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .add(transaction);
      _analytics.logEvent(name: 'transaction_saved');
    } catch (e) {
      _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  static Stream<QuerySnapshot> getTransactions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> saveCustomer(String userId, Map<String, dynamic> customer) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('customers')
          .add(customer);
      _analytics.logEvent(name: 'customer_saved');
    } catch (e) {
      _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  static Stream<QuerySnapshot> getCustomers(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('customers')
        .orderBy('name')
        .snapshots();
  }

  /// Analytics methods
  static Future<void> logEvent(String eventName, {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(name: eventName, parameters: parameters);
  }

  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
    await _crashlytics.setUserIdentifier(userId);
  }

  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// Storage methods
  static Future<String> uploadFile(String path, List<int> data) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putData(Uint8List.fromList(data));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  static Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (e) {
      _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Crashlytics methods
  static void recordError(dynamic exception, StackTrace? stackTrace) {
    _crashlytics.recordError(exception, stackTrace);
  }

  static void log(String message) {
    _crashlytics.log(message);
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}
