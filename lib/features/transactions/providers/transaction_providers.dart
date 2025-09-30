import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/upi_service.dart';
import '../../../shared/models/customer_model.dart' as models;
import '../../../shared/providers/app_providers.dart';
import '../../auth/providers/auth_providers.dart';

/// All transactions provider
final transactionsProvider = StreamProvider<List<models.Transaction>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return FirebaseService.getTransactions(user.uid).map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return models.Transaction.fromJson({...data, 'id': doc.id});
    }).toList();
  });
});

/// Recent transactions provider (last 10)
final recentTransactionsProvider = Provider<List<models.Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  
  return transactions.when(
    data: (transactionList) {
      final sorted = [...transactionList];
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sorted.take(10).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Outstanding transactions provider
final outstandingTransactionsProvider = Provider<List<models.Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  
  return transactions.when(
    data: (transactionList) {
      return transactionList
          .where((t) => t.status == models.TransactionStatus.outstanding)
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Total outstanding amount provider
final totalOutstandingProvider = Provider<double>((ref) {
  final outstandingTransactions = ref.watch(outstandingTransactionsProvider);
  
  return outstandingTransactions.fold(0.0, (total, transaction) {
    return total + (transaction.type == models.TransactionType.credit 
        ? transaction.amount 
        : -transaction.amount);
  });
});

/// Today's transactions provider
final todayTransactionsProvider = Provider<List<models.Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final today = DateTime.now();
  
  return transactions.when(
    data: (transactionList) {
      return transactionList.where((transaction) {
        return transaction.createdAt.year == today.year &&
               transaction.createdAt.month == today.month &&
               transaction.createdAt.day == today.day;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Add transaction provider
final addTransactionProvider = Provider<Future<void> Function(models.Transaction)>((ref) {
  return (transaction) async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await FirebaseService.saveTransaction(user.uid, transaction.toJson());
    }
  };
});

/// Transaction form provider
final transactionFormProvider = StateNotifierProvider<TransactionFormNotifier, TransactionFormState>((ref) {
  return TransactionFormNotifier();
});

/// Transaction form state
class TransactionFormState {
  final String customerId;
  final String customerName;
  final double amount;
  final models.TransactionType type;
  final models.PaymentMethod method;
  final String note;
  final String description;
  final DateTime? dueDate;
  final bool isLoading;
  final String? errorMessage;

  const TransactionFormState({
    this.customerId = '',
    this.customerName = '',
    this.amount = 0.0,
    this.type = models.TransactionType.credit,
    this.method = models.PaymentMethod.cash,
    this.note = '',
    this.description = '',
    this.dueDate,
    this.isLoading = false,
    this.errorMessage,
  });

  TransactionFormState copyWith({
    String? customerId,
    String? customerName,
    double? amount,
    models.TransactionType? type,
    models.PaymentMethod? method,
    String? note,
    String? description,
    DateTime? dueDate,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TransactionFormState(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      method: method ?? this.method,
      note: note ?? this.note,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isValid => customerId.isNotEmpty && amount > 0;
}

/// Transaction form notifier
class TransactionFormNotifier extends StateNotifier<TransactionFormState> {
  TransactionFormNotifier() : super(const TransactionFormState());

  void updateCustomer(String customerId, String customerName) {
    state = state.copyWith(
      customerId: customerId,
      customerName: customerName,
      errorMessage: null,
    );
  }

  void updateAmount(double amount) {
    state = state.copyWith(amount: amount, errorMessage: null);
  }

  void updateType(models.TransactionType type) {
    state = state.copyWith(type: type, errorMessage: null);
  }

  void updateMethod(models.PaymentMethod method) {
    state = state.copyWith(method: method, errorMessage: null);
  }

  void updateNote(String note) {
    state = state.copyWith(note: note, errorMessage: null);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description, errorMessage: null);
  }

  void updateDueDate(DateTime? dueDate) {
    state = state.copyWith(dueDate: dueDate, errorMessage: null);
  }

  Future<bool> saveTransaction(Ref ref) async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'Please fill required fields');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final transaction = models.Transaction(
        id: '', // Will be set by Firestore
        customerId: state.customerId,
        amount: state.amount,
        type: state.type,
        status: state.method == models.PaymentMethod.payLater 
            ? models.TransactionStatus.outstanding 
            : models.TransactionStatus.paid,
        method: state.method,
        note: state.note.isNotEmpty ? state.note : null,
        description: state.description.isNotEmpty ? state.description : null,
        dueDate: state.dueDate,
        createdAt: DateTime.now(),
      );

      final addTransaction = ref.read(addTransactionProvider);
      await addTransaction(transaction);

      state = state.copyWith(isLoading: false);
      reset();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save transaction: $e',
      );
      return false;
    }
  }

  void reset() {
    state = const TransactionFormState();
  }
}

/// UPI payment provider
final upiPaymentProvider = StateNotifierProvider<UpiPaymentNotifier, UpiPaymentState>((ref) {
  return UpiPaymentNotifier(ref.read(upiServiceProvider));
});

/// UPI payment state
class UpiPaymentState {
  final bool isLoading;
  final String? qrData;
  final Map<String, dynamic>? result;
  final String? errorMessage;

  const UpiPaymentState({
    this.isLoading = false,
    this.qrData,
    this.result,
    this.errorMessage,
  });

  UpiPaymentState copyWith({
    bool? isLoading,
    String? qrData,
    Map<String, dynamic>? result,
    String? errorMessage,
  }) {
    return UpiPaymentState(
      isLoading: isLoading ?? this.isLoading,
      qrData: qrData ?? this.qrData,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// UPI payment notifier
class UpiPaymentNotifier extends StateNotifier<UpiPaymentState> {
  final UpiService _upiService;

  UpiPaymentNotifier(this._upiService) : super(const UpiPaymentState());

  Future<void> initiatePayment({
    required String upiId,
    required String payeeName,
    required double amount,
    required String note,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await UpiService.launchUpiPayment(
        upiId: upiId,
        merchantName: payeeName,
        amount: amount,
        transactionNote: note,
      );

      state = state.copyWith(
        isLoading: false,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setQrData(String qrData) {
    state = state.copyWith(qrData: qrData);
  }

  void reset() {
    state = const UpiPaymentState();
  }
}
