import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/constants/app_collection.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';
import 'package:travel_app/features/notifications/providers/notifications_provider.dart';

class LikeController {
  LikeController(this._ref);
  final Ref _ref;

  Future<void> toggle(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not signed in');

    final isLiked = await _ref
        .read(likeServiceProvider)
        .toggleLike(postId: postId, userId: user.uid);

    // Sadece LIKE olduğunda bildirim yaz (UNLIKE'ta yazma)
    if (isLiked) {
      // username / photoUrl çek
      final userDoc = await FirebaseFirestore.instance
          .collection(AppCollections.users)
          .doc(user.uid)
          .get();
      final username =
          userDoc.data()?['username'] ?? (user.displayName ?? 'user');
      final photoUrl = userDoc.data()?['photoUrl'] ?? user.photoURL;

      await _ref.read(notificationsServiceProvider).createLikeNotificationByPostId(
            postId: postId,
            fromUid: user.uid,
            fromUsername: username,
            fromPhotoUrl: photoUrl,
          );
    }
  }
}

final likeControllerProvider = Provider<LikeController>((ref) {
  return LikeController(ref);
});
