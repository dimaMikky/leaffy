import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twitter_alternative/app/controllers/auth_controller.dart';
import 'package:twitter_alternative/app/routes/app_routes.dart';
import 'package:twitter_alternative/app/theme/color_theme.dart';
import 'package:twitter_alternative/core/widgets/custom_button.dart';
import 'package:twitter_alternative/core/widgets/custom_text_field.dart';
import 'package:twitter_alternative/core/widgets/loading_indicator.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator(
            message: 'Creating account...',
            withScaffold: true,
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App icon
                  Center(
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: ColorTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Join the conversation',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create an account to get started',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Error message if any
                  if (controller.errorMessage.value.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(color: ColorTheme.error),
                      ),
                    ),
                  if (controller.errorMessage.value.isNotEmpty)
                    const SizedBox(height: 16),

                  // Email field
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Username field (new)
                  CustomTextField(
                    label: 'Username',
                    hint: 'Choose a unique username',
                    controller: controller.usernameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                        return 'Username can only contain letters, numbers, and underscores';
                      }
                      if (value.length < 3 || value.length > 30) {
                        return 'Username must be between 3 and 30 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    label: 'Password',
                    hint: 'Create a password (min. 6 characters)',
                    controller: controller.passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    controller: controller.confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != controller.passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Terms and conditions
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'By signing up, you agree to our Terms of Service and Privacy Policy',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sign up button
                  CustomButton(
                    text: 'Create Account',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        controller.signUp(
                          email: controller.emailController.text,
                          password: controller.passwordController.text,
                          username: controller.usernameController.text,
                        );
                      }
                    },
                    type: ButtonType.primary,
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google sign up
                  CustomButton(
                    text: 'Sign Up with Google',
                    onPressed: () => controller.signInWithGoogle(),
                    type: ButtonType.outline,
                    icon: Icons.g_mobiledata,
                  ),
                  const SizedBox(height: 12),

                  // Apple sign up
                  CustomButton(
                    text: 'Sign Up with Apple',
                    onPressed: () => controller.signInWithApple(),
                    type: ButtonType.outline,
                    icon: Icons.apple,
                  ),
                  const SizedBox(height: 32),

                  // Sign in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(Routes.LOGIN),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
