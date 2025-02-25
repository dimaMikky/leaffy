import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twitter_alternative/app/controllers/auth_controller.dart';
import 'package:twitter_alternative/app/routes/app_routes.dart';
import 'package:twitter_alternative/app/theme/color_theme.dart';
import 'package:twitter_alternative/core/widgets/custom_button.dart';
import 'package:twitter_alternative/core/widgets/custom_text_field.dart';
import 'package:twitter_alternative/core/widgets/loading_indicator.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator(
            message: 'Signing in...',
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
                  const SizedBox(height: 40),
                  // Logo and app name
                  Center(
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: ColorTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Twitter Alternative',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ColorTheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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

                  // Password field
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: controller.passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.toNamed(Routes.FORGOT_PASSWORD),
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign in button
                  CustomButton(
                    text: 'Sign In',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        controller.signIn(
                          email: controller.emailController.text,
                          password: controller.passwordController.text,
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

                  // Google sign in
                  CustomButton(
                    text: 'Sign In with Google',
                    onPressed: () => controller.signInWithGoogle(),
                    type: ButtonType.outline,
                    icon: Icons.g_mobiledata,
                  ),
                  const SizedBox(height: 12),

                  // Apple sign in
                  CustomButton(
                    text: 'Sign In with Apple',
                    onPressed: () => controller.signInWithApple(),
                    type: ButtonType.outline,
                    icon: Icons.apple,
                  ),
                  const SizedBox(height: 32),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(Routes.SIGNUP),
                        child: const Text('Sign Up'),
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
