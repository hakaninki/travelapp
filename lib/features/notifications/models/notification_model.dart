// lib/features/notifications/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum AppNotificationType { like, comment, follow }

AppNotificationType _parseType(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'like':
      return AppNotificationType.like;
    case 'comment':
      return AppNotificationType.comment;
    case 'follow':
      return AppNotificationType.follow;
    default:
      return AppNotificationType.comment;
  }
}

class AppNotification {
  final String id;
  final AppNotificationType type;
  final String fromUid;
  final String? fromUsername;
  final String? fromPhotoUrl;
  final String? postId;
  final String? commentId;
  final String? commentText; // 👈 NEW
  final bool read;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.fromUid,
    this.fromUsername,
    this.fromPhotoUrl,
    this.postId,
    this.commentId,
    this.commentText, // 👈 NEW
    required this.read,
    this.createdAt,
  });

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    final ts = m['createdAt'];
    DateTime? created;
    if (ts is Timestamp) created = ts.toDate();

    return AppNotification(
      id: d.id,
      type: _parseType(m['type'] as String?),
      fromUid: (m['fromUid'] ?? '') as String,
      fromUsername: m['fromUsername'] as String?,
      fromPhotoUrl: m['fromPhotoUrl'] as String?,
      postId: m['postId'] as String?,
      commentId: m['commentId'] as String?,
      commentText: m['commentText'] as String?, // 👈 NEW
      read: (m['read'] ?? false) as bool,
      createdAt: created,
    );
  }
}
