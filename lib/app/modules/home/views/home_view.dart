import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twitter_alternative/app/controllers/app_controller.dart';
import 'package:twitter_alternative/app/controllers/auth_controller.dart';
import 'package:twitter_alternative/app/controllers/post_controller.dart';
import 'package:twitter_alternative/app/controllers/profile_controller.dart';
import 'package:twitter_alternative/app/modules/home/widgets/post_card.dart';
import 'package:twitter_alternative/app/routes/app_routes.dart';
import 'package:twitter_alternative/app/theme/color_theme.dart';
import 'package:twitter_alternative/core/widgets/error_widget.dart';
import 'package:twitter_alternative/core/widgets/loading_indicator.dart';

class HomeView extends GetView<PostController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final authController = Get.find<AuthController>();
    final profileController = Get.find<ProfileController>();

    // Load feed posts on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadFeedPosts(refresh: true);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twitter Alternative'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadFeedPosts(refresh: true),
          ),
        ],
      ),
      body: Obx(() {
        // Show loading indicator when first loading
        if (controller.isLoadingFeed.value && controller.feedPosts.isEmpty) {
          return const LoadingIndicator(message: 'Loading feed...');
        }

        // Show error widget if there's an error
        if (controller.errorMessage.value.isNotEmpty &&
            controller.feedPosts.isEmpty) {
          return ErrorDisplay(
            message: controller.errorMessage.value,
            onRetry: () => controller.loadFeedPosts(refresh: true),
          );
        }

        // Show empty state if no posts
        if (controller.feedPosts.isEmpty) {
          return NoDataWidget(
            message: 'No posts yet. Be the first to post!',
            actionText: 'Create Post',
            onAction: () => Get.toNamed(Routes.CREATE_POST),
            icon: Icons.post_add,
          );
        }

        // Show feed
        return RefreshIndicator(
          onRefresh: () => controller.loadFeedPosts(refresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount:
                controller.feedPosts.length + 1, // +1 for loading indicator
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom when loading more
              if (index == controller.feedPosts.length) {
                if (controller.isLoadingFeed.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (controller.hasMoreFeedPosts.value) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: TextButton(
                        onPressed: () => controller.loadFeedPosts(),
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
                post: controller.feedPosts[index],
                onLike: () => controller.reactToPost(
                  controller.feedPosts[index].id,
                  'like',
                ),
                onDislike: () => controller.reactToPost(
                  controller.feedPosts[index].id,
                  'dislike',
                ),
                onTap: () {
                  controller.loadPostById(controller.feedPosts[index].id);
                  Get.toNamed(Routes.POST_DETAIL);
                },
                onProfileTap: () {
                  profileController
                      .loadProfile(controller.feedPosts[index].userId);
                  Get.toNamed(Routes.PROFILE);
                },
              );
            },
          ),
        );
      }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: appController.currentBottomNavIndex.value,
            onTap: (index) {
              appController.changeBottomNavIndex(index);
              if (index == 0) {
                // Already on home, refresh
                controller.loadFeedPosts(refresh: true);
              } else if (index == 1) {
                // Go to profile
                profileController.loadCurrentUserProfile();
                Get.toNamed(Routes.PROFILE);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.CREATE_POST),
        child: const Icon(Icons.add),
        backgroundColor: ColorTheme.primary,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Obx(() {
              final user = authController.currentUser.value;
              return UserAccountsDrawerHeader(
                accountName:
                    Text(user?.displayName ?? user?.username ?? 'User'),
                accountEmail: Text(user?.username ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  child:
                      user?.avatarUrl == null ? const Icon(Icons.person) : null,
                ),
                decoration: BoxDecoration(
                  color: ColorTheme.primary,
                ),
              );
            }),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Get.back();
                appController.changeBottomNavIndex(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Get.back();
                profileController.loadCurrentUserProfile();
                Get.toNamed(Routes.PROFILE);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Get.back();
                // TODO: Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Toggle Theme'),
              onTap: () {
                appController.toggleDarkMode();
                Get.back();
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                Get.back();
                authController.signOut();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
