import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add new transaction
  Future<TransactionModel> addTransaction({
    required String shopId,
    required String customerId,
    required int amount,
    required String type,
    required String method,
    String? note,
    DateTime? dueDate,
  }) async {
    try {
      final transaction = TransactionModel.create(
        shopId: shopId,
        customerId: customerId,
        amount: amount,
        type: type,
        method: method,
        note: note,
        dueDate: dueDate,
      );

      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('customers')
          .doc(customerId)
          .collection('transactions')
          .doc(transaction.transactionId)
          .set(transaction.toJson());

      // Update customer outstanding amount if pay later
      if (method == 'paylater') {
        final amountChange = type == 'credit' ? amount : -amount;
        await _updateCustomerOutstanding(shopId, customerId, amountChange);
        await _updateShopSummary(shopId, {'totalOutstanding': FieldValue.increment(amountChange)});
      } else {
        await _updateShopSummary(shopId, {'totalPaid': FieldValue.increment(amount)});
      }

      return transaction;
    } catch (e) {
      throw Exception('Failed to add transaction: ${e.toString()}');
    }
  }

  // Get transactions for a customer
  Stream<List<TransactionModel>> getCustomerTransactions(String shopId, String customerId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('customers')
        .doc(customerId)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .toList());
  }

  // Get all transactions for a shop
  Stream<List<TransactionModel>> getShopTransactions(String shopId) {
    return _firestore
        .collectionGroup('transactions')
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .toList());
  }

  // Get recent transactions
  Stream<List<TransactionModel>> getRecentTransactions(String shopId, {int limit = 10}) {
    return _firestore
        .collectionGroup('transactions')
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .toList());
  }

  // Mark transaction as paid
  Future<void> markTransactionAsPaid({
    required String shopId,
    required String customerId,
    required String transactionId,
    required String paymentMethod,
    String? upiTxnId,
    String? reference,
  }) async {
    try {
      final transactionRef = _firestore
          .collection('shops')
          .doc(shopId)
          .collection('customers')
          .doc(customerId)
          .collection('transactions')
          .doc(transactionId);

      final transactionDoc = await transactionRef.get();
      if (!transactionDoc.exists) {
        throw Exception('Transaction not found');
      }

      final transaction = TransactionModel.fromJson(transactionDoc.data()!);
      
      if (transaction.status == 'paid') {
        throw Exception('Transaction already paid');
      }

      final paymentInfo = PaymentInfo(
        paidAt: DateTime.now(),
        paidBy: paymentMethod,
        upiTxnId: upiTxnId,
        reference: reference,
      );

      await transactionRef.update({
        'status': 'paid',
        'paymentInfo': paymentInfo.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update customer outstanding amount
      final amountChange = transaction.type == 'credit' ? -transaction.amount : transaction.amount;
      await _updateCustomerOutstanding(shopId, customerId, amountChange);

      // Update shop summary
      await _updateShopSummary(shopId, {
        'totalOutstanding': FieldValue.increment(amountChange),
        'totalPaid': FieldValue.increment(transaction.amount),
      });
    } catch (e) {
      throw Exception('Failed to mark transaction as paid: ${e.toString()}');
    }
  }

  // Get outstanding transactions
  Stream<List<TransactionModel>> getOutstandingTransactions(String shopId) {
    return _firestore
        .collectionGroup('transactions')
        .where('shopId', isEqualTo: shopId)
        .where('status', isEqualTo: 'outstanding')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .toList());
  }

  // Get transactions due today
  Stream<List<TransactionModel>> getTransactionsDueToday(String shopId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _firestore
        .collectionGroup('transactions')
        .where('shopId', isEqualTo: shopId)
        .where('status', isEqualTo: 'outstanding')
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .toList());
  }

  // Update transaction
  Future<void> updateTransaction(
    String shopId,
    String customerId,
    String transactionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('customers')
          .doc(customerId)
          .collection('transactions')
          .doc(transactionId)
          .update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update transaction: ${e.toString()}');
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String shopId, String customerId, String transactionId) async {
    try {
      final transactionRef = _firestore
          .collection('shops')
          .doc(shopId)
          .collection('customers')
          .doc(customerId)
          .collection('transactions')
          .doc(transactionId);

      final transactionDoc = await transactionRef.get();
      if (!transactionDoc.exists) {
        throw Exception('Transaction not found');
      }

      final transaction = TransactionModel.fromJson(transactionDoc.data()!);
      
      await transactionRef.delete();

      // Update customer outstanding amount if transaction was outstanding
      if (transaction.status == 'outstanding') {
        final amountChange = transaction.type == 'credit' ? -transaction.amount : transaction.amount;
        await _updateCustomerOutstanding(shopId, customerId, amountChange);
        await _updateShopSummary(shopId, {'totalOutstanding': FieldValue.increment(amountChange)});
      }
    } catch (e) {
      throw Exception('Failed to delete transaction: ${e.toString()}');
    }
  }

  // Helper methods
  Future<void> _updateCustomerOutstanding(String shopId, String customerId, int amountChange) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('customers')
        .doc(customerId)
        .update({
      'outstandingAmount': FieldValue.increment(amountChange),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateShopSummary(String shopId, Map<String, dynamic> updates) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('summary')
        .doc('current')
        .update({
      ...updates,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}
