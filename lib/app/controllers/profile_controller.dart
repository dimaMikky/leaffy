import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitter_alternative/app/controllers/auth_controller.dart';
import 'package:twitter_alternative/app/controllers/post_controller.dart';
import 'package:twitter_alternative/app/data/models/user_model.dart';
import 'package:twitter_alternative/app/data/repositories/profile_repository.dart';

// Conditional import for web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class ProfileController extends GetxController {
  final ProfileRepository _profileRepository;
  final PostController _postController;
  final AuthController _authController;

  ProfileController({
    required ProfileRepository profileRepository,
    required PostController postController,
    required AuthController authController,
  })  : _profileRepository = profileRepository,
        _postController = postController,
        _authController = authController;

  // Profile data
  final Rx<UserModel?> profileUser = Rx<UserModel?>(null);
  final RxBool isLoadingProfile = false.obs;
  final RxString errorMessage = ''.obs;

  // Edit profile
  final usernameController = TextEditingController();
  final displayNameController = TextEditingController();
  final bioController = TextEditingController();
  final Rx<File?> selectedAvatar = Rx<File?>(null);
  final Rx<Uint8List?> selectedAvatarBytes = Rx<Uint8List?>(null);
  final RxString selectedAvatarName = ''.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    usernameController.dispose();
    displayNameController.dispose();
    bioController.dispose();
    super.onClose();
  }

  // Load profile by user ID
  Future<void> loadProfile(String userId) async {
    isLoadingProfile.value = true;
    errorMessage.value = '';

    try {
      final user = await _profileRepository.getUserById(userId);
      profileUser.value = user;

      // Load this user's posts
      await _postController.loadUserPosts(userId: userId, refresh: true);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingProfile.value = false;
    }
  }

// In loadCurrentUserProfile method:
  Future<void> loadCurrentUserProfile() async {
    isLoadingProfile.value = true;
    errorMessage.value = '';

    try {
      print("🔍 Attempting to load current user profile");
      final user = await _profileRepository.getCurrentUserProfile();
      print("📊 Profile fetch result: ${user?.toJson()}");

      if (user != null) {
        profileUser.value = user;
        print("✅ Successfully set profile: ${profileUser.value?.username}");

        // Load current user's posts
        print("📱 Now loading user posts for ID: ${user.id}");
        await _postController.loadUserPosts(userId: user.id, refresh: true);
      } else {
        errorMessage.value = 'Failed to load profile';
        print("❌ Failed to load profile: received null");
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print("❌ Error loading profile: $e");
    } finally {
      isLoadingProfile.value = false;
      print(
          "🏁 Profile loading complete. Success: ${profileUser.value != null}");
    }
  }

  // Setup profile editing
  void setupProfileEditing() {
    final user = profileUser.value;
    if (user != null) {
      usernameController.text = user.username;
      displayNameController.text = user.displayName ?? '';
      bioController.text = user.bio ?? '';
      selectedAvatar.value = null; // Can't load remote image into File directly
      selectedAvatarBytes.value = null;
      selectedAvatarName.value = '';
    }
  }

  // Update profile
  Future<void> updateProfile() async {
    if (usernameController.text.trim().isEmpty) {
      errorMessage.value = 'Username cannot be empty';
      return;
    }

    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      final UserModel updatedUser;

      if (kIsWeb) {
        updatedUser = await _profileRepository.updateProfile(
          username: usernameController.text.trim(),
          displayName: displayNameController.text.trim().isNotEmpty
              ? displayNameController.text.trim()
              : null,
          bio: bioController.text.trim().isNotEmpty
              ? bioController.text.trim()
              : null,
          avatarBytes: selectedAvatarBytes.value,
          avatarName: selectedAvatarName.value.isNotEmpty
              ? selectedAvatarName.value
              : null,
        );
      } else {
        updatedUser = await _profileRepository.updateProfile(
          username: usernameController.text.trim(),
          displayName: displayNameController.text.trim().isNotEmpty
              ? displayNameController.text.trim()
              : null,
          bio: bioController.text.trim().isNotEmpty
              ? bioController.text.trim()
              : null,
          avatar: selectedAvatar.value,
        );
      }

      profileUser.value = updatedUser;
      _authController.currentUser.value = updatedUser;

      Get.back();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isSubmitting.value = false;
    }
  }

  // Web-specific avatar picker
  Future<void> pickAvatarWeb() async {
    if (!kIsWeb) return;

    try {
      // Create a file input element
      final html.FileUploadInputElement input = html.FileUploadInputElement()
        ..accept = 'image/*';

      // Trigger click to open file picker
      input.click();

      // Wait for user to select a file
      await input.onChange.first;
      if (input.files!.isNotEmpty) {
        final html.File file = input.files![0];
        selectedAvatarName.value = file.name;

        // Read the file as bytes
        final html.FileReader reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoad.first;

        // Set the avatar bytes
        selectedAvatarBytes.value =
            Uint8List.fromList(reader.result as List<int>);
      }
    } catch (e) {
      errorMessage.value = 'Error picking avatar: ${e.toString()}';
    }
  }

  // Mobile-specific avatar picker
  Future<void> pickAvatar() async {
    if (kIsWeb) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (image != null) {
        selectedAvatar.value = File(image.path);
        // For consistency, also store the name
        selectedAvatarName.value = image.name;
      }
    } catch (e) {
      errorMessage.value = 'Error picking avatar: ${e.toString()}';
    }
  }

  // Mobile-specific camera method
  Future<void> takePhoto() async {
    if (kIsWeb) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (photo != null) {
        selectedAvatar.value = File(photo.path);
        // For consistency, also store the name
        selectedAvatarName.value = photo.name;
      }
    } catch (e) {
      errorMessage.value = 'Error taking photo: ${e.toString()}';
    }
  }

  // Platform-agnostic method to pick avatar
  Future<void> pickAvatarCrossPlatform() async {
    if (kIsWeb) {
      await pickAvatarWeb();
    } else {
      await pickAvatar();
    }
  }

  // Remove selected avatar
  void removeAvatar() {
    selectedAvatar.value = null;
    selectedAvatarBytes.value = null;
    selectedAvatarName.value = '';
  }

  // Search for users by username or display name
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      return await _profileRepository.searchUsers(query);
    } catch (e) {
      errorMessage.value = e.toString();
      return [];
    }
  }
}
