import 'package:get/get.dart';
import 'package:twitter_alternative/app/controllers/post_controller.dart';
import 'package:twitter_alternative/app/data/providers/supabase_provider.dart';
import 'package:twitter_alternative/app/data/repositories/post_repository.dart';

class PostBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PostRepository>()) {
      Get.put<PostRepository>(
        PostRepository(
          supabaseProvider: Get.find<SupabaseProvider>(),
        ),
      );
    }

    if (!Get.isRegistered<PostController>()) {
      Get.put<PostController>(
        PostController(
          postRepository: Get.find<PostRepository>(),
        ),
      );
    }
  }
}
