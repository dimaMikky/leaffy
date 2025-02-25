import 'package:get/get.dart';
import 'package:twitter_alternative/app/controllers/auth_controller.dart';
import 'package:twitter_alternative/app/controllers/post_controller.dart';
import 'package:twitter_alternative/app/controllers/profile_controller.dart';
import 'package:twitter_alternative/app/data/providers/supabase_provider.dart';
import 'package:twitter_alternative/app/data/repositories/post_repository.dart';
import 'package:twitter_alternative/app/data/repositories/profile_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    if (!Get.isRegistered<PostRepository>()) {
      Get.put<PostRepository>(
        PostRepository(
          supabaseProvider: Get.find<SupabaseProvider>(),
        ),
      );
    }

    if (!Get.isRegistered<ProfileRepository>()) {
      Get.put<ProfileRepository>(
        ProfileRepository(
          supabaseProvider: Get.find<SupabaseProvider>(),
        ),
      );
    }

    // Controllers
    if (!Get.isRegistered<PostController>()) {
      Get.put<PostController>(
        PostController(
          postRepository: Get.find<PostRepository>(),
        ),
      );
    }

    if (!Get.isRegistered<ProfileController>()) {
      Get.put<ProfileController>(
        ProfileController(
          profileRepository: Get.find<ProfileRepository>(),
          postController: Get.find<PostController>(),
          authController: Get.find<AuthController>(),
        ),
      );
    }
  }
}
