import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Stream<QuerySnapshot> getPosts({String? department}) {
    Query query = _db.collection('posts').orderBy('createdAt', descending: true);
    
    if (department != null) {
      query = query.where('department', isEqualTo: department);
    }
    
    return query.snapshots();
  }

  static Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }

  static Future<void> createPost({
    required String bookName,
    required String description,
    required String faculty,
    required String department,
    required String exchangeType,
    String? exchangeFor,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final studentID = user.email?.split("@")[0];
    if (studentID == null) throw Exception('Invalid email format');

    await _db.collection('posts').add({
      "ownerId": user.uid,
      "studentID": studentID,
      "bookName": bookName.trim(),
      "description": description.trim(),
      "faculty": faculty,
      "department": department,
      "exchangeType": exchangeType,
      "exchangeFor": exchangeType == "exchange" ? exchangeFor?.trim() : null,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  static Future<void> sendRequest(String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final studentID = user.email?.split('@')[0];
    if (studentID == null) throw Exception('Invalid email format');

    // Get post data first
    final postDoc = await _db.collection('posts').doc(postId).get();
    final postData = postDoc.data()!;

    await _db
        .collection('posts')
        .doc(postId)
        .collection('requests')
        .add({
          'requesterId': user.uid,
          'requesterStudentID': studentID,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'postOwnerId': postData['ownerId'],
          'faculty': postData['faculty'],
          'department': postData['department'],
          'bookName': postData['bookName'],
        });
  }

  static Stream<QuerySnapshot> getPostRequests(String postId, String userId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('requests')
        .where('requesterId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  static Stream<QuerySnapshot> getRequests({
    required String userId,
    required bool isReceived,
    String? department,
  }) {
    Query query = _db.collectionGroup('requests');
    
    if (isReceived) {
      // Get requests for posts where I'm the owner
      query = query.where('postOwnerId', isEqualTo: userId);
    } else {
      // Get requests I sent
      query = query.where('requesterId', isEqualTo: userId);
    }

    if (department != null) {
      query = query.where('department', isEqualTo: department);
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  static Future<void> updateRequestStatus(String postId, String requestId, String status) async {
    await _db
        .collection('posts')
        .doc(postId)
        .collection('requests')
        .doc(requestId)
        .update({'status': status});
  }
}
