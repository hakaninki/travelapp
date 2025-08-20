// lib/features/post/application/like_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';
import 'package:travel_app/features/notifications/providers/notifications_provider.dart';

class LikeController {
  LikeController(this._ref);
  final Ref _ref;

  /// Toggle like ve eğer yeni durum "liked" ise bildirim oluştur.
  Future<void> toggle(String postId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not signed in');

    final likeSvc = _ref.read(likeServiceProvider);

    // 1) Toggle öncesi mevcut durum
    final wasLiked = await likeSvc.isLikedOnce(postId: postId, userId: uid);

    // 2) Toggle işlemi
    await likeSvc.toggleLike(postId: postId, userId: uid);

    // 3) Yeni durum: like olduysa (yani önceden like DEĞİLDİ)
    if (!wasLiked) {
      // Bildirim (try/catch ile sessiz hata)
      try {
        // Kullanıcı adı / foto isteğe bağlı; notification servisi sadece fromUid ile de çalışır.
        await _ref.read(notificationsServiceProvider).createLikeNotificationByPostId(
              postId: postId,
              fromUid: uid,
            );
        // ignore: avoid_print
        print('DEBUG notif.like: created for post=$postId by=$uid');
      } catch (e) {
        // ignore: avoid_print
        print('DEBUG notif.like: failed (ignored): $e');
      }
    }
  }
}

final likeControllerProvider = Provider<LikeController>((ref) {
  return LikeController(ref);
});
