import 'package:flutter/material.dart';
import '../constants/styles.dart';
import '../utils/date_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListItem extends StatelessWidget {
  final String displayName;
  final String lastMessage;
  final ImageProvider profileImage;
  final bool userExists;
  final Timestamp? lastUpdated;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.displayName,
    required this.lastMessage,
    required this.profileImage,
    required this.userExists,
    this.lastUpdated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSmall,
        vertical: 4,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: profileImage,
          backgroundColor: userExists ? null : AppColors.textSecondary,
        ),
        title: Text(
          displayName,
          style: AppTextStyles.bodyText.copyWith(
            color: userExists ? AppColors.text : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              lastMessage,
              style: AppTextStyles.caption.copyWith(
                fontStyle: FontStyle.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (lastUpdated != null)
              Text(
                DateFormatter.formatTimestamp(lastUpdated!),
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
