import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String getChatId(String userId1, String userId2) {
    // Sort IDs to ensure consistent chat ID regardless of who initiates
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  static Future<String> createOrGetChat({
    required String otherUserId,
    required String bookName,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final chatId = getChatId(currentUser.uid, otherUserId);
    final chatRef = _firestore.collection('chats').doc(chatId);

    // Create chat if it doesn't exist
    await chatRef.set({
      'participants': [currentUser.uid, otherUserId],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': 'Chat started for book: $bookName',
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Send initial system message if chat is new
    final chatDoc = await chatRef.get();
    if (!chatDoc.exists) {
      await chatRef.collection('messages').add({
        'senderId': 'system',
        'text': 'Chat started for book: $bookName',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  static Stream<QuerySnapshot> getChatList() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return const Stream.empty();

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastUpdated', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getMessages(String chatId) {
  return _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots();
}

  static Future<void> sendMessage({
    required String chatId,
    required String text,
    required String otherUserId,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final chatRef = _firestore.collection('chats').doc(chatId);
    final messagesRef = chatRef.collection('messages');

    try {
      // Ensure chat document exists and has correct participants
      final chatDoc = await chatRef.get();
      if (!chatDoc.exists) {
        await chatRef.set({
          'participants': [currentUser.uid, otherUserId],
          'lastMessage': '',
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        final data = chatDoc.data() as Map<String, dynamic>;
        final participants = List<String>.from(data['participants'] ?? []);
        if (!participants.contains(currentUser.uid) || !participants.contains(otherUserId)) {
          await chatRef.update({
            'participants': [currentUser.uid, otherUserId],
          });
        }
      }

      // Add the message
      await messagesRef.add({
        'senderId': currentUser.uid,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update chat metadata
      await chatRef.update({
        'lastMessage': text,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<DocumentSnapshot> getUserProfile(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }

  static Future<List<DocumentSnapshot>> getUserProfiles(List<String> userIds) {
    return _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: userIds)
        .get()
        .then((snapshot) => snapshot.docs);
  }
}
