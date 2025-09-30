import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/providers/app_providers.dart';

/// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseService.authStateChanges;
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Phone verification provider
final phoneVerificationProvider = StateNotifierProvider<PhoneVerificationNotifier, PhoneVerificationState>((ref) {
  return PhoneVerificationNotifier();
});

/// Phone verification state
class PhoneVerificationState {
  final bool isLoading;
  final String? verificationId;
  final String? errorMessage;
  final bool isCodeSent;
  final bool isVerified;

  const PhoneVerificationState({
    this.isLoading = false,
    this.verificationId,
    this.errorMessage,
    this.isCodeSent = false,
    this.isVerified = false,
  });

  PhoneVerificationState copyWith({
    bool? isLoading,
    String? verificationId,
    String? errorMessage,
    bool? isCodeSent,
    bool? isVerified,
  }) {
    return PhoneVerificationState(
      isLoading: isLoading ?? this.isLoading,
      verificationId: verificationId ?? this.verificationId,
      errorMessage: errorMessage ?? this.errorMessage,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

/// Phone verification notifier
class PhoneVerificationNotifier extends StateNotifier<PhoneVerificationState> {
  PhoneVerificationNotifier() : super(const PhoneVerificationState());

  /// Send OTP to phone number
  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await FirebaseService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: e.message ?? 'Verification failed',
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          state = state.copyWith(
            isLoading: false,
            verificationId: verificationId,
            isCodeSent: true,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Verify OTP code
  Future<void> verifyOtp(String smsCode) async {
    if (state.verificationId == null) {
      state = state.copyWith(errorMessage: 'No verification ID found');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final userCredential = await FirebaseService.signInWithPhone(
        state.verificationId!,
        smsCode,
      );

      if (userCredential != null) {
        state = state.copyWith(
          isLoading: false,
          isVerified: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid OTP code',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid OTP code',
      );
    }
  }

  /// Sign in with credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      state = state.copyWith(
        isLoading: false,
        isVerified: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reset state
  void reset() {
    state = const PhoneVerificationState();
  }
}

/// User role provider
final userRoleProvider = StateProvider<UserRole>((ref) {
  return UserRole.merchant;
});

/// User role enum
enum UserRole {
  merchant,
  customer,
}

/// User profile provider
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  try {
    final doc = await FirebaseService.getUserData(user.uid);
    return doc.data() as Map<String, dynamic>?;
  } catch (e) {
    return null;
  }
});

/// Save user profile provider
final saveUserProfileProvider = Provider<Future<void> Function(Map<String, dynamic>)>((ref) {
  return (userData) async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await FirebaseService.saveUserData(user.uid, userData);
      await FirebaseService.setUserId(user.uid);
    }
  };
});
