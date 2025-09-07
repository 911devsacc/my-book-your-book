import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/styles.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final ImageProvider profileImage;
  final Timestamp? timestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.profileImage,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingSmall,
        horizontal: AppDimensions.spacingSmall,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: profileImage,
            ),
            const SizedBox(width: AppDimensions.spacingSmall),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacingSmall,
                horizontal: AppDimensions.spacingMedium,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.messageBubbleMe : AppColors.messageBubbleOther,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      message,
                      style: AppTextStyles.messageText.copyWith(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (message.length > 30) // Show expand button if message is long
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                message,
                                style: AppTextStyles.messageText,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          '...',
                          style: AppTextStyles.messageText.copyWith(
                            color: isMe ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: AppDimensions.spacingSmall),
            CircleAvatar(
              radius: 16,
              backgroundImage: profileImage,
            ),
          ],
        ],
      ),
    );
  }
}
