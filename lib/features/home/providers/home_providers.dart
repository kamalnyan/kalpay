import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/customer_model.dart';
import '../../auth/providers/auth_providers.dart';
import '../../transactions/providers/transaction_providers.dart';
import '../../customers/providers/customer_providers.dart';

/// Dashboard summary provider
final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final customers = ref.watch(customersProvider);
  
  return transactions.when(
    data: (transactionList) {
      final customerList = customers.when(
        data: (list) => list,
        loading: () => <Customer>[],
        error: (_, __) => <Customer>[],
      );

      final totalSales = transactionList
          .where((t) => t.type == TransactionType.credit && t.status == TransactionStatus.paid)
          .fold(0.0, (sum, t) => sum + t.amount);

      final totalOutstanding = transactionList
          .where((t) => t.status == TransactionStatus.outstanding)
          .fold(0.0, (sum, t) => sum + t.amount);

      final todayTransactions = transactionList.where((t) {
        final today = DateTime.now();
        return t.createdAt.year == today.year &&
               t.createdAt.month == today.month &&
               t.createdAt.day == today.day;
      }).toList();

      final todaySales = todayTransactions
          .where((t) => t.type == TransactionType.credit && t.status == TransactionStatus.paid)
          .fold(0.0, (sum, t) => sum + t.amount);

      return DashboardSummary(
        totalCustomers: customerList.length,
        totalSales: totalSales,
        totalOutstanding: totalOutstanding,
        todaySales: todaySales,
        todayTransactions: todayTransactions.length,
        recentTransactions: transactionList.take(5).toList(),
      );
    },
    loading: () => const DashboardSummary(),
    error: (_, __) => const DashboardSummary(),
  );
});

/// Quick actions provider
final quickActionsProvider = Provider<List<QuickAction>>((ref) {
  return [
    QuickAction(
      title: 'Add Sale',
      icon: 'add_circle',
      color: 0xFF4CAF50,
      action: QuickActionType.addSale,
    ),
    QuickAction(
      title: 'Collect Payment',
      icon: 'payment',
      color: 0xFF2196F3,
      action: QuickActionType.collectPayment,
    ),
    QuickAction(
      title: 'Add Customer',
      icon: 'person_add',
      color: 0xFF9C27B0,
      action: QuickActionType.addCustomer,
    ),
    QuickAction(
      title: 'Send Reminder',
      icon: 'notifications',
      color: 0xFFFF9800,
      action: QuickActionType.sendReminder,
    ),
    QuickAction(
      title: 'View Reports',
      icon: 'bar_chart',
      color: 0xFF607D8B,
      action: QuickActionType.viewReports,
    ),
    QuickAction(
      title: 'Scan QR',
      icon: 'qr_code_scanner',
      color: 0xFF795548,
      action: QuickActionType.scanQr,
    ),
  ];
});

/// Home screen state provider
final homeScreenStateProvider = StateNotifierProvider<HomeScreenNotifier, HomeScreenState>((ref) {
  return HomeScreenNotifier();
});

/// Dashboard summary model
class DashboardSummary {
  final int totalCustomers;
  final double totalSales;
  final double totalOutstanding;
  final double todaySales;
  final int todayTransactions;
  final List<Transaction> recentTransactions;

  const DashboardSummary({
    this.totalCustomers = 0,
    this.totalSales = 0.0,
    this.totalOutstanding = 0.0,
    this.todaySales = 0.0,
    this.todayTransactions = 0,
    this.recentTransactions = const [],
  });
}

/// Quick action model
class QuickAction {
  final String title;
  final String icon;
  final int color;
  final QuickActionType action;

  const QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.action,
  });
}

/// Quick action types
enum QuickActionType {
  addSale,
  collectPayment,
  addCustomer,
  sendReminder,
  viewReports,
  scanQr,
}

/// Home screen state
class HomeScreenState {
  final bool isRefreshing;
  final DateTime? lastRefresh;
  final String? errorMessage;

  const HomeScreenState({
    this.isRefreshing = false,
    this.lastRefresh,
    this.errorMessage,
  });

  HomeScreenState copyWith({
    bool? isRefreshing,
    DateTime? lastRefresh,
    String? errorMessage,
  }) {
    return HomeScreenState(
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastRefresh: lastRefresh ?? this.lastRefresh,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Home screen notifier
class HomeScreenNotifier extends StateNotifier<HomeScreenState> {
  HomeScreenNotifier() : super(const HomeScreenState());

  Future<void> refreshData() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    
    try {
      // Simulate refresh delay
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(
        isRefreshing: false,
        lastRefresh: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: 'Failed to refresh data',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
