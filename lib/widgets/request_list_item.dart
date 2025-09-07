import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/post_service.dart';
import '../services/chat_service.dart';
import '../pages/inside/chat_message_page.dart';
import 'app_snack_bar.dart';

class RequestListItem extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final String requestId;
  final String postId;
  final bool isReceived;
  final VoidCallback? onStatusChanged;

  const RequestListItem({
    super.key,
    required this.requestData,
    required this.requestId,
    required this.postId,
    required this.isReceived,
    this.onStatusChanged,
  });

  void _updateStatus(BuildContext context, String status) async {
    try {
      await PostService.updateRequestStatus(postId, requestId, status);
      
      if (status == 'accepted') {
        // Create a chat when request is accepted
        final requesterId = requestData['requesterId'] as String;
        final bookName = requestData['bookName'] as String;
        
        final chatId = await ChatService.createOrGetChat(
          otherUserId: requesterId,
          bookName: bookName,
        );
        
        if (context.mounted) {
          AppSnackBar.showSuccess(context, 'Request accepted ✅');
          // Navigate to chat
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatMessagesPage(
                chatId: chatId,
                otherUserId: requesterId,
                otherUserDisplayName: requestData['requesterStudentID'] as String,
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          AppSnackBar.show(context, message: 'Request rejected ❌');
        }
      }
      
      onStatusChanged?.call();
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, 'Error updating request: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get(),
      builder: (context, postSnapshot) {
        if (postSnapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!postSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final postData = postSnapshot.data!.data() as Map<String, dynamic>;
        final bookName = postData['bookName'] as String;
        final exchangeType = postData['exchangeType'] as String;
        final exchangeFor = postData['exchangeFor'] as String?;
        final department = postData['department'] as String;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Info
                Text(
                  bookName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  department,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                // Exchange Info
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: exchangeType == 'free'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    exchangeType == 'free'
                        ? 'Free'
                        : 'Exchange for: $exchangeFor',
                    style: TextStyle(
                      color: exchangeType == 'free'
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isReceived && requestData['status'] == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _updateStatus(context, 'rejected'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _updateStatus(context, 'accepted'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Accept'),
                      ),
                    ],
                  ),
                ],
                if (!isReceived || requestData['status'] != 'pending') ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(requestData['status'])
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(requestData['status']),
                          style: TextStyle(
                            color: _getStatusColor(requestData['status']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted ✓';
      case 'rejected':
        return 'Rejected ✗';
      default:
        return 'Pending...';
    }
  }
}
