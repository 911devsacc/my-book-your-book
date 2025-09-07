import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import 'request_button.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final String? currentUserId;
  final VoidCallback? onDeleted;

  const PostCard({
    super.key,
    required this.post,
    this.currentUserId,
    this.onDeleted,
  });

  ImageProvider _getProfileImage(Map<String, dynamic>? userData) {
    final profilePicUrl = userData?['profilePic'] as String?;
    final gender = userData?['gender'] as String? ?? 'male';

    if (profilePicUrl != null && profilePicUrl.isNotEmpty) {
      return AssetImage(profilePicUrl);
    } else {
      return AssetImage(
        gender == 'male'
            ? 'assets/images/male_pfp.png'
            : 'assets/images/female_pfp.png',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMyPost = currentUserId == post.ownerId;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(post.ownerId)
          .get(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final displayName = userData?['studentId'] ?? 'Unknown';

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: _getProfileImage(userData),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              post.department,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isMyPost)
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'delete') {
                            try {
                              await PostService.deletePost(post.id);
                              onDeleted?.call();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error deleting post: $e"),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text("Delete"),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  post.bookName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: post.exchangeType == 'free'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    post.exchangeType == 'free'
                        ? "For Free"
                        : "In Exchange for: ${post.exchangeFor ?? ''}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: post.exchangeType == 'free'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: RequestButton(
                    postId: post.id,
                    postOwnerId: post.ownerId,
                    currentUserId: currentUserId,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
