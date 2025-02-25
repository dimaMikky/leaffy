import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twitter_alternative/app/controllers/auth_controller.dart';
import 'package:twitter_alternative/app/controllers/post_controller.dart';
import 'package:twitter_alternative/app/data/models/post_model.dart';
import 'package:twitter_alternative/app/theme/color_theme.dart';
import 'package:twitter_alternative/core/widgets/custom_button.dart';
import 'package:twitter_alternative/core/widgets/loading_indicator.dart';

class CreatePostView extends GetView<PostController> {
  const CreatePostView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);
    final isEditing = Get.arguments != null && Get.arguments['post'] != null;
    final PostModel? postToEdit =
        isEditing ? Get.arguments['post'] as PostModel : null;

    // Set up controller with existing post data if editing
    if (isEditing && postToEdit != null) {
      controller.setupPostEditing(postToEdit);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Post' : 'Create Post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Clear form and go back
            controller.contentController.clear();
            controller.selectedImage.value = null;
            Get.back();
          },
        ),
      ),
      body: Obx(() {
        if (controller.isSubmitting.value) {
          return const LoadingIndicator(
            message: 'Submitting post...',
          );
        }

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error message if any
                      if (controller.errorMessage.value.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            controller.errorMessage.value,
                            style: TextStyle(color: ColorTheme.error),
                          ),
                        ),

                      // User info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User avatar
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                authController.currentUser.value?.avatarUrl !=
                                        null
                                    ? NetworkImage(authController
                                        .currentUser.value!.avatarUrl!)
                                    : null,
                            child:
                                authController.currentUser.value?.avatarUrl ==
                                        null
                                    ? const Icon(Icons.person)
                                    : null,
                          ),
                          const SizedBox(width: 12),

                          // Post content field
                          Expanded(
                            child: TextField(
                              controller: controller.contentController,
                              maxLines: 8,
                              minLines: 3,
                              decoration: InputDecoration(
                                hintText: 'What\'s on your mind?',
                                border: InputBorder.none,
                                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.brightness == Brightness.light
                                      ? ColorTheme.textLight
                                      : Colors.grey,
                                ),
                              ),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Selected image preview
                      if (controller.selectedImage.value != null ||
                          (isEditing && postToEdit?.imageUrl != null))
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: controller.selectedImage.value != null
                                  ? Image.file(
                                      controller.selectedImage.value!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    )
                                  : postToEdit?.imageUrl != null
                                      ? Image.network(
                                          postToEdit!.imageUrl!,
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        )
                                      : const SizedBox(),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => controller.removeImage(),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom actions
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Image picker
                    IconButton(
                      icon: const Icon(Icons.photo_library),
                      onPressed: () => controller.pickImage(),
                    ),

                    // Camera
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () => controller.takePhoto(),
                    ),

                    const Spacer(),

                    // Post button
                    CustomButton(
                      text: isEditing ? 'Update' : 'Post',
                      onPressed: () {
                        if (isEditing && postToEdit != null) {
                          controller.updatePost(postToEdit.id);
                        } else {
                          controller.createPost();
                        }
                      },
                      type: ButtonType.primary,
                      isFullWidth: false,
                      width: 100,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
