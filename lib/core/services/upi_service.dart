import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

class UpiService {
  static const String _defaultUpiId = 'merchant@paytm';
  
  /// Generate UPI payment URL
  static String generateUpiUrl({
    required String upiId,
    required String merchantName,
    required double amount,
    String? transactionNote,
    String? transactionRef,
  }) {
    final uri = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': upiId,
        'pn': merchantName,
        'am': amount.toStringAsFixed(2),
        'cu': 'INR',
        if (transactionNote != null) 'tn': transactionNote,
        if (transactionRef != null) 'tr': transactionRef,
      },
    );
    
    return uri.toString();
  }
  
  /// Launch UPI payment with callback handling
  static Future<Map<String, dynamic>> launchUpiPayment({
    required String upiId,
    required String merchantName,
    required double amount,
    String? transactionNote,
    String? transactionRef,
  }) async {
    final upiUrl = generateUpiUrl(
      upiId: upiId,
      merchantName: merchantName,
      amount: amount,
      transactionNote: transactionNote,
      transactionRef: transactionRef,
    );
    
    try {
      final uri = Uri.parse(upiUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return {
          'status': 'launched',
          'message': 'UPI payment launched successfully',
        };
      } else {
        return {
          'status': 'failed',
          'message': 'No UPI app available to handle payment',
        };
      }
    } catch (e) {
      return {
        'status': 'failed',
        'message': 'Error launching UPI payment: $e',
      };
    }
  }
  
  /// Generate QR code widget for UPI payment
  Widget generateUpiQrCode({
    required String upiId,
    required String payeeName,
    required double amount,
    required String transactionNote,
    double size = 200.0,
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    final upiUrl = generateUpiUrl(
      upiId: upiId,
      merchantName: payeeName,
      amount: amount,
      transactionNote: transactionNote,
    );

    return QrImageView(
      data: upiUrl,
      version: QrVersions.auto,
      size: size,
      foregroundColor: foregroundColor ?? Colors.black,
      backgroundColor: backgroundColor ?? Colors.white,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }

  /// Validate UPI ID format
  bool isValidUpiId(String upiId) {
    // Basic UPI ID validation pattern
    final upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');
    return upiRegex.hasMatch(upiId);
  }

  /// Extract UPI ID from QR code data
  String? extractUpiIdFromQr(String qrData) {
    try {
      final uri = Uri.parse(qrData);
      if (uri.scheme == 'upi' && uri.host == 'pay') {
        return uri.queryParameters['pa'];
      }
    } catch (e) {
      // Invalid QR data
    }
    return null;
  }

  /// Parse UPI payment response (if available from UPI apps)
  UpiTransactionResult parseUpiResponse(Map<String, dynamic>? response) {
    if (response == null) {
      return UpiTransactionResult(
        status: UpiTransactionStatus.unknown,
        message: 'No response received from UPI app',
      );
    }

    final status = response['Status'] as String?;
    final txnId = response['txnId'] as String?;
    final responseCode = response['responseCode'] as String?;

    switch (status?.toLowerCase()) {
      case 'success':
        return UpiTransactionResult(
          status: UpiTransactionStatus.success,
          transactionId: txnId,
          message: 'Payment successful',
        );
      case 'failure':
        return UpiTransactionResult(
          status: UpiTransactionStatus.failure,
          message: response['message'] as String? ?? 'Payment failed',
        );
      case 'submitted':
        return UpiTransactionResult(
          status: UpiTransactionStatus.submitted,
          message: 'Payment submitted for processing',
        );
      default:
        return UpiTransactionResult(
          status: UpiTransactionStatus.unknown,
          message: 'Unknown payment status',
        );
    }
  }
}

/// UPI transaction result model
class UpiTransactionResult {
  final UpiTransactionStatus status;
  final String? transactionId;
  final String message;
  final Map<String, dynamic>? additionalData;

  UpiTransactionResult({
    required this.status,
    this.transactionId,
    required this.message,
    this.additionalData,
  });
}

/// UPI transaction status enum
enum UpiTransactionStatus {
  success,
  failure,
  submitted,
  unknown,
}

/// UPI app information
class UpiApp {
  final String packageName;
  final String appName;
  final String iconAsset;

  const UpiApp({
    required this.packageName,
    required this.appName,
    required this.iconAsset,
  });

  static const List<UpiApp> popularApps = [
    UpiApp(
      packageName: 'com.google.android.apps.nbu.paisa.user',
      appName: 'Google Pay',
      iconAsset: 'assets/icons/gpay.png',
    ),
    UpiApp(
      packageName: 'com.phonepe.app',
      appName: 'PhonePe',
      iconAsset: 'assets/icons/phonepe.png',
    ),
    UpiApp(
      packageName: 'net.one97.paytm',
      appName: 'Paytm',
      iconAsset: 'assets/icons/paytm.png',
    ),
    UpiApp(
      packageName: 'com.amazon.mobile.shopping',
      appName: 'Amazon Pay',
      iconAsset: 'assets/icons/amazon_pay.png',
    ),
  ];
}
