import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/models/user_model.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// User profile provider
final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, uid) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getUserProfile(uid);
});

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});

// Auth state
class AuthState {
  final bool isLoading;
  final String? error;
  final String? verificationId;
  final UserModel? user;
  final AuthStep step;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.verificationId,
    this.user,
    this.step = AuthStep.phoneInput,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? verificationId,
    UserModel? user,
    AuthStep? step,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      verificationId: verificationId ?? this.verificationId,
      user: user ?? this.user,
      step: step ?? this.step,
    );
  }
}

enum AuthStep {
  phoneInput,
  otpVerification,
  profileSetup,
  completed,
}

// Auth state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(const AuthState());

  // Send OTP
  Future<void> sendOTP(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.sendOTP(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) {
          state = state.copyWith(
            isLoading: false,
            verificationId: verificationId,
            step: AuthStep.otpVerification,
          );
        },
        onError: (error) {
          state = state.copyWith(isLoading: false, error: error);
        },
        onAutoVerify: (credential) async {
          await _signInWithCredential(credential);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Verify OTP
  Future<void> verifyOTP(String otp) async {
    if (state.verificationId == null) {
      state = state.copyWith(error: 'Verification ID not found');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final userCredential = await _authService.verifyOTP(
        verificationId: state.verificationId!,
        otp: otp,
      );

      if (userCredential != null && userCredential.user != null) {
        // Check if user profile exists
        try {
          final userProfile = await _authService.getUserProfile(userCredential.user!.uid);
          
          if (userProfile != null) {
            state = state.copyWith(
              isLoading: false,
              user: userProfile,
              step: AuthStep.completed,
            );
          } else {
            // User authenticated but no profile, create one
            state = state.copyWith(
              isLoading: false,
              step: AuthStep.profileSetup,
            );
          }
        } catch (profileError) {
          // If profile check fails, still mark as authenticated
          state = state.copyWith(
            isLoading: false,
            step: AuthStep.profileSetup,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Authentication failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Create user profile
  Future<void> createProfile({
    required String role,
    String? shopName,
    String? upiId,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.createUserProfile(
        uid: currentUser.uid,
        phoneNumber: currentUser.phoneNumber!,
        role: role,
        shopName: shopName,
        upiId: upiId,
      );

      final userProfile = await _authService.getUserProfile(currentUser.uid);
      
      state = state.copyWith(
        isLoading: false,
        user: userProfile,
        step: AuthStep.completed,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _authService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset auth state
  void reset() {
    state = const AuthState();
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        final userProfile = await _authService.getUserProfile(userCredential.user!.uid);
        
        if (userProfile != null) {
          state = state.copyWith(
            isLoading: false,
            user: userProfile,
            step: AuthStep.completed,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            step: AuthStep.profileSetup,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
