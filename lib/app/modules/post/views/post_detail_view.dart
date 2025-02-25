import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twitter_alternative/app/controllers/post_controller.dart';
import 'package:twitter_alternative/app/controllers/profile_controller.dart';
import 'package:twitter_alternative/app/modules/home/widgets/post_card.dart';
import 'package:twitter_alternative/app/routes/app_routes.dart';
import 'package:twitter_alternative/core/widgets/error_widget.dart';
import 'package:twitter_alternative/core/widgets/loading_indicator.dart';

class PostDetailView extends GetView<PostController> {
  const PostDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        // Show loading indicator when loading
        if (controller.isLoadingPost.value) {
          return const LoadingIndicator(message: 'Loading post...');
        }

        // Show error widget if there's an error
        if (controller.errorMessage.value.isNotEmpty &&
            controller.currentPost.value == null) {
          return ErrorDisplay(
            message: controller.errorMessage.value,
            onRetry: () {
              if (controller.currentPost.value != null) {
                controller.loadPostById(controller.currentPost.value!.id);
              } else {
                Get.back();
              }
            },
          );
        }

        // Show empty state if no post
        if (controller.currentPost.value == null) {
          return const NoDataWidget(
            message: 'Post not found',
            icon: Icons.post_add,
          );
        }

        // Show post
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
            child: PostCard(
              post: controller.currentPost.value!,
              onLike: () => controller.reactToPost(
                controller.currentPost.value!.id,
                'like',
              ),
              onDislike: () => controller.reactToPost(
                controller.currentPost.value!.id,
                'dislike',
              ),
              onTap: () {}, // Already in detail view
              onProfileTap: () {
                profileController
                    .loadProfile(controller.currentPost.value!.userId);
                Get.toNamed(Routes.PROFILE);
              },
              isDetailView: true,
            ),
          ),
        );
      }),
    );
  }
}
