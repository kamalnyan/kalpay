import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/responsive_builder.dart';
import '../../../../shared/widgets/lottie_animation.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../customers/providers/customer_providers.dart';
import '../../../transactions/providers/transaction_provider.dart';
import '../../../../core/services/upi_service.dart';
import '../../../../shared/widgets/payment_reminder_bottom_sheet.dart';

/// Home dashboard screen for merchants
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Set initial status bar style
    _updateStatusBar();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 0;
    if (_isScrolled != isScrolled) {
      setState(() => _isScrolled = isScrolled);
      _updateStatusBar();
    }
  }

  void _updateStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isScrolled ? Brightness.dark : Brightness.light,
        statusBarBrightness: _isScrolled ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          // User not authenticated, redirect to onboarding
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/onboarding');
          });
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadingAnimation(),
                  const SizedBox(height: 16),
                  Text(
                    'Redirecting...',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }
        
        return _buildAuthenticatedHome(user);
      },
      loading: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LoadingAnimation(),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.dangerRed,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading user data',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppButton.primary(
                text: 'Retry',
                onPressed: () => ref.invalidate(authStateProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedHome(User user) {
    final shopId = user.uid;
    final customersAsync = ref.watch(customersProvider);
    final recentTransactionsAsync = ref.watch(recentTransactionsProvider(shopId));
    final outstandingTransactionsAsync = ref.watch(outstandingTransactionsProvider(shopId));

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: _buildAppBar(),
      body: ResponsiveBuilder(
        mobile: (context, constraints) => _buildMobileLayout(
          customersAsync,
          recentTransactionsAsync,
          outstandingTransactionsAsync,
        ),
        tablet: (context, constraints) => _buildTabletLayout(
          customersAsync,
          recentTransactionsAsync,
          outstandingTransactionsAsync,
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: _isScrolled ? 2 : 0,
      backgroundColor: _isScrolled ? AppColors.white : AppColors.primaryBlue,
      foregroundColor: _isScrolled ? AppColors.textPrimary : AppColors.white,
      title: Row(
        children: [
          Image.asset(
            _isScrolled?'assets/icons/logo_big_trans.png':'assets/icons/blue_logo_trans.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.account_balance_wallet,
                size: 24,
              );
            },
          ),
          const SizedBox(width: 12),
          Text(
            context.l10n.appTitle,
            style: AppTextStyles.h3.copyWith(
              color: _isScrolled ? AppColors.textPrimary : AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Navigate to notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // Navigate to settings
          },
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    AsyncValue customersAsync,
    AsyncValue recentTransactionsAsync,
    AsyncValue outstandingTransactionsAsync,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: _buildSummarySection(customersAsync, outstandingTransactionsAsync),
        ),
        SliverToBoxAdapter(child: _buildQuickActions()),
        SliverToBoxAdapter(
          child: _buildRecentTransactions(recentTransactionsAsync),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    AsyncValue customersAsync,
    AsyncValue recentTransactionsAsync,
    AsyncValue outstandingTransactionsAsync,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingBase),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildSummarySection(customersAsync, outstandingTransactionsAsync),
                      _buildQuickActions(),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingBase),
                Expanded(
                  flex: 3,
                  child: _buildRecentTransactions(recentTransactionsAsync),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(
    AsyncValue customersAsync,
    AsyncValue outstandingTransactionsAsync,
  ) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingBase),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.dashboard,
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 16),
          customersAsync.when(
            data: (customers) => outstandingTransactionsAsync.when(
              data: (outstandingTransactions) {
                final totalOutstanding = outstandingTransactions
                    .fold<int>(0, (sum, tx) => sum + tx.amount);
                final dueToday = outstandingTransactions
                    .where((tx) => tx.dueDate != null && 
                        _isToday(tx.dueDate!))
                    .fold<int>(0, (sum, tx) => sum + tx.amount);
                
                return ResponsiveBuilder(
                  mobile: (context, constraints) => Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              title: context.l10n.outstanding,
                              amount: '₹${(totalOutstanding / 100).toStringAsFixed(0)}',
                              amountColor: AppColors.dangerRed,
                              icon: Icons.schedule_outlined,
                              iconColor: AppColors.dangerRed,
                              onTap: () => Navigator.pushNamed(context, '/outstanding'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SummaryCard(
                              title: context.l10n.dueToday,
                              amount: '₹${(dueToday / 100).toStringAsFixed(0)}',
                              amountColor: AppColors.warning,
                              icon: Icons.today_outlined,
                              iconColor: AppColors.warning,
                              onTap: () => Navigator.pushNamed(context, '/due-today'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SummaryCard(
                        title: 'Total Customers',
                        amount: '${customers.length}',
                        amountColor: AppColors.accentGreen,
                        icon: Icons.people_outlined,
                        iconColor: AppColors.accentGreen,
                        onTap: () => Navigator.pushNamed(context, '/customers'),
                      ),
                    ],
                  ),
                  tablet: (context, constraints) => Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: context.l10n.outstanding,
                          amount: '₹${(totalOutstanding / 100).toStringAsFixed(0)}',
                          amountColor: AppColors.dangerRed,
                          icon: Icons.schedule_outlined,
                          iconColor: AppColors.dangerRed,
                          onTap: () => Navigator.pushNamed(context, '/outstanding'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SummaryCard(
                          title: context.l10n.dueToday,
                          amount: '₹${(dueToday / 100).toStringAsFixed(0)}',
                          amountColor: AppColors.warning,
                          icon: Icons.today_outlined,
                          iconColor: AppColors.warning,
                          onTap: () => Navigator.pushNamed(context, '/due-today'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SummaryCard(
                          title: 'Total Customers',
                          amount: '${customers.length}',
                          amountColor: AppColors.accentGreen,
                          icon: Icons.people_outlined,
                          iconColor: AppColors.accentGreen,
                          onTap: () => Navigator.pushNamed(context, '/customers'),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: LoadingAnimation()),
              error: (error, stack) => Center(
                child: Text('Error loading data: $error'),
              ),
            ),
            loading: () => const Center(child: LoadingAnimation()),
            error: (error, stack) => Center(
              child: Text('Error loading customers: $error'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingBase),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 16),
          ResponsiveBuilder(
            mobile: (context, constraints) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        title: context.l10n.addSale,
                        icon: Icons.add_shopping_cart_outlined,
                        color: AppColors.primaryBlue,
                        onTap: () => _showAddSaleBottomSheet(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionCard(
                        title: context.l10n.scanQr,
                        icon: Icons.qr_code_scanner_outlined,
                        color: AppColors.accentGreen,
                        onTap: () => Navigator.pushNamed(context, '/qr-scanner'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        title: context.l10n.requestPayment,
                        icon: Icons.payment_outlined,
                        color: AppColors.warning,
                        onTap: () => Navigator.pushNamed(context, '/request-payment'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionCard(
                        title: context.l10n.addCustomer,
                        icon: Icons.person_add_outlined,
                        color: AppColors.info,
                        onTap: () => Navigator.pushNamed(context, '/add-customer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            tablet: (context, constraints) => Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: context.l10n.addSale,
                    icon: Icons.add_shopping_cart_outlined,
                    color: AppColors.primaryBlue,
                    onTap: () => _showAddSaleBottomSheet(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionCard(
                    title: context.l10n.scanQr,
                    icon: Icons.qr_code_scanner_outlined,
                    color: AppColors.accentGreen,
                    onTap: () => Navigator.pushNamed(context, '/qr-scanner'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionCard(
                    title: context.l10n.requestPayment,
                    icon: Icons.payment_outlined,
                    color: AppColors.warning,
                    onTap: () => Navigator.pushNamed(context, '/request-payment'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionCard(
                    title: context.l10n.addCustomer,
                    icon: Icons.person_add_outlined,
                    color: AppColors.info,
                    onTap: () => Navigator.pushNamed(context, '/add-customer'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppDimensions.iconLarge,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(AsyncValue recentTransactionsAsync) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingBase),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.recentTransactions,
                style: AppTextStyles.h3,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/transactions'),
                child: Text(
                  'View All',
                  style: AppTextStyles.link,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          recentTransactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions yet',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first sale to get started',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return TransactionCard(
                    customerName: 'Customer', // We'll need to fetch customer name
                    amount: '₹${(transaction.amount / 100).toStringAsFixed(0)}',
                    note: transaction.note ?? 'No description',
                    date: _formatDate(transaction.createdAt),
                    status: transaction.status == 'paid' ? 'Paid' : 'Pending',
                    statusColor: transaction.status == 'paid' 
                        ? AppColors.accentGreen 
                        : AppColors.warning,
                    onTap: () => Navigator.pushNamed(context, '/transaction-details'),
                    onMarkPaid: transaction.status != 'paid' 
                        ? () => _markTransactionAsPaid(transaction) 
                        : null,
                    onRemind: transaction.status != 'paid' 
                        ? () => _sendPaymentReminder(transaction) 
                        : null,
                  );
                },
              );
            },
            loading: () => const Center(child: LoadingAnimation()),
            error: (error, stack) => Center(
              child: Text('Error loading transactions: $error'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _showQuickActions,
      child: const Icon(Icons.add),
    );
  }

  void _showQuickActions() {
    QuickActionBottomSheet.show(
      context: context,
      actions: [
        QuickAction(
          title: context.l10n.addSale,
          subtitle: 'Add a new sale transaction',
          icon: Icons.add_shopping_cart_outlined,
          color: AppColors.primaryBlue,
          onTap: () => _showAddSaleBottomSheet(),
        ),
        QuickAction(
          title: context.l10n.scanQr,
          subtitle: 'Scan customer QR code',
          icon: Icons.qr_code_scanner_outlined,
          color: AppColors.accentGreen,
          onTap: () => Navigator.pushNamed(context, '/qr-scanner'),
        ),
        QuickAction(
          title: context.l10n.requestPayment,
          subtitle: 'Send payment request',
          icon: Icons.payment_outlined,
          color: AppColors.warning,
          onTap: () => Navigator.pushNamed(context, '/request-payment'),
        ),
        QuickAction(
          title: context.l10n.addCustomer,
          subtitle: 'Add new customer',
          icon: Icons.person_add_outlined,
          color: AppColors.info,
          onTap: () => Navigator.pushNamed(context, '/add-customer'),
        ),
      ],
    );
  }

  void _showAddSaleBottomSheet() {
    AppBottomSheet.show(
      context: context,
      title: context.l10n.addSale,
      child: const AddSaleForm(),
    );
  }

  // Helper methods
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _markTransactionAsPaid(dynamic transaction) async {
    final result = await ref.read(transactionStateProvider.notifier).markTransactionAsPaid(
      shopId: FirebaseAuth.instance.currentUser!.uid,
      customerId: transaction.customerId,
      transactionId: transaction.transactionId,
      paymentMethod: 'cash',
    );

    if (result) {
      AnimationDialog.showSuccess(
        context,
        title: 'Payment Recorded!',
        message: 'Transaction marked as paid successfully',
      );
    } else {
      AnimationDialog.showFailed(
        context,
        title: 'Failed!',
        message: 'Failed to mark transaction as paid',
      );
    }
  }

  Future<void> _sendPaymentReminder(dynamic transaction) async {
    // Show UPI payment options
    showModalBottomSheet(
      context: context,
      builder: (context) => PaymentReminderBottomSheet(
        transaction: transaction,
        onUpiPayment: () => _launchUpiPayment(transaction),
        onShareLink: () => _sharePaymentLink(transaction),
      ),
    );
  }

  Future<void> _launchUpiPayment(dynamic transaction) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    
    final userProfile = await ref.read(userProfileProvider(currentUser.uid).future);
    
    if (userProfile != null && userProfile.upiId != null) {
      final result = await UpiService.launchUpiPayment(
        upiId: userProfile.upiId!,
        merchantName: userProfile.shopName ?? 'Shop',
        amount: transaction.amount / 100.0,
        transactionNote: transaction.note ?? 'Payment',
        transactionRef: transaction.transactionId,
      );

      if (result['status'] == 'launched') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('UPI app launched. Please complete the payment.'),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add UPI ID in settings to use UPI payments'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  Future<void> _sharePaymentLink(dynamic transaction) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    
    final userProfile = await ref.read(userProfileProvider(currentUser.uid).future);
    
    if (userProfile != null && userProfile.upiId != null) {
      final paymentLink = UpiService.generateUpiUrl(
        upiId: userProfile.upiId!,
        merchantName: userProfile.shopName ?? 'Shop',
        amount: transaction.amount / 100.0,
        transactionNote: transaction.note ?? 'Payment',
        transactionRef: transaction.transactionId,
      );

      // Use share_plus package to share the link
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment link copied to clipboard'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    }
  }
}

/// Add sale form widget
class AddSaleForm extends StatefulWidget {
  const AddSaleForm({super.key});

  @override
  State<AddSaleForm> createState() => _AddSaleFormState();
}

class _AddSaleFormState extends State<AddSaleForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCustomer;
  bool _payNow = true;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingBase),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCustomer,
              decoration: const InputDecoration(
                labelText: 'Select Customer',
                prefixIcon: Icon(Icons.person_outlined),
              ),
              items: ['Customer 1', 'Customer 2', 'Customer 3']
                  .map((customer) => DropdownMenuItem(
                        value: customer,
                        child: Text(customer),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCustomer = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                prefixIcon: Icon(Icons.currency_rupee_outlined),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Amount is required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                prefixIcon: Icon(Icons.note_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(context.l10n.payNow),
                    value: true,
                    groupValue: _payNow,
                    onChanged: (value) => setState(() => _payNow = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(context.l10n.payLater),
                    value: false,
                    groupValue: _payNow,
                    onChanged: (value) => setState(() => _payNow = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              text: context.l10n.save,
              onPressed: _saveSale,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  void _saveSale() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sale added successfully'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    }
  }
}
