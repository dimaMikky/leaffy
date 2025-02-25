import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:twitter_alternative/app/data/models/user_model.dart';
import 'package:twitter_alternative/app/data/providers/supabase_provider.dart';
import 'package:twitter_alternative/core/services/file_service.dart';
import 'package:get/get.dart';

class ProfileRepository {
  final SupabaseProvider _supabaseProvider;
  // Get the FileService from GetX
  final FileService _fileService = Get.find<FileService>();

  ProfileRepository({
    required SupabaseProvider supabaseProvider,
  }) : _supabaseProvider = supabaseProvider;

  // Get user profile by ID
  Future<UserModel> getUserById(String userId) async {
    try {
      final userData = await _supabaseProvider.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUserProfile() async {
    try {
      print("🔄 getCurrentUserProfile called");
      final currentUser = _supabaseProvider.getCurrentUser();
      if (currentUser == null) {
        print("⚠️ No current user found");
        return null;
      }

      print("🔍 Fetching profile for user ID: ${currentUser.id}");

      final userData = await _supabaseProvider.client
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .single();

      print("📊 Raw profile data: $userData");

      if (userData != null) {
        final userModel = UserModel.fromJson(userData);
        print("✅ Profile parsed successfully: ${userModel.username}");
        return userModel;
      } else {
        print("⚠️ No profile data returned from Supabase");
        return null;
      }
    } catch (e) {
      print("❌ Error in getCurrentUserProfile: $e");
      rethrow;
    }
  }

  // Update user profile
  Future<UserModel> updateProfile({
    required String username,
    String? displayName,
    String? bio,
    File? avatar,
    Uint8List? avatarBytes,
    String? avatarName,
  }) async {
    try {
      final currentUser = _supabaseProvider.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check if username is already taken (if changed)
      final existingProfile = await getCurrentUserProfile();
      if (existingProfile != null && existingProfile.username != username) {
        final usernameCheck = await _supabaseProvider.client
            .from('profiles')
            .select('username')
            .eq('username', username)
            .maybeSingle();

        if (usernameCheck != null) {
          throw Exception('Username already taken');
        }
      }

      String? avatarUrl = existingProfile?.avatarUrl;

      // Handle avatar update
      if (avatar != null || (avatarBytes != null && avatarName != null)) {
        // If there's an existing avatar, delete it (if it's not the default one)
        if (existingProfile?.avatarUrl != null &&
            !existingProfile!.avatarUrl!.contains('ui-avatars.com')) {
          final oldAvatarName =
              _fileService.getFileNameFromUrl(existingProfile.avatarUrl!);
          await _fileService.deleteFile(
            bucketName: 'avatars',
            filePath: oldAvatarName,
          );
        }

        // Upload new avatar
        if (kIsWeb && avatarBytes != null && avatarName != null) {
          // Web platform upload
          avatarUrl = await _fileService.uploadFile(
            bucketName: 'avatars',
            fileName: avatarName,
            bytes: avatarBytes,
            contentType: 'image/jpeg',
          );
        } else if (!kIsWeb && avatar != null) {
          // Mobile platform upload
          final bytes = await avatar.readAsBytes();
          final fileName = path.basename(avatar.path);

          avatarUrl = await _fileService.uploadFile(
            bucketName: 'avatars',
            fileName: fileName,
            bytes: bytes,
          );
        }
      }

      // Update profile in database
      final profileData = {
        'username': username,
        'display_name': displayName,
        'bio': bio,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseProvider.client
          .from('profiles')
          .update(profileData)
          .eq('id', currentUser.id)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Search for users by username or display name
  Future<List<UserModel>> searchUsers(String query, {int limit = 10}) async {
    try {
      final response = await _supabaseProvider.client
          .from('profiles')
          .select()
          .or('username.ilike.%$query%,display_name.ilike.%$query%')
          .limit(limit);

      return response
          .map((user) => UserModel.fromJson(user))
          .toList()
          .cast<UserModel>();
    } catch (e) {
      rethrow;
    }
  }
}
