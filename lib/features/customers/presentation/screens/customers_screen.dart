import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_input_field.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/responsive_builder.dart';
import '../../../shared/models/customer_model.dart' as models;
import '../providers/customer_providers.dart';
import '../../auth/providers/auth_providers.dart';
import 'customer_ledger_screen_minimal.dart';

/// Customers list screen
class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  models.Customer? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCustomers() {
    final user = ref.read(currentUserProvider);
    // Customers are automatically loaded via provider
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    ref.read(customerSearchProvider.notifier).state = query;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text(context.l10n.customers),
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: ResponsiveBuilder(
        mobile: (context, constraints) => _buildMobileLayout(),
        tablet: (context, constraints) => _buildTabletLayout(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.person_add, color: AppColors.white),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingBase),
          child: AppInputField(
            controller: _searchController,
            hintText: context.l10n.searchCustomers,
            prefixIcon: Icons.search,
            suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
            onSuffixIconPressed: () {
              _searchController.clear();
              _onSearchChanged();
            },
          ),
        ),
        Expanded(
          child: _buildCustomersList(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingBase),
                child: AppInputField(
                  controller: _searchController,
                  hintText: context.l10n.searchCustomers,
                  prefixIcon: Icons.search,
                  suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
                  onSuffixIconPressed: () {
                    _searchController.clear();
                    _onSearchChanged();
                  },
                ),
              ),
              Expanded(
                child: _buildCustomersList(),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: _buildCustomerDetails(),
        ),
      ],
    );
  }

  Widget _buildCustomersList() {
    return Consumer(
      builder: (context, ref, child) {
        final customerState = ref.watch(filteredCustomersProvider);
        
        if (customerState.isEmpty) {
          return _buildEmptyState();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingBase),
          itemCount: customerState.length,
          itemBuilder: (context, index) {
            final customer = customerState[index];
            return _buildCustomerCard(customer);
          },
        );
      },
    );
  }

  Widget _buildCustomerCard(models.Customer customer) {
    final outstandingAmount = ref.watch(customerOutstandingProvider(customer.id));
    final hasOutstanding = outstandingAmount > 0;
    final statusColor = hasOutstanding ? AppColors.dangerRed : AppColors.accentGreen;
    final statusText = hasOutstanding ? 'Outstanding' : 'Paid';

    return AppCard(
      onTap: () {
        setState(() {
          _selectedCustomer = customer;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerLedgerScreen(customer: customer),
          ),
        );
      },
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            child: Text(
              customer.name.substring(0, 1).toUpperCase(),
              style: AppTextStyles.h3.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Customer Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  customer.phoneNumber,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(customer.updatedAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          
          // Outstanding Amount & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasOutstanding)
                Text(
                  '₹${outstandingAmountRupees.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 4),
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
          
          // Arrow
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: AppColors.textMuted,
            size: AppDimensions.iconMedium,
          ),
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
            Icons.people_outline,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? context.l10n.noCustomersFound
                : context.l10n.noCustomersYet,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (_searchController.text.isEmpty)
            Text(
              context.l10n.addYourFirstCustomer,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingBase),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a customer to view details',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
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

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddCustomerDialog(
        onCustomerAdded: () {
          _loadCustomers();
        },
      ),
    );
  }
}

class _AddCustomerDialog extends ConsumerStatefulWidget {
  final VoidCallback onCustomerAdded;

  const _AddCustomerDialog({required this.onCustomerAdded});

  @override
  ConsumerState<_AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends ConsumerState<_AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Customer'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppInputField(
              controller: _nameController,
              hint: 'Customer Name',
              prefixIcon: const Icon(Icons.person_outline),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _phoneController,
              hint: 'Phone Number',
              prefixIcon: const Icon(Icons.phone_outlined),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                if (value.length < 10) {
                  return 'Please enter valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _emailController,
              hint: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _addressController,
              hint: 'Address',
              prefixIcon: const Icon(Icons.location_on_outlined),
              maxLines: 3,
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
          onPressed: _isLoading ? null : _addCustomer,
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

  Future<void> _addCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // For now, just show success message
      // In a real app, this would save to Firebase
      
      if (mounted) {
        Navigator.pop(context);
        widget.onCustomerAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding customer: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
