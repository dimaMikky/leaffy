import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twitter_alternative/app/controllers/auth_controller.dart';
import 'package:twitter_alternative/app/theme/color_theme.dart';
import 'package:twitter_alternative/core/widgets/custom_button.dart';
import 'package:twitter_alternative/core/widgets/custom_text_field.dart';
import 'package:twitter_alternative/core/widgets/loading_indicator.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator(
            message: 'Sending reset link...',
            withScaffold: true,
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  // Icon
                  Center(
                    child: Icon(
                      Icons.lock_reset,
                      size: 64,
                      color: ColorTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Forgot your password?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    'Enter your email address and we\'ll send you a link to reset your password.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

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
                  const SizedBox(height: 32),

                  // Reset button
                  CustomButton(
                    text: 'Send Reset Link',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        controller
                            .resetPassword(controller.emailController.text);
                      }
                    },
                    type: ButtonType.primary,
                  ),
                  const SizedBox(height: 16),

                  // Back to sign in
                  CustomButton(
                    text: 'Back to Sign In',
                    onPressed: () => Get.back(),
                    type: ButtonType.text,
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
