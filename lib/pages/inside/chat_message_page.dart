import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessagesPage extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatMessagesPage({super.key, required this.chatId, required this.otherUserId});

  @override
  State<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  void sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');

    await messagesRef.add({
      'senderId': currentUser!.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update last message and timestamp in chat doc
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
      'lastMessage': text,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.otherUserId}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Colors.green));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == currentUser!.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green.withOpacity(0.8) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
