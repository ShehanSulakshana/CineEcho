import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cine_echo/models/user_feedback.dart';

class FeedbackRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const int _rateLimitMinutes = 5;
  static const int _maxFeedbackPerDay = 10;

  FeedbackRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;
  String? get _userEmail => _auth.currentUser?.email;

  Future<void> _checkRateLimit() async {
    if (_uid == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    final fiveMinutesAgo = now.subtract(Duration(minutes: _rateLimitMinutes));
    final oneDayAgo = now.subtract(Duration(days: 1));

    final recentSnapshot = await _firestore
        .collection('feedback')
        .where('userId', isEqualTo: _uid)
        .where('timestamp', isGreaterThan: fiveMinutesAgo)
        .get();

    if (recentSnapshot.docs.isNotEmpty) {
      throw Exception(
        'Please wait 5 minutes before submitting another feedback',
      );
    }

    final dailySnapshot = await _firestore
        .collection('feedback')
        .where('userId', isEqualTo: _uid)
        .where('timestamp', isGreaterThan: oneDayAgo)
        .get();

    if (dailySnapshot.docs.length >= _maxFeedbackPerDay) {
      throw Exception(
        'Daily feedback limit ($maxFeedbackPerDay) reached. Try again tomorrow.',
      );
    }
  }

  Future<Duration> getTimeUntilNextFeedback() async {
    if (_uid == null) return Duration.zero;

    final now = DateTime.now();
    final fiveMinutesAgo = now.subtract(Duration(minutes: _rateLimitMinutes));

    final snapshot = await _firestore
        .collection('feedback')
        .where('userId', isEqualTo: _uid)
        .where('timestamp', isGreaterThan: fiveMinutesAgo)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return Duration.zero;

    final lastFeedback = snapshot.docs.first;
    final lastTimestamp = (lastFeedback['timestamp'] as Timestamp).toDate();
    final nextAllowed = lastTimestamp.add(Duration(minutes: _rateLimitMinutes));

    if (nextAllowed.isBefore(now)) return Duration.zero;
    return nextAllowed.difference(now);
  }

  Future<void> submitFeedback({
    required String subject,
    required String message,
    required String feedbackType,
    required String userName,
  }) async {
    if (_uid == null) throw Exception('User not authenticated');

    await _checkRateLimit();

    final feedbackDoc = _firestore.collection('feedback').doc();
    final feedback = UserFeedback(
      id: feedbackDoc.id,
      userId: _uid!,
      userName: userName,
      userEmail: _userEmail ?? '',
      subject: subject,
      message: message,
      feedbackType: feedbackType,
      timestamp: DateTime.now(),
    );

    await feedbackDoc.set(feedback.toMap());
  }

  Future<List<UserFeedback>> getUserFeedback() async {
    if (_uid == null) return [];

    final snapshot = await _firestore
        .collection('feedback')
        .where('userId', isEqualTo: _uid)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => UserFeedback.fromSnapshot(doc)).toList();
  }

  static const int maxFeedbackPerDay = _maxFeedbackPerDay;
  static const int rateLimitMinutes = _rateLimitMinutes;
}
