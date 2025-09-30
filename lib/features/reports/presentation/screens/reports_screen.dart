import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/responsive_builder.dart';
import '../../../transactions/providers/transaction_providers.dart';
import '../../../customers/providers/customer_providers.dart';

/// Reports screen showing business analytics and insights
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.reports),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: [
            Tab(text: context.l10n.overview),
            Tab(text: context.l10n.transactions),
            Tab(text: context.l10n.customers),
          ],
        ),
      ),
      body: ResponsiveBuilder(
        mobile: (context, constraints) => _buildMobileLayout(),
        tablet: (context, constraints) => _buildTabletLayout(),
        desktop: (context, constraints) => _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildTransactionsTab(),
        _buildCustomersTab(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return _buildMobileLayout(); // Same as mobile for now
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar navigation
        Container(
          width: 200,
          color: AppColors.white,
          child: Column(
            children: [
              _buildNavItem('Overview', 0),
              _buildNavItem('Transactions', 1),
              _buildNavItem('Customers', 2),
            ],
          ),
        ),
        // Content area
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildTransactionsTab(),
              _buildCustomersTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(String title, int index) {
    final isSelected = _tabController.index == index;
    return ListTile(
      title: Text(title),
      selected: isSelected,
      onTap: () => _tabController.animateTo(index),
      selectedTileColor: AppColors.primaryBlue.withOpacity(0.1),
    );
  }

  Widget _buildOverviewTab() {
    final transactions = ref.watch(transactionsProvider);
    final customers = ref.watch(customersProvider);

    return transactions.when(
      data: (transactionList) {
        final customerList = customers.when(
          data: (list) => list,
          loading: () => [],
          error: (_, __) => [],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(transactionList, customerList),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildChartSection(),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildTopCustomers(customerList, transactionList),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading data: $error'),
      ),
    );
  }

  Widget _buildSummaryCards(transactions, customers) {
    final totalSales = transactions
        .where((t) => t.status.name == 'paid')
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalOutstanding = transactions
        .where((t) => t.status.name == 'outstanding')
        .fold(0.0, (sum, t) => sum + t.amount);

    final thisMonth = DateTime.now();
    final monthlyTransactions = transactions.where((t) =>
        t.createdAt.year == thisMonth.year &&
        t.createdAt.month == thisMonth.month).toList();

    final monthlySales = monthlyTransactions
        .where((t) => t.status.name == 'paid')
        .fold(0.0, (sum, t) => sum + t.amount);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveBuilderHelper.of(context).isMobile ? 2 : 4,
      childAspectRatio: 1.5,
      mainAxisSpacing: AppDimensions.spacingMedium,
      crossAxisSpacing: AppDimensions.spacingMedium,
      children: [
        _buildSummaryCard(
          'Total Sales',
          '₹${totalSales.toStringAsFixed(0)}',
          Icons.trending_up,
          AppColors.accentGreen,
        ),
        _buildSummaryCard(
          'Outstanding',
          '₹${totalOutstanding.toStringAsFixed(0)}',
          Icons.pending_actions,
          AppColors.dangerRed,
        ),
        _buildSummaryCard(
          'This Month',
          '₹${monthlySales.toStringAsFixed(0)}',
          Icons.calendar_month,
          AppColors.primaryBlue,
        ),
        _buildSummaryCard(
          'Customers',
          customers.length.toString(),
          Icons.people,
          AppColors.accentPurple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: color),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Trend',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Container(
            height: 200,
            child: const Center(
              child: Text(
                'Chart will be implemented with fl_chart package',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomers(customers, transactions) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Customers',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: customers.take(5).length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final customer = customers[index];
              final customerTransactions = transactions
                  .where((t) => t.customerId == customer.id)
                  .toList();
              final totalAmount = customerTransactions
                  .fold(0.0, (sum, t) => sum + t.amount);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue,
                  child: Text(
                    customer.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(customer.name),
                subtitle: Text('${customerTransactions.length} transactions'),
                trailing: Text(
                  '₹${totalAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return const Center(
      child: Text('Transaction Reports - Coming Soon'),
    );
  }

  Widget _buildCustomersTab() {
    return const Center(
      child: Text('Customer Reports - Coming Soon'),
    );
  }
}
