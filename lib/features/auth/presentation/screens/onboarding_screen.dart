import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input_field.dart';
import '../../../../shared/widgets/responsive_builder.dart';
import '../../../../shared/widgets/lottie_animation.dart';
import '../../providers/auth_provider.dart';

/// Onboarding screen with Firebase authentication
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();
  
  int _currentPage = 0;
  String _selectedRole = 'shopkeeper';

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _shopNameController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    // Listen to auth state changes
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.dangerRed,
          ),
        );
        ref.read(authStateProvider.notifier).clearError();
      }
      
      // Navigate based on auth step
      switch (next.step) {
        case AuthStep.otpVerification:
          if (_currentPage != 2) _goToPage(2);
          break;
        case AuthStep.profileSetup:
          if (_currentPage != 3) _goToPage(3);
          break;
        case AuthStep.completed:
          Navigator.of(context).pushReplacementNamed('/home');
          break;
        default:
          break;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            
            // Main content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildRoleSelectionPage(),
                  _buildPhoneInputPage(authState),
                  _buildOtpVerificationPage(authState),
                  _buildProfileSetupPage(authState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingBase),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentPage;
          final isCompleted = index < _currentPage;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: isCompleted 
                    ? AppColors.accentGreen 
                    : isActive 
                        ? AppColors.primaryBlue 
                        : AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRoleSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingBase),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          
          // Header
          Container(
            width: 80,
            height: 80,
            child: Image.asset("assets/icons/logo_big_trans.png", fit: BoxFit.cover),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to KalPay',
            style: AppTextStyles.h1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Smart PayLater Ledger for Shops',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          // Role selection
          Text(
            'I am a...',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildRoleOption(
            title: 'Shopkeeper',
            subtitle: 'Manage customer ledger and payments',
            icon: Icons.storefront_outlined,
            value: 'shopkeeper',
          ),
          const SizedBox(height: 16),
          _buildRoleOption(
            title: 'Customer',
            subtitle: 'View and pay your bills',
            icon: Icons.person_outlined,
            value: 'customer',
          ),
          
          const Spacer(),
          
          AppButton.primary(
            text: 'Continue',
            onPressed: () => _goToPage(1),
            isFullWidth: true,
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedRole == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryBlue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInputPage(AuthState authState) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingBase),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          
          Icon(
            Icons.phone_outlined,
            size: 64,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 24),
          
          Text(
            'Enter your phone number',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll send you a verification code',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          AppInputField(
            controller: _phoneController,
            hint: 'Enter 10-digit mobile number',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          
          const Spacer(),
          
          AppButton.primary(
            text: authState.isLoading ? 'Sending...' : 'Send OTP',
            onPressed: authState.isLoading ? null : _sendOtp,
            isFullWidth: true,
            isLoading: authState.isLoading,
          ),
          
          const SizedBox(height: 24),
          _buildTermsText(),
        ],
      ),
    );
  }

  Widget _buildOtpVerificationPage(AuthState authState) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingBase),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          
          Icon(
            Icons.security_outlined,
            size: 64,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 24),
          
          Text(
            'Verify your phone',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 6-digit code sent to\n+91 ${_phoneController.text}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          AppInputField(
            controller: _otpController,
            hint: 'Enter 6-digit OTP',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.lock_outlined),
            maxLength: 6,
          ),
          
          const SizedBox(height: 16),
          
          TextButton(
            onPressed: authState.isLoading ? null : _sendOtp,
            child: Text(
              'Resend OTP',
              style: AppTextStyles.link,
            ),
          ),
          
          const Spacer(),
          
          AppButton.primary(
            text: authState.isLoading ? 'Verifying...' : 'Verify OTP',
            onPressed: authState.isLoading ? null : _verifyOtp,
            isFullWidth: true,
            isLoading: authState.isLoading,
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileSetupPage(AuthState authState) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingBase),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          
          Icon(
            _selectedRole == 'shopkeeper' ? Icons.storefront_outlined : Icons.person_outlined,
            size: 64,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 24),
          
          Text(
            _selectedRole == 'shopkeeper' ? 'Setup your shop' : 'Complete your profile',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _selectedRole == 'shopkeeper' 
                ? 'Add your shop details to get started'
                : 'Just a few more details',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          if (_selectedRole == 'shopkeeper') ...[
            AppInputField(
              controller: _shopNameController,
              hint: 'Enter your shop name',
              prefixIcon: const Icon(Icons.store_outlined),
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _upiIdController,
              hint: 'yourname@paytm',
              prefixIcon: const Icon(Icons.payment_outlined),
            ),
          ],
          
          const Spacer(),
          
          AppButton.primary(
            text: authState.isLoading ? 'Creating Profile...' : 'Complete Setup',
            onPressed: authState.isLoading ? null : _createProfile,
            isFullWidth: true,
            isLoading: authState.isLoading,
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTermsText() {
    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _sendOtp() {
    if (_phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit phone number'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    final phoneNumber = '+91${_phoneController.text}';
    ref.read(authStateProvider.notifier).sendOTP(phoneNumber);
  }

  void _verifyOtp() {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit OTP'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    ref.read(authStateProvider.notifier).verifyOTP(_otpController.text);
  }

  void _createProfile() {
    if (_selectedRole == 'shopkeeper' && _shopNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your shop name'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    ref.read(authStateProvider.notifier).createProfile(
      role: _selectedRole,
      shopName: _selectedRole == 'shopkeeper' ? _shopNameController.text : null,
      upiId: _selectedRole == 'shopkeeper' && _upiIdController.text.isNotEmpty 
          ? _upiIdController.text 
          : null,
    );
  }
}
