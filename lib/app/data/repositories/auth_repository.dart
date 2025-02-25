import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:twitter_alternative/app/data/models/user_model.dart';
import 'package:twitter_alternative/app/data/providers/supabase_provider.dart';

class AuthRepository {
  final SupabaseProvider _supabaseProvider;

  AuthRepository({
    required SupabaseProvider supabaseProvider,
  }) : _supabaseProvider = supabaseProvider;
  Future<UserModel?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      // First, attempt to sign up the user
      final response = await _supabaseProvider.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        try {
          print("User created, now manually creating profile");

          // Manually create a profile for the user
          final displayName = email.split('@').first;
          final avatarUrl =
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}';

          // Use upsert to handle both insert and update cases
          await _supabaseProvider.client.from('profiles').upsert({
            'id': response.user!.id,
            'username': email,
            'display_name': displayName,
            'avatar_url': avatarUrl,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

          // Fetch the created profile
          final userData = await _supabaseProvider.client
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .single();

          return UserModel.fromJson(userData);
        } catch (profileError) {
          print("Error creating profile: $profileError");
          // Continue anyway - at least the user was created
          // Create a minimal UserModel
          return UserModel(
            id: response.user!.id,
            username: email,
            displayName: email.split('@').first,
            avatarUrl:
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(email.split('@').first)}',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }
      return null;
    } catch (e) {
      print("Error during signup: $e");
      rethrow;
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseProvider.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Fetch user profile
        final userData = await _supabaseProvider.client
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .single();

        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseProvider.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabaseProvider.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabaseProvider.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final user = await _supabaseProvider.signInWithGoogle();

      if (user != null) {
        // Fetch user profile
        final userData = await _supabaseProvider.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signInWithApple() async {
    try {
      final user = await _supabaseProvider.signInWithApple();

      if (user != null) {
        // Fetch user profile
        final userData = await _supabaseProvider.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  bool isAuthenticated() {
    return _supabaseProvider.isAuthenticated();
  }

  User? getCurrentUser() {
    return _supabaseProvider.getCurrentUser();
  }

  Stream<AuthState> get onAuthStateChange =>
      _supabaseProvider.onAuthStateChange;

  Future<UserModel?> getUserProfile() async {
    try {
      final currentUser = _supabaseProvider.getCurrentUser();
      if (currentUser == null) return null;

      final userData = await _supabaseProvider.client
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .single();

      return UserModel.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }
}
