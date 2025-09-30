import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/customer_service.dart';
import '../../../shared/models/customer_model.dart';

// Customer service provider
final customerServiceProvider = Provider<CustomerService>((ref) => CustomerService());

// Customers list provider
final customersProvider = StreamProvider.family<List<Customer>, String>((ref, shopId) {
  final customerService = ref.watch(customerServiceProvider);
  return customerService.getCustomers(shopId);
});

// Customer search provider
final customerSearchProvider = StreamProvider.family<List<Customer>, CustomerSearchParams>((ref, params) {
  final customerService = ref.watch(customerServiceProvider);
  if (params.query.isEmpty) {
    return customerService.getCustomers(params.shopId);
  }
  return customerService.searchCustomers(params.shopId, params.query);
});

// Outstanding customers provider
final outstandingCustomersProvider = StreamProvider.family<List<Customer>, String>((ref, shopId) {
  final customerService = ref.watch(customerServiceProvider);
  return customerService.getCustomersWithOutstanding(shopId);
});

// Customer state provider
final customerStateProvider = StateNotifierProvider<CustomerStateNotifier, CustomerState>((ref) {
  final customerService = ref.watch(customerServiceProvider);
  return CustomerStateNotifier(customerService);
});

// Customer search params
class CustomerSearchParams {
  final String shopId;
  final String query;

  const CustomerSearchParams({
    required this.shopId,
    required this.query,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerSearchParams &&
          runtimeType == other.runtimeType &&
          shopId == other.shopId &&
          query == other.query;

  @override
  int get hashCode => shopId.hashCode ^ query.hashCode;
}

// Customer state
class CustomerState {
  final bool isLoading;
  final String? error;
  final Customer? selectedCustomer;

  const CustomerState({
    this.isLoading = false,
    this.error,
    this.selectedCustomer,
  });

  CustomerState copyWith({
    bool? isLoading,
    String? error,
    Customer? selectedCustomer,
  }) {
    return CustomerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
    );
  }
}

// Customer state notifier
class CustomerStateNotifier extends StateNotifier<CustomerState> {
  final CustomerService _customerService;

  CustomerStateNotifier(this._customerService) : super(const CustomerState());

  // Add customer
  Future<Customer?> addCustomer({
    required String shopId,
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final customer = await _customerService.addCustomer(
        shopId: shopId,
        name: name,
        phone: phone,
        email: email,
        address: address,
      );

      state = state.copyWith(isLoading: false);
      return customer;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Update customer
  Future<bool> updateCustomer(
    String shopId,
    String customerId,
    Map<String, dynamic> updates,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _customerService.updateCustomer(shopId, customerId, updates);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Delete customer
  Future<bool> deleteCustomer(String shopId, String customerId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _customerService.deleteCustomer(shopId, customerId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Select customer
  void selectCustomer(Customer customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  // Clear selection
  void clearSelection() {
    state = state.copyWith(selectedCustomer: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
