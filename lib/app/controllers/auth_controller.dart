import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:twitter_alternative/app/data/models/user_model.dart';
import 'package:twitter_alternative/app/data/repositories/auth_repository.dart';
import 'package:twitter_alternative/app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();

    // Listen for auth state changes
    _authRepository.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedIn) {
        _loadUserProfile();
      } else if (event.event == AuthChangeEvent.signedOut) {
        currentUser.value = null;
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    super.onClose();
  }

// Check if user is already signed in during app startup
  Future<void> checkAuthStatus() async {
    isLoading.value = true;
    try {
      print("Checking auth status...");
      final isLoggedIn = _authRepository
          .isAuthenticated(); // Use authRepository instead of _supabaseProvider
      print("Is logged in: $isLoggedIn");

      if (isLoggedIn) {
        try {
          await _loadUserProfile();
          Get.offAllNamed(Routes.HOME);
        } catch (e) {
          print("Error loading profile: $e");
          Get.offAllNamed(Routes.LOGIN);
        }
      } else {
        print("Not logged in, going to login screen");
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      print("Auth check error: $e");
      errorMessage.value = e.toString();
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }

  // Load user profile data
  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await _authRepository.getUserProfile();
      if (userProfile != null) {
        currentUser.value = userProfile;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  // Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
      );

      if (user != null) {
        currentUser.value = user;
        Get.offAllNamed(Routes.HOME);
      } else {
        errorMessage.value = 'Failed to create account';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (user != null) {
        currentUser.value = user;
        Get.offAllNamed(Routes.HOME);
      } else {
        errorMessage.value = 'Invalid credentials';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _authRepository.signOut();
      currentUser.value = null;
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _authRepository.resetPassword(email);
      Get.snackbar(
        'Success',
        'Password reset link sent to your email',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await _authRepository.signInWithGoogle();

      if (user != null) {
        currentUser.value = user;
        Get.offAllNamed(Routes.HOME);
      } else {
        errorMessage.value = 'Failed to sign in with Google';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with Apple
  Future<void> signInWithApple() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await _authRepository.signInWithApple();

      if (user != null) {
        currentUser.value = user;
        Get.offAllNamed(Routes.HOME);
      } else {
        errorMessage.value = 'Failed to sign in with Apple';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Validate sign up form
  String? validateSignUpForm() {
    if (emailController.text.isEmpty ||
        !GetUtils.isEmail(emailController.text)) {
      return 'Please enter a valid email';
    }

    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (passwordController.text != confirmPasswordController.text) {
      return 'Passwords do not match';
    }

    if (usernameController.text.isEmpty) {
      return 'Please enter a username';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(usernameController.text)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    if (usernameController.text.length < 3 ||
        usernameController.text.length > 30) {
      return 'Username must be between 3 and 30 characters';
    }

    return null;
  }

  // Validate sign in form
  String? validateSignInForm() {
    if (emailController.text.isEmpty ||
        !GetUtils.isEmail(emailController.text)) {
      return 'Please enter a valid email';
    }

    if (passwordController.text.isEmpty) {
      return 'Please enter your password';
    }

    return null;
  }
}
