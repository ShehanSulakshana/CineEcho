import 'package:cloud_firestore/cloud_firestore.dart';

class UserFeedback {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String subject;
  final String message;
  final String feedbackType;
  final DateTime timestamp;

  UserFeedback({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.subject,
    required this.message,
    required this.feedbackType,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'subject': subject,
      'message': message,
      'feedbackType': feedbackType,
      'timestamp': timestamp,
    };
  }

  factory UserFeedback.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserFeedback(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userEmail: data['userEmail'] ?? '',
      subject: data['subject'] ?? '',
      message: data['message'] ?? '',
      feedbackType: data['feedbackType'] ?? 'general',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
