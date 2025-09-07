import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Stream<QuerySnapshot> getPostsStream([String? department]) {
    var query = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true);

    if (department != null) {
      query = query.where('department', isEqualTo: department);
    }

    return query.snapshots();
  }

  static Stream<QuerySnapshot> getRequestsForPost(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getPendingRequestsFromUser(String userId, String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('requests')
        .where('requesterId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  static Future<void> sendRequest(String postId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final studentID = currentUser.email?.split('@')[0] ?? "Unknown";

    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('requests')
        .add({
          'requesterId': currentUser.uid,
          'requesterStudentID': studentID,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  static Future<void> deletePost(String postId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final postRef = _firestore.collection('posts').doc(postId);
    final post = await postRef.get();
    
    if (post.exists && post.data()?['ownerId'] == currentUser.uid) {
      await postRef.delete();
    } else {
      throw Exception('Unauthorized to delete this post');
    }
  }

  static Future<void> cancelRequest(String postId, String requestId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('requests')
        .doc(requestId)
        .delete();
  }
}
