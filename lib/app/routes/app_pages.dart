import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twitter_alternative/app/bindings/auth_binding.dart';
import 'package:twitter_alternative/app/bindings/home_binding.dart';
import 'package:twitter_alternative/app/bindings/post_binding.dart';
import 'package:twitter_alternative/app/bindings/profile_binding.dart';
import 'package:twitter_alternative/app/modules/auth/views/forgot_password_view.dart';
import 'package:twitter_alternative/app/modules/auth/views/login_view.dart';
import 'package:twitter_alternative/app/modules/auth/views/signup_view.dart';
import 'package:twitter_alternative/app/modules/home/views/home_view.dart';
import 'package:twitter_alternative/app/modules/post/views/create_post_view.dart';
import 'package:twitter_alternative/app/modules/post/views/post_detail_view.dart';
import 'package:twitter_alternative/app/modules/profile/views/edit_profile_view.dart';
import 'package:twitter_alternative/app/modules/profile/views/profile_view.dart';
import 'package:twitter_alternative/app/routes/app_routes.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    // GetPage(
    //   name: Routes.SPLASH,
    //   page: () => const SplashView(),
    //   binding: AuthBinding(),
    // ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.CREATE_POST,
      page: () => const CreatePostView(),
      binding: PostBinding(),
    ),
    GetPage(
      name: Routes.POST_DETAIL,
      page: () => const PostDetailView(),
      binding: PostBinding(),
    ),
  ];
}

// This is a placeholder for the SplashView which will be implemented later
class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
