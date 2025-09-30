import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firebase_service.dart';
import '../../../shared/models/customer_model.dart' as models;
import '../../auth/providers/auth_providers.dart';

/// Customers list provider
final customersProvider = StreamProvider<List<models.Customer>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return FirebaseService.getCustomers(user.uid).map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return models.Customer.fromJson({...data, 'id': doc.id});
    }).toList();
  });
});

/// Customer search provider
final customerSearchProvider = StateProvider<String>((ref) => '');

/// Filtered customers provider
final filteredCustomersProvider = Provider<List<models.Customer>>((ref) {
  final customers = ref.watch(customersProvider);
  final searchQuery = ref.watch(customerSearchProvider);

  return customers.when(
    data: (customerList) {
      if (searchQuery.isEmpty) return customerList;
      
      return customerList.where((customer) {
        return customer.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               customer.phone.contains(searchQuery);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Add customer provider
final addCustomerProvider = Provider<Future<void> Function(models.Customer)>((ref) {
  return (customer) async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await FirebaseService.saveCustomer(user.uid, customer.toJson());
    }
  };
});

/// Customer details provider
final customerDetailsProvider = FutureProvider.family<models.Customer?, String>((ref, customerId) async {
  final customers = ref.watch(customersProvider);
  
  return customers.when(
    data: (customerList) {
      try {
        return customerList.firstWhere((customer) => customer.id == customerId);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Customer transactions provider
final customerTransactionsProvider = StreamProvider.family<List<models.Transaction>, String>((ref, customerId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return FirebaseService.getTransactions(user.uid).map((snapshot) {
    return snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return models.Transaction.fromJson({...data, 'id': doc.id});
        })
        .where((transaction) => transaction.customerId == customerId)
        .toList();
  });
});

/// Customer outstanding amount provider
final customerOutstandingProvider = Provider.family<double, String>((ref, customerId) {
  final transactions = ref.watch(customerTransactionsProvider(customerId));
  
  return transactions.when(
    data: (transactionList) {
      return transactionList
          .where((t) => t.status == models.TransactionStatus.outstanding)
          .fold(0.0, (sum, transaction) {
            return sum + (transaction.type == models.TransactionType.credit 
                ? transaction.amount 
                : -transaction.amount);
          });
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Customer form state provider
final customerFormProvider = StateNotifierProvider<CustomerFormNotifier, CustomerFormState>((ref) {
  return CustomerFormNotifier();
});

/// Customer form state
class CustomerFormState {
  final String name;
  final String phone;
  final String email;
  final String address;
  final bool isLoading;
  final String? errorMessage;

  const CustomerFormState({
    this.name = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.isLoading = false,
    this.errorMessage,
  });

  CustomerFormState copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CustomerFormState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isValid => name.isNotEmpty && phone.isNotEmpty;
}

/// Customer form notifier
class CustomerFormNotifier extends StateNotifier<CustomerFormState> {
  CustomerFormNotifier() : super(const CustomerFormState());

  void updateName(String name) {
    state = state.copyWith(name: name, errorMessage: null);
  }

  void updatePhone(String phone) {
    state = state.copyWith(phone: phone, errorMessage: null);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void updateAddress(String address) {
    state = state.copyWith(address: address, errorMessage: null);
  }

  Future<bool> saveCustomer(ProviderRef ref) async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'Please fill required fields');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final customer = models.Customer(
        id: '', // Will be set by Firestore
        name: state.name,
        phone: state.phone,
        email: state.email.isNotEmpty ? state.email : null,
        address: state.address.isNotEmpty ? state.address : null,
        createdAt: DateTime.now(),
      );

      final addCustomer = ref.read(addCustomerProvider);
      await addCustomer(customer);

      state = state.copyWith(isLoading: false);
      reset();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save customer: $e',
      );
      return false;
    }
  }

  void reset() {
    state = const CustomerFormState();
  }
}
