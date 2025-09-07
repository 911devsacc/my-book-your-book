import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_book_your_book/widgets/message_bubble.dart';

class MessageList extends StatefulWidget {
  final List<QueryDocumentSnapshot> messages;
  final Map<String, Map<String, String>> userProfiles;

  const MessageList({super.key, required this.messages, required this.userProfiles});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ImageProvider _getProfileImage(String userId) {
    final profile = widget.userProfiles[userId];
    final profilePic = profile?['profilePic'];
    if (profilePic != null && profilePic.isNotEmpty) {
      return AssetImage(profilePic);
    } else {
      final gender = profile?['gender'] ?? 'male';
      return AssetImage(
        gender == 'male'
            ? 'assets/images/male_pfp.png'
            : 'assets/images/female_pfp.png',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index].data() as Map<String, dynamic>;
        final senderId = message['senderId'] as String?;
        final isMe = senderId == currentUser?.uid;

        return MessageBubble(
          message: message['text'] as String? ?? '',
          isMe: isMe,
          profileImage: _getProfileImage(senderId ?? ''),
          timestamp: message['timestamp'] as Timestamp?,
        );
      },
    );
  }
}
