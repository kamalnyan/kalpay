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

/// Onboarding screen for role selection and phone authentication
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
    _otpController.addListener(_onOtpChanged);
  }

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
      
      if (next.step == AuthStep.otpVerification && _currentPage != 2) {
        _goToPage(2);
      }
      
      if (next.step == AuthStep.profileSetup && _currentPage != 3) {
        _goToPage(3);
      }
      
      if (next.step == AuthStep.completed) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: ResponsiveBuilder(
        mobile: (context, constraints) => _buildMobileLayout(authState),
        tablet: (context, constraints) => _buildTabletLayout(authState),
      ),
    );
  }

  Widget _buildMobileLayout(AuthState authState) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingBase),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            _buildHeader(),
            const SizedBox(height: 48),
            if (!_isOtpSent) ...[
              _buildRoleSelection(),
              const SizedBox(height: 32),
              _buildPhoneInput(),
            ] else ...[
              _buildOtpInput(),
            ],
            const SizedBox(height: 32),
            _buildActionButton(),
            const SizedBox(height: 24),
            _buildTermsText(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SafeArea(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 48),
                if (!_isOtpSent) ...[
                  _buildRoleSelection(),
                  const SizedBox(height: 32),
                  _buildPhoneInput(),
                ] else ...[
                  _buildOtpInput(),
                ],
                const SizedBox(height: 32),
                _buildActionButton(),
                const SizedBox(height: 24),
                _buildTermsText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          child: Image.asset("assets/icons/logo_big_trans.png",fit: BoxFit.cover)
        ),
        const SizedBox(height: 24),
        Text(
          context.l10n.welcome,
          style: AppTextStyles.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.tagline,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.selectRole,
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 16),
        _buildRoleCard(
          role: UserRole.shopkeeper,
          title: context.l10n.shopkeeper,
          icon: Icons.store_outlined,
          isSelected: _selectedRole == UserRole.shopkeeper,
        ),
        const SizedBox(height: 12),
        _buildRoleCard(
          role: UserRole.customer,
          title: context.l10n.customer,
          icon: Icons.person_outlined,
          isSelected: _selectedRole == UserRole.customer,
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingBase),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primaryBlue 
                    : AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.primaryBlue,
                size: AppDimensions.iconMedium,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryBlue,
                size: AppDimensions.iconMedium,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.phoneNumber,
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Enter 10-digit mobile number',
            prefixIcon: const Icon(Icons.phone_outlined,color: AppColors.primaryBlue,),
            prefixText: '+91 ',
            filled: true,
            fillColor: AppColors.white,
            counterText: '', // Hide character counter
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
              borderSide: const BorderSide(color: AppColors.dangerRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
              borderSide: const BorderSide(color: AppColors.dangerRed, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            }
            if (!_isValidPhoneNumber(value)) {
              return 'Please enter a valid 10-digit mobile number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.otpSent(_phoneController.text),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          context.l10n.otp,
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: AppTextStyles.h2,
          decoration: InputDecoration(
            hintText: 'Enter 6-digit OTP',
            filled: true,
            fillColor: AppColors.white,
            counterText: '', // Hide character counter
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
              borderSide: const BorderSide(color: AppColors.dangerRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMicro),
              borderSide: const BorderSide(color: AppColors.dangerRed, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'OTP is required';
            }
            if (value.length != 6) {
              return 'Please enter 6-digit OTP';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _resendOtp,
            child: Text(
              context.l10n.resendOtp,
              style: AppTextStyles.link,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return AppButton.primary(
      text: _isOtpSent ? context.l10n.verifyOtp : context.l10n.continueText,
      onPressed: _canProceed() ? _handleAction : null,
      isLoading: _isLoading,
      isFullWidth: true,
    );
  }

  Widget _buildTermsText() {
    return Text(
      context.l10n.termsConditions,
      style: AppTextStyles.caption,
      textAlign: TextAlign.center,
    );
  }

  void _onPhoneChanged() {
    setState(() {}); // Trigger rebuild to update button state
  }

  void _onOtpChanged() {
    setState(() {}); // Trigger rebuild to update button state
  }

  bool _canProceed() {
    if (_isOtpSent) {
      return _otpController.text.length == 6;
    }
    return _selectedRole != null && _isValidPhoneNumber(_phoneController.text);
  }

  bool _isValidPhoneNumber(String phone) {
    // Remove any non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Check if it's exactly 10 digits and starts with 6-9
    return digitsOnly.length == 10 && RegExp(r'^[6-9]').hasMatch(digitsOnly);
  }

  void _handleAction() async {
    if (_isOtpSent) {
      await _verifyOtp();
    } else {
      await _sendOtp();
    }
  }

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
      _isOtpSent = true;
    });
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _resendOtp() async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
      _otpController.clear();
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    }
  }
}

enum UserRole { shopkeeper, customer }
