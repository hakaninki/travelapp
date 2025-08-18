// lib/features/notifications/services/notifications_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/features/notifications/models/notification_model.dart';

class NotificationsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// SADECE kendi yolundan oku: notifications/{me}/items
  Stream<List<AppNotification>> watchMyNotifications({int limit = 100}) {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    final col = _db.collection('notifications').doc(uid).collection('items');

    return col
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(AppNotification.fromDoc).toList());
  }

  Future<void> markAsRead(String notifId) async {
    final uid = _uid;
    if (uid == null) return;

    final ref =
        _db.collection('notifications').doc(uid).collection('items').doc(notifId);

    await ref.update({'read': true});
    // ignore: avoid_print
    print('DEBUG notif: markAsRead uid=$uid notifId=$notifId');
  }

  // -------------------- CREATE HELPERS --------------------

  Future<void> createLikeNotificationByPostId({
    required String postId,
    required String fromUid,
    String? fromUsername,
    String? fromPhotoUrl,
  }) async {
    final postSnap = await _db.collection('posts').doc(postId).get();
    final ownerUid = (postSnap.data() ?? {})['uid'] as String?;
    // ignore: avoid_print
    print('DEBUG notif.like: postId=$postId owner=$ownerUid from=$fromUid');

    if (ownerUid == null || ownerUid.isEmpty || ownerUid == fromUid) {
      // ignore: avoid_print
      print('DEBUG notif.like: skip (invalid owner/self-like)');
      return;
    }

    final payload = <String, dynamic>{
      'type': 'like',
      'fromUid': fromUid,
      if (fromUsername != null) 'fromUsername': fromUsername,
      if (fromPhotoUrl != null) 'fromPhotoUrl': fromPhotoUrl,
      'postId': postId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // ignore: avoid_print
    print('DEBUG notif.like: write -> notifications/$ownerUid/items payload=$payload');

    await _db.collection('notifications').doc(ownerUid).collection('items').add(payload);
  }

  Future<void> createCommentNotificationByPostId({
    required String postId,
    required String fromUid,
    String? fromUsername,
    String? fromPhotoUrl,
    String? commentId,
  }) async {
    final postSnap = await _db.collection('posts').doc(postId).get();
    final ownerUid = (postSnap.data() ?? {})['uid'] as String?;
    // ignore: avoid_print
    print('DEBUG notif.comment: postId=$postId owner=$ownerUid from=$fromUid');

    if (ownerUid == null || ownerUid.isEmpty || ownerUid == fromUid) {
      // ignore: avoid_print
      print('DEBUG notif.comment: skip (invalid owner/self-comment)');
      return;
    }

    // Yorum metnini (varsa) çek → payload'a kısa önizleme ekle
    String? commentText;
    if (commentId != null && commentId.isNotEmpty) {
      try {
        final cSnap = await _db
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .get();
        final txt = (cSnap.data() ?? {})['text'];
        if (txt is String && txt.trim().isNotEmpty) {
          final t = txt.trim();
          commentText = t.length <= 140 ? t : '${t.substring(0, 140)}…';
        }
      } catch (e) {
        // ignore: avoid_print
        print('DEBUG notif.comment: failed to fetch comment text: $e');
      }
    }

    final payload = <String, dynamic>{
      'type': 'comment',
      'fromUid': fromUid,
      if (fromUsername != null) 'fromUsername': fromUsername,
      if (fromPhotoUrl != null) 'fromPhotoUrl': fromPhotoUrl,
      'postId': postId,
      if (commentId != null) 'commentId': commentId,
      if (commentText != null) 'commentText': commentText,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // ignore: avoid_print
    print('DEBUG notif.comment: write -> notifications/$ownerUid/items payload=$payload');

    await _db.collection('notifications').doc(ownerUid).collection('items').add(payload);
  }

  Future<void> createFollowNotification({
    required String targetUid,
    required String fromUid,
    String? fromUsername,
    String? fromPhotoUrl,
  }) async {
    // ignore: avoid_print
    print('DEBUG notif.follow: target=$targetUid from=$fromUid');

    if (targetUid.isEmpty || targetUid == fromUid) {
      // ignore: avoid_print
      print('DEBUG notif.follow: skip (invalid target/self-follow)');
      return;
    }

    final payload = <String, dynamic>{
      'type': 'follow',
      'fromUid': fromUid,
      if (fromUsername != null) 'fromUsername': fromUsername,
      if (fromPhotoUrl != null) 'fromPhotoUrl': fromPhotoUrl,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // ignore: avoid_print
    print('DEBUG notif.follow: write -> notifications/$targetUid/items payload=$payload');

    await _db.collection('notifications').doc(targetUid).collection('items').add(payload);
  }
}
