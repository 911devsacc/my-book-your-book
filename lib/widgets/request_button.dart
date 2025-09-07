import 'package:flutter/material.dart';
import '../services/post_service.dart';
import 'app_snack_bar.dart';

class RequestButton extends StatelessWidget {
  final String postId;
  final String postOwnerId;
  final String? currentUserId;

  const RequestButton({
    super.key,
    required this.postId,
    required this.postOwnerId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isMyPost = currentUserId == postOwnerId;

    if (currentUserId == null) return const SizedBox.shrink();

    return StreamBuilder(
      stream: PostService.getPostRequests(postId, currentUserId!),
      builder: (context, snapshot) {
        final hasPendingRequest =
            snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isMyPost || hasPendingRequest
                ? Colors.grey
                : Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: isMyPost || hasPendingRequest
              ? null
              : () async {
                  try {
                    await PostService.sendRequest(postId);
                    if (context.mounted) {
                      AppSnackBar.showSuccess(context, "Request sent ✅");
                    }
                  } catch (e) {
                    if (context.mounted) {
                      AppSnackBar.showError(context, "Error sending request: $e");
                    }
                  }
                },
          child: Text(
            isMyPost
                ? "Your Post"
                : hasPendingRequest
                    ? "Requested"
                    : "Request",
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}
