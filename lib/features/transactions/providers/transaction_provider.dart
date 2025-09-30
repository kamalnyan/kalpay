import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/transaction_service.dart';
import '../../../shared/models/transaction_model.dart';

// Transaction service provider
final transactionServiceProvider = Provider<TransactionService>((ref) => TransactionService());

// Shop transactions provider
final shopTransactionsProvider = StreamProvider.family<List<TransactionModel>, String>((ref, shopId) {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getShopTransactions(shopId);
});

// Customer transactions provider
final customerTransactionsProvider = StreamProvider.family<List<TransactionModel>, TransactionParams>((ref, params) {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getCustomerTransactions(params.shopId, params.customerId);
});

// Recent transactions provider
final recentTransactionsProvider = StreamProvider.family<List<TransactionModel>, String>((ref, shopId) {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getRecentTransactions(shopId);
});

// Outstanding transactions provider
final outstandingTransactionsProvider = StreamProvider.family<List<TransactionModel>, String>((ref, shopId) {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getOutstandingTransactions(shopId);
});

// Due today transactions provider
final dueTodayTransactionsProvider = StreamProvider.family<List<TransactionModel>, String>((ref, shopId) {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getTransactionsDueToday(shopId);
});

// Transaction state provider
final transactionStateProvider = StateNotifierProvider<TransactionStateNotifier, TransactionState>((ref) {
  final transactionService = ref.watch(transactionServiceProvider);
  return TransactionStateNotifier(transactionService);
});

// Transaction params
class TransactionParams {
  final String shopId;
  final String customerId;

  const TransactionParams({
    required this.shopId,
    required this.customerId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionParams &&
          runtimeType == other.runtimeType &&
          shopId == other.shopId &&
          customerId == other.customerId;

  @override
  int get hashCode => shopId.hashCode ^ customerId.hashCode;
}

// Transaction state
class TransactionState {
  final bool isLoading;
  final String? error;
  final TransactionModel? selectedTransaction;

  const TransactionState({
    this.isLoading = false,
    this.error,
    this.selectedTransaction,
  });

  TransactionState copyWith({
    bool? isLoading,
    String? error,
    TransactionModel? selectedTransaction,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTransaction: selectedTransaction ?? this.selectedTransaction,
    );
  }
}

// Transaction state notifier
class TransactionStateNotifier extends StateNotifier<TransactionState> {
  final TransactionService _transactionService;

  TransactionStateNotifier(this._transactionService) : super(const TransactionState());

  // Add transaction
  Future<TransactionModel?> addTransaction({
    required String shopId,
    required String customerId,
    required double amount,
    required String type,
    required String method,
    String? note,
    DateTime? dueDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final transaction = await _transactionService.addTransaction(
        shopId: shopId,
        customerId: customerId,
        amount: (amount * 100).round(), // Convert to paise
        type: type,
        method: method,
        note: note,
        dueDate: dueDate,
      );

      state = state.copyWith(isLoading: false);
      return transaction;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Mark transaction as paid
  Future<bool> markTransactionAsPaid({
    required String shopId,
    required String customerId,
    required String transactionId,
    required String paymentMethod,
    String? upiTxnId,
    String? reference,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _transactionService.markTransactionAsPaid(
        shopId: shopId,
        customerId: customerId,
        transactionId: transactionId,
        paymentMethod: paymentMethod,
        upiTxnId: upiTxnId,
        reference: reference,
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Update transaction
  Future<bool> updateTransaction(
    String shopId,
    String customerId,
    String transactionId,
    Map<String, dynamic> updates,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _transactionService.updateTransaction(shopId, customerId, transactionId, updates);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(String shopId, String customerId, String transactionId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _transactionService.deleteTransaction(shopId, customerId, transactionId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Select transaction
  void selectTransaction(TransactionModel transaction) {
    state = state.copyWith(selectedTransaction: transaction);
  }

  // Clear selection
  void clearSelection() {
    state = state.copyWith(selectedTransaction: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
