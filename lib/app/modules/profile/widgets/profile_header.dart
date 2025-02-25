import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:twitter_alternative/app/data/models/user_model.dart';
import 'package:twitter_alternative/app/theme/color_theme.dart';
import 'package:twitter_alternative/core/widgets/custom_button.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final bool isCurrentUser;
  final VoidCallback onEditProfile;

  const ProfileHeader({
    Key? key,
    required this.user,
    required this.isCurrentUser,
    required this.onEditProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar and edit profile button
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundImage: user.avatarUrl != null
                    ? CachedNetworkImageProvider(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const Spacer(),

              // Edit profile button
              if (isCurrentUser)
                CustomButton(
                  text: 'Edit Profile',
                  onPressed: onEditProfile,
                  type: ButtonType.outline,
                  isFullWidth: false,
                  width: 120,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Display name
          if (user.displayName != null)
            Text(
              user.displayName!,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

          // Username
          Text(
            '@${user.username}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.brightness == Brightness.light
                  ? ColorTheme.textLight
                  : Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          // Bio
          if (user.bio != null && user.bio!.isNotEmpty)
            Text(
              user.bio!,
              style: theme.textTheme.bodyMedium,
            ),
          const SizedBox(height: 12),

          // Joined date
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: theme.brightness == Brightness.light
                    ? ColorTheme.textLight
                    : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                'Joined ${_formatDate(user.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.brightness == Brightness.light
                      ? ColorTheme.textLight
                      : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tabs
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildTab(
                  context: context,
                  title: 'Posts',
                  isActive: true,
                ),
                _buildTab(
                  context: context,
                  title: 'Media',
                  isActive: false,
                ),
                _buildTab(
                  context: context,
                  title: 'Likes',
                  isActive: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required String title,
    required bool isActive,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: () {
          // Only posts tab is implemented for now
          if (title != 'Posts') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This feature is coming soon!')),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: isActive
                ? Border(
                    bottom: BorderSide(
                      color: ColorTheme.primary,
                      width: 2,
                    ),
                  )
                : null,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isActive ? ColorTheme.primary : null,
              fontWeight: isActive ? FontWeight.bold : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
