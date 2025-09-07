import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_book_your_book/models/user_data.dart';
import 'package:my_book_your_book/pages/inside/chat_message_page.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> with SingleTickerProviderStateMixin {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late final TabController _tabController;
  final Map<String, UserData> _userDataCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<UserData> _getUserData(String userId) async {
    if (_userDataCache.containsKey(userId)) {
      return _userDataCache[userId]!;
    }

    final doc = await _db.collection('users').doc(userId).get();
    final userData = UserData.fromMap(doc.data());
    _userDataCache[userId] = userData;
    return userData;
  }

  ImageProvider _getProfileImage(UserData userData) {
    if (userData.profilePic.isNotEmpty) {
      return AssetImage(userData.profilePic);
    }
    return AssetImage(
      userData.gender == 'male'
          ? 'assets/images/male_pfp.png'
          : 'assets/images/female_pfp.png',
    );
  }

  Future<String?> _findExistingChat(String requesterId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final chatQuery = await _db
        .collection('chats')
        .where('participants', arrayContainsAny: [currentUser.uid])
        .get();

    for (var doc in chatQuery.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.length == 2 &&
          participants.contains(requesterId) &&
          participants.contains(currentUser.uid)) {
        return doc.id;
      }
    }
    return null;
  }

  Future<void> _acceptRequest(
    String postId,
    Map<String, dynamic> request,
    String requestDocId,
    BuildContext context,
  ) async {
    if (!context.mounted) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to accept requests'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final requesterId = request['requesterId'] as String?;
      if (requesterId == null || requesterId.isEmpty) {
        throw 'Invalid requester ID';
      }

      // First check if chat exists
      final existingChatId = await _findExistingChat(requesterId);
      String finalChatId;

      // First verify the request status outside transaction
      final requestRef = _db
          .collection('posts')
          .doc(postId)
          .collection('requests')
          .doc(requestDocId);
      
      final requestSnapshot = await requestRef.get();
      if (!requestSnapshot.exists) {
        throw 'Request no longer exists';
      }
      if (requestSnapshot.data()?['status'] != 'pending') {
        throw 'Request is no longer pending';
      }

      // If chat exists, just update request status
      if (existingChatId != null) {
        await requestRef.update({'status': 'accepted'});
        finalChatId = existingChatId;
      } else {
        // Create new chat
        final newChatId = _db.collection('chats').doc().id;
        final chatRef = _db.collection('chats').doc(newChatId);
        
        // Use transaction for atomic operations
        await _db.runTransaction((transaction) async {
          // Set chat data first
          transaction.set(chatRef, {
            'participants': [currentUser.uid, requesterId],
            'lastMessage': '',
            'lastUpdated': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Update request status
          transaction.update(requestRef, {'status': 'accepted'});
        });

        finalChatId = newChatId;
      }

      if (!context.mounted) return;

      // Get requester display name
      final userDoc = await _db.collection('users').doc(requesterId).get();
      final requesterDisplayName = userDoc.exists
          ? (userDoc.data()?['studentId'] ?? requesterId)
          : requesterId;

      if (!context.mounted) return;

      // Navigate to chat
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatMessagesPage(
            chatId: finalChatId,
            otherUserId: requesterId,
            otherUserDisplayName: requesterDisplayName,
          ),
        ),
      );
    } catch (e) {
      print('Error in request acceptance process: $e');
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Requests',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // RECEIVED REQUESTS
          StreamBuilder<QuerySnapshot>(
            stream: _db
                .collection('posts')
                .where('ownerId', isEqualTo: currentUser?.uid)
                .snapshots(),
            builder: (context, postSnapshot) {
              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                );
              }
              if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No received requests",
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                );
              }

              final posts = postSnapshot.data!.docs;
              return ListView(
                padding: const EdgeInsets.all(12),
                children: posts.map((postDoc) {
                  final post = postDoc.data() as Map<String, dynamic>;
                  final postId = postDoc.id;
                  final bookName = post['bookName'] ?? '';

                  return StreamBuilder<QuerySnapshot>(
                    stream: _db
                        .collection('posts')
                        .doc(postId)
                        .collection('requests')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, requestSnapshot) {
                      if (!requestSnapshot.hasData ||
                          requestSnapshot.data!.docs.isEmpty) {
                        return const SizedBox();
                      }

                      final requests = requestSnapshot.data!.docs;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: requests.map((requestDoc) {
                          final request =
                              requestDoc.data() as Map<String, dynamic>;
                          final requesterId = request['requesterId'] ?? '';
                          final requesterName =
                              request['requesterStudentID'] ?? 'Unknown';
                          final status = request['status'] ?? 'pending';

                          return FutureBuilder<UserData>(
                            future: _getUserData(requesterId),
                            builder: (context, snapshot) {
                              final userData = snapshot.data ??
                                  const UserData(
                                    profilePic: '',
                                    gender: 'male',
                                  );
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: _getProfileImage(userData),
                                  ),
                                  title: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "$requesterName ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(text: "from "),
                                        TextSpan(
                                          text: "${request['department']} ",
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(text: "requested "),
                                        TextSpan(
                                          text: bookName,
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: status == "pending"
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              ),
                                              onPressed: () => _acceptRequest(
                                                postId,
                                                request,
                                                requestDoc.id,
                                                context,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                              onPressed: () async {
                                                await _db
                                                    .collection('posts')
                                                    .doc(postId)
                                                    .collection('requests')
                                                    .doc(requestDoc.id)
                                                    .update({
                                                      'status': 'rejected',
                                                    });
                                              },
                                            ),
                                          ],
                                        )
                                      : Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            color: status == "accepted"
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),

          // SENT REQUESTS
          StreamBuilder<QuerySnapshot>(
            stream: (() {
              print(
                "Setting up sent requests query for user: ${currentUser?.uid}",
              );
              return _db
                  .collectionGroup('requests')
                  .where('requesterId', isEqualTo: currentUser?.uid)
                  .where('status', whereIn: ['pending', 'accepted', 'rejected'])
                  .orderBy('createdAt', descending: true)
                  .snapshots();
            })(),
            builder: (context, requestSnapshot) {
              if (requestSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                );
              }

              if (requestSnapshot.hasError) {
                print("Error fetching sent requests: ${requestSnapshot.error}");
                return Center(
                  child: Text(
                    "Error loading requests: ${requestSnapshot.error}",
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ),
                );
              }

              if (!requestSnapshot.hasData ||
                  requestSnapshot.data!.docs.isEmpty) {
                print("Current user ID: ${currentUser?.uid}");
                return const Center(
                  child: Text(
                    "No sent requests",
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                );
              }

              final requests = requestSnapshot.data!.docs;

              return ListView(
                padding: const EdgeInsets.all(12),
                children: requests.map((requestDoc) {
                  final request = requestDoc.data() as Map<String, dynamic>;
                  final status = request['status'] ?? 'pending';
                  final postRef = requestDoc.reference.parent.parent;

                  return FutureBuilder<DocumentSnapshot>(
                    future: postRef!.get(),
                    builder: (context, postSnapshot) {
                      if (!postSnapshot.hasData) return const SizedBox();

                      final post =
                          postSnapshot.data!.data() as Map<String, dynamic>?;
                      final bookName = post?['bookName'] ?? 'Unknown';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: [
                                const TextSpan(text: "You requested "),
                                TextSpan(
                                  text: bookName,
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: status == "pending"
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Cancel Request',
                                  onPressed: () async {
                                    try {
                                      await requestDoc.reference.delete();
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Request cancelled successfully',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      print('Error cancelling request: $e');
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error cancelling request: $e',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                )
                              : Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    color: status == "accepted"
                                        ? Colors.green
                                        : status == "rejected"
                                            ? Colors.red
                                            : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
