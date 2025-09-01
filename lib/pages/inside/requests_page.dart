import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Requests',
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
            .where('ownerId', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, postSnapshot) {
          if (postSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          final posts = postSnapshot.data?.docs ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_email_read, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    "No Request",
                    style: TextStyle(color: Colors.green, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          // Use a StreamBuilder for each post and merge results
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _getAllRequests(posts),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                );
              }

              final allRequests = snapshot.data!;

              if (allRequests.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mark_email_read, size: 64, color: Colors.green),
                      SizedBox(height: 16),
                      Text(
                        "No Request",
                        style: TextStyle(color: Colors.green, fontSize: 18),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: allRequests.length,
                itemBuilder: (context, index) {
                  final req = allRequests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: RichText(
                        text: TextSpan(
                          style:
                              const TextStyle(fontSize: 16, color: Colors.black),
                          children: [
                            TextSpan(text: "${req['requesterStudentID']} requested "),
                            TextSpan(
                              text: req['bookName'],
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: req['status'] == "pending"
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(req['postId'])
                                        .collection('requests')
                                        .doc(req['requestId'])
                                        .update({'status': 'accepted'});
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(req['postId'])
                                        .collection('requests')
                                        .doc(req['requestId'])
                                        .update({'status': 'rejected'});
                                  },
                                ),
                              ],
                            )
                          : Text(
                              req['status'].toUpperCase(),
                              style: TextStyle(
                                color: req['status'] == "accepted"
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  Future<List<Map<String, dynamic>>> _getAllRequests(List<QueryDocumentSnapshot> posts) async {
    List<Map<String, dynamic>> allRequests = [];

    for (var post in posts) {
      final postId = post.id;
      final bookName = post['bookName'] ?? '';

      final requestSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('requests')
          .get();

      for (var req in requestSnapshot.docs) {
        final data = req.data();
        allRequests.add({
          'requestId': req.id,
          'postId': postId,
          'bookName': bookName,
          'requesterStudentID': data['requesterStudentID'] ?? 'Unknown',
          'status': data['status'] ?? 'pending',
        });
      }
    }

    return allRequests;
  }
}
