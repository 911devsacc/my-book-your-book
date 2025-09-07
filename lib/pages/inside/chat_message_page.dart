import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/chat_service.dart';
import '../../widgets/message_input.dart';
import '../../widgets/message_list.dart';

class ChatMessagesPage extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserDisplayName;

  const ChatMessagesPage({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserDisplayName,
  });

  @override
  State<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  Map<String, Map<String, String>> _userProfiles = {};

  @override
  void initState() {
    super.initState();
    _loadUserProfiles();
  }

  Future<void> _loadUserProfiles() async {
    try {
      final profiles = await ChatService.getUserProfiles([currentUser!.uid, widget.otherUserId]);
      setState(() {
        for (var doc in profiles) {
          final data = doc.data() as Map<String, dynamic>;
          _userProfiles[doc.id] = {
            'profilePic': data['profilePic'] ?? '',
            'gender': data['gender'] ?? 'male',
          };
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profiles: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserDisplayName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: ChatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data?.docs ?? [];
                
                // Sort messages in the correct order for display
                final reversedMessages = messages.reversed.toList();
                
                return MessageList(
                  messages: reversedMessages,
                  userProfiles: _userProfiles,
                );
              },
            ),
          ),
          MessageInput(
            controller: _messageController,
            onSend: () async {
              final text = _messageController.text.trim();
              if (text.isEmpty) return;

              try {
                await ChatService.sendMessage(
                  chatId: widget.chatId,
                  otherUserId: widget.otherUserId,
                  text: text,
                );
                _messageController.clear();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error sending message: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}