import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add new customer
  Future<Customer> addCustomer({
    required String shopId,
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    try {
      final customer = Customer.create(
        shopId: shopId,
        name: name,
        phone: phone,
        email: email,
        address: address,
      );

      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('customers')
          .doc(customer.id)
          .set(customer.toJson());

      // Update customer count in shop summary
      await _updateShopSummary(shopId, {'customerCount': FieldValue.increment(1)});

      return customer;
    } catch (e) {
      throw Exception('Failed to add customer: ${e.toString()}');
    }
  }

  // Get all customers for a shop
  Stream<List<Customer>> getCustomers(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('customers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Customer.fromJson(doc.data()))
            .toList());
  }

  // Get customer by ID
  Future<Customer?> getCustomer(String shopId, String customerId) async {
    try {
      final doc = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('customers')
          .doc(customerId)
          .get();

      if (doc.exists) {
        return Customer.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get customer: ${e.toString()}');
    }
  }

  // Update customer
  Future<void> updateCustomer(
    String shopId,
    String customerId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('customers')
          .doc(customerId)
          .update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update customer: ${e.toString()}');
    }
  }

  // Delete customer
  Future<void> deleteCustomer(String shopId, String customerId) async {
    try {
      // Delete all transactions for this customer
      final transactionsQuery = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('customers')
          .doc(customerId)
          .collection('transactions')
          .get();

      final batch = _firestore.batch();
      
      for (final doc in transactionsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete customer document
      batch.delete(_firestore
          .collection('shops')
          .doc(shopId)
          .collection('customers')
          .doc(customerId));

      await batch.commit();

      // Update customer count in shop summary
      await _updateShopSummary(shopId, {'customerCount': FieldValue.increment(-1)});
    } catch (e) {
      throw Exception('Failed to delete customer: ${e.toString()}');
    }
  }

  // Search customers
  Stream<List<Customer>> searchCustomers(String shopId, String query) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('customers')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Customer.fromJson(doc.data()))
            .toList());
  }

  // Update customer outstanding amount
  Future<void> updateCustomerOutstanding(
    String shopId,
    String customerId,
    int amountChange,
  ) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('customers')
          .doc(customerId)
          .update({
        'outstandingAmount': FieldValue.increment(amountChange),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update customer outstanding: ${e.toString()}');
    }
  }

  // Get customers with outstanding amounts
  Stream<List<Customer>> getCustomersWithOutstanding(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('customers')
        .where('outstandingAmount', isGreaterThan: 0)
        .orderBy('outstandingAmount', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Customer.fromJson(doc.data()))
            .toList());
  }

  // Helper method to update shop summary
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
