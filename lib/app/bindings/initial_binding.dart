import 'package:get/get.dart';
import 'package:twitter_alternative/app/controllers/app_controller.dart';
import 'package:twitter_alternative/app/controllers/auth_controller.dart';
import 'package:twitter_alternative/app/controllers/post_controller.dart';
import 'package:twitter_alternative/app/controllers/profile_controller.dart';
import 'package:twitter_alternative/app/data/providers/supabase_provider.dart';
import 'package:twitter_alternative/app/data/repositories/auth_repository.dart';
import 'package:twitter_alternative/app/data/repositories/post_repository.dart';
import 'package:twitter_alternative/app/data/repositories/profile_repository.dart';
import 'package:twitter_alternative/core/services/connectivity_service.dart';
import 'package:twitter_alternative/core/services/file_service.dart';
import 'package:twitter_alternative/core/services/media_service.dart';
import 'package:twitter_alternative/core/services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    print("📥 Initializing dependencies...");

    // Core Services - permanent instances
    Get.put(ConnectivityService(), permanent: true);
    Get.put(StorageService(), permanent: true);
    Get.put(MediaService(), permanent: true);
    Get.put(FileService(), permanent: true);

    // Provider - permanent instance
    final supabaseProvider = Get.put(SupabaseProvider(), permanent: true);
    supabaseProvider.initAuthState();

    // Repositories
    Get.put(
      AuthRepository(supabaseProvider: Get.find<SupabaseProvider>()),
      permanent: true,
    );

    Get.put(
      PostRepository(supabaseProvider: Get.find<SupabaseProvider>()),
      permanent: true,
    );

    Get.put(
      ProfileRepository(supabaseProvider: Get.find<SupabaseProvider>()),
      permanent: true,
    );

    // Controllers
    Get.put(
      AppController(connectivityService: Get.find<ConnectivityService>()),
      permanent: true,
    );

    Get.put(
      AuthController(authRepository: Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put(
      PostController(postRepository: Get.find<PostRepository>()),
      permanent: true,
    );

    // Profile controller depends on PostController and AuthController
    Get.put(
      ProfileController(
        profileRepository: Get.find<ProfileRepository>(),
        postController: Get.find<PostController>(),
        authController: Get.find<AuthController>(),
      ),
      permanent: true,
    );

    print("✅ All dependencies initialized successfully");
  }
}
