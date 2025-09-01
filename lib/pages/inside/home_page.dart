import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Your Book My Book',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Be the First to Post !",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            );
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postDoc = posts[index];
              final post = postDoc.data() as Map<String, dynamic>;
              final postOwnerId = post['ownerId'];
              final isMyPost = currentUser != null && currentUser.uid == postOwnerId;

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
                      // Student ID + Department + 3 dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post['studentID'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                post['department'] ?? '',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          if (isMyPost)
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  await FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(postDoc.id)
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Post deleted 🗑️"),
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
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

                      // Book Name
                      Text(
                        post['bookName'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Description
                      Text(
                        post['description'] ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Exchange Type
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: post['exchangeType'] == 'free'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          post['exchangeType'] == 'free'
                              ? "For Free"
                              : "In Exchange for: ${post['exchangeFor'] ?? ''}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: post['exchangeType'] == 'free'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isMyPost ? Colors.grey : Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isMyPost
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Request sent ✅"),
                                    ),
                                  );
                                },
                          child: Text(
                            isMyPost ? "Your Post" : "Request",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
