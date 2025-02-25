import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twitter_alternative/app/controllers/app_controller.dart';
import 'package:twitter_alternative/app/controllers/auth_controller.dart';
import 'package:twitter_alternative/app/controllers/post_controller.dart';
import 'package:twitter_alternative/app/controllers/profile_controller.dart';
import 'package:twitter_alternative/app/modules/home/widgets/post_card.dart';
import 'package:twitter_alternative/app/modules/profile/widgets/profile_header.dart';
import 'package:twitter_alternative/app/routes/app_routes.dart';
import 'package:twitter_alternative/core/widgets/error_widget.dart';
import 'package:twitter_alternative/core/widgets/loading_indicator.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("🔄 ProfileView initialized - loading current profile");
      controller.loadCurrentUserProfile();
    });

    final authController = Get.find<AuthController>();
    final postController = Get.find<PostController>();
    final appController = Get.find<AppController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Go back to home if coming from there
            if (appController.currentBottomNavIndex.value == 1) {
              appController.changeBottomNavIndex(0);
              Get.offAllNamed(Routes.HOME);
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: Obx(() {
        // Show loading indicator when loading
        if (controller.isLoadingProfile.value &&
            controller.profileUser.value == null) {
          return const LoadingIndicator(message: 'Loading profile...');
        }

        // Show error widget if there's an error
        if (controller.errorMessage.value.isNotEmpty &&
            controller.profileUser.value == null) {
          return ErrorDisplay(
            message: controller.errorMessage.value,
            onRetry: () {
              if (controller.profileUser.value != null) {
                controller.loadProfile(controller.profileUser.value!.id);
              } else {
                Get.back();
              }
            },
          );
        }

        // Show empty state if no profile
        if (controller.profileUser.value == null) {
          return const NoDataWidget(
            message: 'Profile not found',
            icon: Icons.person_off,
          );
        }

        final user = controller.profileUser.value!;
        final isCurrentUser = authController.currentUser.value?.id == user.id;

        return RefreshIndicator(
          onRefresh: () async {
            controller.loadProfile(user.id);
            await postController.loadUserPosts(userId: user.id, refresh: true);
          },
          child: CustomScrollView(
            slivers: [
              // Profile header
              SliverToBoxAdapter(
                child: ProfileHeader(
                  user: user,
                  isCurrentUser: isCurrentUser,
                  onEditProfile: () => Get.toNamed(Routes.EDIT_PROFILE),
                ),
              ),

              // Post loading indicator
              if (postController.isLoadingUserPosts.value &&
                  postController.userPosts.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (postController.userPosts.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.post_add,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isCurrentUser
                                ? 'You haven\'t posted anything yet'
                                : '${user.displayName ?? user.username} hasn\'t posted anything yet',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => Get.toNamed(Routes.CREATE_POST),
                              child: const Text('Create Your First Post'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              else
                // User posts
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Show loading indicator at the bottom when loading more
                      if (index == postController.userPosts.length) {
                        if (postController.isLoadingUserPosts.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (postController.hasMoreUserPosts.value) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: TextButton(
                                onPressed: () => postController.loadUserPosts(
                                  userId: user.id,
                                ),
                                child: const Text('Load More'),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox(height: 80); // Bottom padding
                        }
                      }

                      // Show post card
                      return PostCard(
                        post: postController.userPosts[index],
                        onLike: () => postController.reactToPost(
                          postController.userPosts[index].id,
                          'like',
                        ),
                        onDislike: () => postController.reactToPost(
                          postController.userPosts[index].id,
                          'dislike',
                        ),
                        onTap: () {
                          postController
                              .loadPostById(postController.userPosts[index].id);
                          Get.toNamed(Routes.POST_DETAIL);
                        },
                        onProfileTap: () {}, // Already on the profile page
                      );
                    },
                    childCount: postController.userPosts.length +
                        1, // +1 for loading indicator
                  ),
                ),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() {
        // Show FAB only if viewing current user's profile
        final isCurrentUser = authController.currentUser.value?.id ==
            controller.profileUser.value?.id;
        if (isCurrentUser) {
          return FloatingActionButton(
            onPressed: () => Get.toNamed(Routes.CREATE_POST),
            child: const Icon(Icons.add),
          );
        }
        return const SizedBox.shrink();
      }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: appController.currentBottomNavIndex.value,
            onTap: (index) {
              appController.changeBottomNavIndex(index);
              if (index == 0) {
                Get.offAllNamed(Routes.HOME);
              } else if (index == 1) {
                // Already on profile, refresh
                controller.loadCurrentUserProfile();
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          )),
    );
  }
}
