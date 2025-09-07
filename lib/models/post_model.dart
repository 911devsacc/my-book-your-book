import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String ownerId;
  final String studentId;
  final String bookName;
  final String description;
  final String exchangeType;
  final String? exchangeFor;
  final String department;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.ownerId,
    required this.studentId,
    required this.bookName,
    required this.description,
    required this.exchangeType,
    this.exchangeFor,
    required this.department,
    required this.createdAt,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      ownerId: data['ownerId'] as String,
      studentId: data['studentID'] as String,
      bookName: data['bookName'] as String,
      description: data['description'] as String,
      exchangeType: data['exchangeType'] as String,
      exchangeFor: data['exchangeFor'] as String?,
      department: data['department'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'studentID': studentId,
      'bookName': bookName,
      'description': description,
      'exchangeType': exchangeType,
      'exchangeFor': exchangeFor,
      'department': department,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
