import 'package:get/get.dart';
import 'package:twitter_alternative/app/controllers/auth_controller.dart';
import 'package:twitter_alternative/app/data/providers/supabase_provider.dart';
import 'package:twitter_alternative/app/data/repositories/auth_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        supabaseProvider: Get.find<SupabaseProvider>(),
      ),
    );

    Get.lazyPut<AuthController>(
      () => AuthController(
        authRepository: Get.find<AuthRepository>(),
      ),
    );
  }
}
