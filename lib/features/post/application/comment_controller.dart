import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';
import 'package:travel_app/core/constants/app_collection.dart';

class CommentController {
  CommentController(this._ref);
  final Ref _ref;

  Future<void> add({
    required String postId,
    required String text,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not signed in');

    // username'i users/{uid} üzerinden al
    final userDoc = await FirebaseFirestore.instance
        .collection(AppCollections.users)
        .doc(user.uid)
        .get();
    final username = userDoc.data()?['username'] ?? (user.displayName ?? 'user');
    final profilePhoto = userDoc.data()?['photoUrl'] ?? user.photoURL;

    // Yalnızca yorum ekle — post dokümanında commentCount güncellemesi YOK
    await _ref.read(commentServiceProvider).addComment(
          postId: postId,
          userId: user.uid,
          username: username,
          photoUrl: profilePhoto,
          text: text,
        );
  }

  Future<void> delete({
    required String postId,
    required String commentId,
  }) async {
    // Yalnızca yorumu sil — post dokümanında commentCount güncellemesi YOK
    await _ref.read(commentServiceProvider).deleteComment(
          postId: postId,
          commentId: commentId,
        );
  }
}

final commentControllerProvider = Provider<CommentController>((ref) {
  return CommentController(ref);
});
