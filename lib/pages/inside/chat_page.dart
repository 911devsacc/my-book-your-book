import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUser!.uid)
            .orderBy('lastUpdated', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    "No Chats",
                    style: TextStyle(color: Colors.green, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              final otherUserId = (chat['participants'] as List)
                  .firstWhere((id) => id != currentUser.uid);

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text("Chat with $otherUserId"), // You can fetch username from users collection
                subtitle: Text(chat['lastMessage'] ?? ''),
                onTap: () {
                  // TODO: Navigate to chat messages screen
                },
              );
            },
          );
        },
      ),
    );
  }
}
