import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitter_alternative/app/data/models/post_model.dart';
import 'package:twitter_alternative/app/data/repositories/post_repository.dart';
import 'package:twitter_alternative/app/routes/app_routes.dart';

// Conditional import for web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class PostController extends GetxController {
  final PostRepository _postRepository;

  PostController({
    required PostRepository postRepository,
  }) : _postRepository = postRepository;

  // Feed posts
  final RxList<PostModel> feedPosts = <PostModel>[].obs;
  final RxBool isLoadingFeed = false.obs;
  final RxBool hasMoreFeedPosts = true.obs;
  int feedOffset = 0;
  final int feedLimit = 10;

  // User posts
  final RxList<PostModel> userPosts = <PostModel>[].obs;
  final RxBool isLoadingUserPosts = false.obs;
  final RxBool hasMoreUserPosts = true.obs;
  int userPostsOffset = 0;
  final int userPostsLimit = 10;

  // Post creation/editing
  final contentController = TextEditingController();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);
  final RxString selectedImageName = ''.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // Single post viewing
  final Rx<PostModel?> currentPost = Rx<PostModel?>(null);
  final RxBool isLoadingPost = false.obs;

  // Stream subscription for real-time updates
  RxList<StreamSubscription> subscriptions = <StreamSubscription>[].obs;

  @override
  void onClose() {
    // Dispose of all stream subscriptions
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    contentController.dispose();
    super.onClose();
  }

  // Load feed posts with pagination
  Future<void> loadFeedPosts({bool refresh = false}) async {
    if (refresh) {
      feedOffset = 0;
      hasMoreFeedPosts.value = true;
    }

    if (isLoadingFeed.value || !hasMoreFeedPosts.value) return;

    isLoadingFeed.value = true;

    try {
      final posts = await _postRepository.getFeedPosts(
        offset: feedOffset,
        limit: feedLimit,
      );

      if (refresh) {
        feedPosts.clear();
      }

      if (posts.length < feedLimit) {
        hasMoreFeedPosts.value = false;
      }

      feedPosts.addAll(posts);
      feedOffset += posts.length;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingFeed.value = false;
    }
  }

  // Load posts by a specific user
  Future<void> loadUserPosts({
    required String userId,
    bool refresh = false,
  }) async {
    if (refresh) {
      userPostsOffset = 0;
      hasMoreUserPosts.value = true;
    }

    if (isLoadingUserPosts.value || !hasMoreUserPosts.value) return;

    isLoadingUserPosts.value = true;

    try {
      final posts = await _postRepository.getUserPosts(
        userId: userId,
        offset: userPostsOffset,
        limit: userPostsLimit,
      );

      if (refresh) {
        userPosts.clear();
      }

      if (posts.length < userPostsLimit) {
        hasMoreUserPosts.value = false;
      }

      userPosts.addAll(posts);
      userPostsOffset += posts.length;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingUserPosts.value = false;
    }
  }

  // Create a new post
  Future<void> createPost() async {
    if (contentController.text.trim().isEmpty) {
      errorMessage.value = 'Post content cannot be empty';
      return;
    }

    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      if (kIsWeb) {
        await _postRepository.createPost(
          content: contentController.text.trim(),
          imageBytes: selectedImageBytes.value,
          imageName: selectedImageName.value.isNotEmpty
              ? selectedImageName.value
              : null,
        );
      } else {
        await _postRepository.createPost(
          content: contentController.text.trim(),
          image: selectedImage.value,
        );
      }

      // Clear form
      contentController.clear();
      selectedImage.value = null;
      selectedImageBytes.value = null;
      selectedImageName.value = '';

      Get.back();
      Get.snackbar(
        'Success',
        'Post created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh feed
      loadFeedPosts(refresh: true);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isSubmitting.value = false;
    }
  }

  // Update an existing post
  Future<void> updatePost(String postId) async {
    if (contentController.text.trim().isEmpty) {
      errorMessage.value = 'Post content cannot be empty';
      return;
    }

    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      if (kIsWeb) {
        await _postRepository.updatePost(
          postId: postId,
          content: contentController.text.trim(),
          imageBytes: selectedImageBytes.value,
          imageName: selectedImageName.value.isNotEmpty
              ? selectedImageName.value
              : null,
        );
      } else {
        await _postRepository.updatePost(
          postId: postId,
          content: contentController.text.trim(),
          image: selectedImage.value,
        );
      }

      // Clear form
      contentController.clear();
      selectedImage.value = null;
      selectedImageBytes.value = null;
      selectedImageName.value = '';

      Get.back();
      Get.snackbar(
        'Success',
        'Post updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh data
      if (currentPost.value != null) {
        loadPostById(postId);
      }
      loadFeedPosts(refresh: true);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isSubmitting.value = false;
    }
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await _postRepository.deletePost(postId);

      Get.snackbar(
        'Success',
        'Post deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // If we're viewing the post detail, go back to feed
      if (Get.currentRoute == Routes.POST_DETAIL) {
        Get.back();
      }

      // Refresh feed
      loadFeedPosts(refresh: true);

      // Also refresh user posts if they're being displayed
      if (userPosts.isNotEmpty) {
        loadUserPosts(userId: userPosts.first.userId, refresh: true);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  // Load a single post by ID
  Future<void> loadPostById(String postId) async {
    isLoadingPost.value = true;

    try {
      final post = await _postRepository.getPostById(postId);
      currentPost.value = post;

      // Setup real-time updates for this post
      final subscription =
          _postRepository.getPostStream(postId).listen((updatedPost) {
        currentPost.value = updatedPost;
      });

      subscriptions.add(subscription);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingPost.value = false;
    }
  }

  // Set up post editing
  void setupPostEditing(PostModel post) {
    contentController.text = post.content;
    selectedImage.value = null; // Can't load remote image into File directly
    selectedImageBytes.value = null;
    selectedImageName.value = '';

    // If there's an image URL, we could optionally download it for preview
    // but that's more complex and not necessary for this implementation
  }

  // Add or toggle a reaction (like/dislike)
  Future<void> reactToPost(String postId, String reactionType) async {
    try {
      await _postRepository.reactToPost(
        postId: postId,
        reactionType: reactionType,
      );

      // Update post in local lists
      final feedIndex = feedPosts.indexWhere((post) => post.id == postId);
      if (feedIndex != -1) {
        final post = feedPosts[feedIndex];
        String? newReaction;

        if (post.userReaction == reactionType) {
          // Toggling off the same reaction
          newReaction = null;
        } else {
          // New reaction or changing reaction
          newReaction = reactionType;
        }

        // Update post reaction counts and user reaction locally
        // This will be overwritten when real-time updates are received
        int likesCount = post.likesCount;
        int dislikesCount = post.dislikesCount;

        if (post.userReaction == 'like' && newReaction != 'like') {
          likesCount = Math.max(0, likesCount - 1);
        }
        if (post.userReaction == 'dislike' && newReaction != 'dislike') {
          dislikesCount = Math.max(0, dislikesCount - 1);
        }
        if (newReaction == 'like' && post.userReaction != 'like') {
          likesCount += 1;
        }
        if (newReaction == 'dislike' && post.userReaction != 'dislike') {
          dislikesCount += 1;
        }

        feedPosts[feedIndex] = post.copyWith(
          userReaction: newReaction,
          likesCount: likesCount,
          dislikesCount: dislikesCount,
        );
      }

      // Also update in user posts if present
      final userPostIndex = userPosts.indexWhere((post) => post.id == postId);
      if (userPostIndex != -1) {
        final post = userPosts[userPostIndex];
        String? newReaction;

        if (post.userReaction == reactionType) {
          newReaction = null;
        } else {
          newReaction = reactionType;
        }

        int likesCount = post.likesCount;
        int dislikesCount = post.dislikesCount;

        if (post.userReaction == 'like' && newReaction != 'like') {
          likesCount = Math.max(0, likesCount - 1);
        }
        if (post.userReaction == 'dislike' && newReaction != 'dislike') {
          dislikesCount = Math.max(0, dislikesCount - 1);
        }
        if (newReaction == 'like' && post.userReaction != 'like') {
          likesCount += 1;
        }
        if (newReaction == 'dislike' && post.userReaction != 'dislike') {
          dislikesCount += 1;
        }

        userPosts[userPostIndex] = post.copyWith(
          userReaction: newReaction,
          likesCount: likesCount,
          dislikesCount: dislikesCount,
        );
      }

      // Update current post if viewing
      if (currentPost.value?.id == postId) {
        final post = currentPost.value!;
        String? newReaction;

        if (post.userReaction == reactionType) {
          newReaction = null;
        } else {
          newReaction = reactionType;
        }

        int likesCount = post.likesCount;
        int dislikesCount = post.dislikesCount;

        if (post.userReaction == 'like' && newReaction != 'like') {
          likesCount = Math.max(0, likesCount - 1);
        }
        if (post.userReaction == 'dislike' && newReaction != 'dislike') {
          dislikesCount = Math.max(0, dislikesCount - 1);
        }
        if (newReaction == 'like' && post.userReaction != 'like') {
          likesCount += 1;
        }
        if (newReaction == 'dislike' && post.userReaction != 'dislike') {
          dislikesCount += 1;
        }

        currentPost.value = post.copyWith(
          userReaction: newReaction,
          likesCount: likesCount,
          dislikesCount: dislikesCount,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  // Web-specific image picking method
  Future<void> pickImageWeb() async {
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
        selectedImageName.value = file.name;

        // Read the file as bytes
        final html.FileReader reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoad.first;

        // Set the image bytes
        selectedImageBytes.value =
            Uint8List.fromList(reader.result as List<int>);
      }
    } catch (e) {
      errorMessage.value = 'Error picking image: ${e.toString()}';
    }
  }

  // Mobile-specific image picking method
  Future<void> pickImage() async {
    if (kIsWeb) return;

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        // For consistency, also update the name
        selectedImageName.value = image.name;
      }
    } catch (e) {
      errorMessage.value = 'Error picking image: ${e.toString()}';
    }
  }

  // Mobile-specific camera method
  Future<void> takePhoto() async {
    if (kIsWeb) return;

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        selectedImage.value = File(photo.path);
        // For consistency, also update the name
        selectedImageName.value = photo.name;
      }
    } catch (e) {
      errorMessage.value = 'Error taking photo: ${e.toString()}';
    }
  }

  // Platform-agnostic method to pick image
  Future<void> pickImageCrossPlatform() async {
    if (kIsWeb) {
      await pickImageWeb();
    } else {
      await pickImage();
    }
  }

  // Remove selected image
  void removeImage() {
    selectedImage.value = null;
    selectedImageBytes.value = null;
    selectedImageName.value = '';
  }
}

// Helper for math operations
class Math {
  static int max(int a, int b) {
    return a > b ? a : b;
  }
}
