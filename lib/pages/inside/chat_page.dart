import 'package:my_book_your_book/pages/inside/chat_message_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      // If more than a week ago, show date
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      // If within a week, show days ago
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      // If within a day, show hours ago
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      // If within an hour, show minutes ago
      return '${difference.inMinutes}m ago';
    } else {
      // If less than a minute ago
      return 'Just now';
    }
  }

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
          print('Chat stream update:');
          print('Connection state: ${snapshot.connectionState}');
          print('Has error: ${snapshot.hasError}');
          print('Error: ${snapshot.error}');
          print('Has data: ${snapshot.hasData}');
          if (snapshot.hasData) {
            print('Number of chats: ${snapshot.data!.docs.length}');
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              print('Chat ${doc.id}:');
              print('  participants: ${data['participants']}');
              print('  lastMessage: ${data['lastMessage']}');
              print('  lastUpdated: ${data['lastUpdated']}');
            }
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              
              // Safety check for participants
              if (chat['participants'] == null || chat['participants'] is! List || (chat['participants'] as List).isEmpty) {
                print('Invalid chat document ${chats[index].id}: Missing or invalid participants');
                return const SizedBox(); // Skip invalid chats
              }

              late String otherUserId;
              try {
                final participants = chat['participants'] as List;
                otherUserId = participants.firstWhere(
                  (id) => id != currentUser.uid,
                  orElse: () => 'deleted',
                ) as String;
              } catch (e) {
                print('Error finding other user in chat ${chats[index].id}: $e');
                return const SizedBox(); // Skip chats with errors
              }

              if (otherUserId == 'deleted') {
                print('Could not find other user in chat ${chats[index].id}');
                return const SizedBox(); // Skip chats where we can't find the other user
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  Widget leading = const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person),
                  );
                  String displayName = 'Deleted User';
                  bool userExists = false;

                  if (userSnapshot.hasError) {
                    print('Error loading user $otherUserId: ${userSnapshot.error}');
                  }

                  if (userSnapshot.hasData) {
                    if (!userSnapshot.data!.exists) {
                      print('User $otherUserId does not exist');
                    } else {
                      userExists = true;
                      final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                      displayName = userData['studentId'] ?? otherUserId;
                      final profilePic = userData['profilePic'];
                      final gender = userData['gender'] ?? 'male';
                      if (profilePic != null && profilePic.isNotEmpty) {
                        leading = CircleAvatar(
                          backgroundImage: AssetImage(profilePic),
                        );
                      } else {
                        leading = CircleAvatar(
                          backgroundImage: AssetImage(
                            gender == 'male'
                                ? 'assets/images/male_pfp.png'
                                : 'assets/images/female_pfp.png',
                          ),
                        );
                      }
                    }
                  }

                  final lastMessage = chat['lastMessage'] ?? '';
                  final lastUpdated = chat['lastUpdated'] as Timestamp?;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: leading,
                      title: Text(
                        displayName,
                        style: TextStyle(
                          color: userExists ? Colors.black : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(lastMessage),
                          if (lastUpdated != null)
                            Text(
                              _formatTimestamp(lastUpdated),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatMessagesPage(
                              chatId: chats[index].id,
                              otherUserId: otherUserId,
                              otherUserDisplayName: displayName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
