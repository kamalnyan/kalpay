import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input_field.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/lottie_animation.dart';
import '../../../../shared/models/customer_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../transactions/providers/transaction_provider.dart';
import '../../providers/customer_provider.dart';

class CustomerLedgerScreen extends ConsumerStatefulWidget {
  final CustomerModel customer;

  const CustomerLedgerScreen({
    super.key,
    required this.customer,
  });

  @override
  ConsumerState<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends ConsumerState<CustomerLedgerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  void _loadTransactions() {
    ref.read(transactionNotifierProvider.notifier)
        .fetchTransactionsByCustomer(widget.customer.customerId);
  }

  @override
  Widget build(BuildContext context) {
    final outstandingAmount = widget.customer.outstandingAmount / 100;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text(widget.customer.name),
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showCustomerOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCustomerSummary(outstandingAmount),
          _buildQuickActions(),
          Expanded(
            child: _buildTransactionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSummary(double outstandingAmount) {
    final hasOutstanding = outstandingAmount > 0;
    final statusColor = hasOutstanding ? AppColors.dangerRed : AppColors.accentGreen;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingBase),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Customer Avatar and Info
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.white.withOpacity(0.2),
                child: Text(
                  widget.customer.name.substring(0, 1).toUpperCase(),
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.customer.name,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.customer.phoneNumber,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Outstanding Amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusBase),
              border: Border.all(
                color: AppColors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  hasOutstanding ? 'Outstanding Amount' : 'All Cleared',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasOutstanding ? '₹${outstandingAmount.toStringAsFixed(0)}' : '₹0',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasOutstanding) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'PENDING',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingBase),
      child: Row(
        children: [
          Expanded(
            child: AppButton.primary(
              text: 'Add Transaction',
              icon: Icons.add,
              onPressed: _showAddTransactionDialog,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton.secondary(
              text: 'Send Reminder',
              icon: Icons.notifications_outlined,
              onPressed: widget.customer.outstandingAmount > 0 
                  ? _sendPaymentReminder 
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Consumer(
      builder: (context, ref, child) {
        final transactionState = ref.watch(transactionsByCustomerProvider(widget.customer.customerId));
        
        return transactionState.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return _buildEmptyState();
            }
            
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingBase),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionCard(transaction);
              },
            );
          },
          loading: () => const AppLoading(),
          error: (error, stackTrace) => Center(
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
                  'Error loading transactions',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                AppButton.secondary(
                  text: 'Retry',
                  onPressed: _loadTransactions,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isCredit = transaction.type == TransactionType.credit;
    final isPaid = transaction.status == TransactionStatus.paid;
    final amount = transaction.amount / 100;
    
    final statusColor = isPaid 
        ? AppColors.accentGreen 
        : (isCredit ? AppColors.dangerRed : AppColors.primaryBlue);
    
    final statusText = isPaid ? 'Paid' : 'Pending';
    final typeText = isCredit ? 'Credit' : 'Debit';

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Transaction Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
                ),
                child: Icon(
                  isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          typeText,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '₹${amount.toStringAsFixed(0)}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (transaction.note != null)
                      Text(
                        transaction.note!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatDate(transaction.createdAt),
                          style: AppTextStyles.caption,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
                          ),
                          child: Text(
                            statusText,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Action buttons for pending transactions
          if (!isPaid && isCredit) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    text: 'Mark Paid',
                    onPressed: () => _markTransactionPaid(transaction),
                    isSmall: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton.secondary(
                    text: 'Send Reminder',
                    onPressed: () => _sendTransactionReminder(transaction),
                    isSmall: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first transaction with this customer',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          AppButton.primary(
            text: 'Add Transaction',
            icon: Icons.add,
            onPressed: _showAddTransactionDialog,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddTransactionDialog(
        customer: widget.customer,
        onTransactionAdded: () {
          _loadTransactions();
          // Refresh customer data to update outstanding amount
          ref.read(customerNotifierProvider.notifier)
              .fetchCustomers(widget.customer.shopId);
        },
      ),
    );
  }

  void _showCustomerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingBase),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Customer'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit customer screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.dangerRed),
              title: const Text('Delete Customer', style: TextStyle(color: AppColors.dangerRed)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${widget.customer.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(customerNotifierProvider.notifier)
                    .deleteCustomer(widget.customer.customerId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Customer deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting customer: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _markTransactionPaid(TransactionModel transaction) async {
    try {
      await ref.read(transactionNotifierProvider.notifier)
          .markTransactionPaid(transaction.transactionId);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment marked as received!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }
      
      // Refresh data
      _loadTransactions();
      ref.read(customerNotifierProvider.notifier)
          .fetchCustomers(widget.customer.shopId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking transaction as paid: $e')),
        );
      }
    }
  }

  void _sendPaymentReminder() {
    // TODO: Implement payment reminder for customer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment reminder sent!')),
    );
  }

  void _sendTransactionReminder(TransactionModel transaction) {
    // TODO: Implement transaction-specific reminder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction reminder sent!')),
    );
  }
}

class _AddTransactionDialog extends ConsumerStatefulWidget {
  final CustomerModel customer;
  final VoidCallback onTransactionAdded;

  const _AddTransactionDialog({
    required this.customer,
    required this.onTransactionAdded,
  });

  @override
  ConsumerState<_AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<_AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _selectedType = TransactionType.credit;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Transaction'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Transaction Type
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: const Text('Credit'),
                    subtitle: const Text('Customer owes you'),
                    value: TransactionType.credit,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() => _selectedType = value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: const Text('Debit'),
                    subtitle: const Text('You owe customer'),
                    value: TransactionType.debit,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() => _selectedType = value!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Amount
            AppInputField(
              controller: _amountController,
              hintText: 'Amount (₹)',
              prefixIcon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Note
            AppInputField(
              controller: _noteController,
              hintText: 'Note (optional)',
              prefixIcon: Icons.note_outlined,
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addTransaction,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _addTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text.trim());
      final amountInPaise = (amount * 100).round();
      
      final transaction = TransactionModel.create(
        shopId: widget.customer.shopId,
        customerId: widget.customer.customerId,
        amount: amountInPaise,
        type: _selectedType.name,
        method: PaymentMethod.cash.name,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
      
      if (mounted) {
        Navigator.pop(context);
        widget.onTransactionAdded();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction added successfully!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding transaction: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
