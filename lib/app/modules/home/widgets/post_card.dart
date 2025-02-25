import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twitter_alternative/app/controllers/auth_controller.dart';
import 'package:twitter_alternative/app/controllers/post_controller.dart';
import 'package:twitter_alternative/app/data/models/post_model.dart';
import 'package:twitter_alternative/app/modules/home/widgets/post_action.dart';
import 'package:twitter_alternative/app/routes/app_routes.dart';
import 'package:twitter_alternative/app/theme/color_theme.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onTap;
  final VoidCallback onProfileTap;
  final bool isDetailView;

  const PostCard({
    Key? key,
    required this.post,
    required this.onLike,
    required this.onDislike,
    required this.onTap,
    required this.onProfileTap,
    this.isDetailView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();

    return InkWell(
      onTap: isDetailView ? null : onTap,
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: isDetailView ? 0.0 : 6.0,
        ),
        elevation: isDetailView ? 0.0 : 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post header with user info
              Row(
                children: [
                  // User avatar
                  GestureDetector(
                    onTap: onProfileTap,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: post.author?.avatarUrl != null
                          ? CachedNetworkImageProvider(post.author!.avatarUrl!)
                          : null,
                      child: post.author?.avatarUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // User name and timestamp
                  Expanded(
                    child: GestureDetector(
                      onTap: onProfileTap,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.author?.displayName ??
                                post.author?.username ??
                                'User',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '@${post.author?.username ?? ''}',
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Post timestamp and menu
                  Row(
                    children: [
                      Text(
                        timeago.format(post.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                      if (authController.currentUser.value?.id == post.userId)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (value) {
                            if (value == 'edit') {
                              Get.toNamed(
                                Routes.CREATE_POST,
                                arguments: {'post': post},
                              );
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(context, post);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),

              // Post content
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  post.content,
                  style: theme.textTheme.bodyMedium,
                ),
              ),

              // Post image if any
              if (post.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          color: theme.colorScheme.background,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          color: theme.colorScheme.background,
                          child: const Center(
                            child: Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Post actions (like, dislike)
              PostActions(
                post: post,
                onLike: onLike,
                onDislike: onDislike,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, PostModel post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.find<PostController>().deletePost(post.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: ColorTheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
