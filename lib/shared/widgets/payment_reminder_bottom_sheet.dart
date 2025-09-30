import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import 'app_button.dart';

class PaymentReminderBottomSheet extends StatelessWidget {
  final dynamic transaction;
  final VoidCallback onUpiPayment;
  final VoidCallback onShareLink;

  const PaymentReminderBottomSheet({
    super.key,
    required this.transaction,
    required this.onUpiPayment,
    required this.onShareLink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingBase),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusDefault),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            'Send Payment Reminder',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Amount
          Text(
            '₹${(transaction.amount / 100).toStringAsFixed(0)}',
            style: AppTextStyles.h1.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          
          // Note
          if (transaction.note != null)
            Text(
              transaction.note!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          
          const SizedBox(height: 32),
          
          // Payment options
          Row(
            children: [
              Expanded(
                child: _buildPaymentOption(
                  icon: Icons.payment_outlined,
                  title: 'UPI Payment',
                  subtitle: 'Open UPI app',
                  color: AppColors.primaryBlue,
                  onTap: () {
                    Navigator.pop(context);
                    onUpiPayment();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPaymentOption(
                  icon: Icons.share_outlined,
                  title: 'Share Link',
                  subtitle: 'Send via WhatsApp',
                  color: AppColors.accentGreen,
                  onTap: () {
                    Navigator.pop(context);
                    onShareLink();
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Cancel button
          AppButton.secondary(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
            isFullWidth: true,
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
