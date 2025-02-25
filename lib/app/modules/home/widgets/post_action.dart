import 'package:flutter/material.dart';
import 'package:twitter_alternative/app/data/models/post_model.dart';
import 'package:twitter_alternative/app/theme/color_theme.dart';

class PostActions extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const PostActions({
    Key? key,
    required this.post,
    required this.onLike,
    required this.onDislike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLiked = post.userReaction == 'like';
    final isDisliked = post.userReaction == 'dislike';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Like button
        _buildActionButton(
          context: context,
          icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
          label: post.likesCount.toString(),
          color: isLiked ? ColorTheme.like : null,
          onTap: onLike,
        ),

        // Dislike button
        _buildActionButton(
          context: context,
          icon: isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
          label: post.dislikesCount.toString(),
          color: isDisliked ? ColorTheme.dislike : null,
          onTap: onDislike,
        ),

        // Share button (placeholder)
        _buildActionButton(
          context: context,
          icon: Icons.share_outlined,
          label: 'Share',
          onTap: () {
            // TODO: Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share functionality coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final textColor = color ??
        (theme.brightness == Brightness.light
            ? ColorTheme.textLight
            : Colors.grey);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? textColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color ?? textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
