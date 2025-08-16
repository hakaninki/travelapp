import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/core/constants/app_collection.dart';
import 'package:travel_app/core/models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _postRef(String postId) =>
      _firestore.collection(AppCollections.posts).doc(postId);

  CollectionReference<Map<String, dynamic>> _commentsCol(String postId) =>
      _postRef(postId).collection(AppCollections.comments);

  /// Yorum ekle (post dokümanına dokunmuyoruz)
  Future<void> addComment({
    required String postId,
    required String userId,
    required String username,
    String? photoUrl,
    required String text,
  }) async {
    final docRef = _commentsCol(postId).doc();
    await docRef.set({
      'userId': userId,
      'username': username,
      if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Yorum stream
  Stream<List<CommentModel>> watchComments(String postId) {
    return _commentsCol(postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CommentModel.fromFirestore(d.id, d.data())).toList());
  }

  /// Yorum sil (post dokümanına dokunmuyoruz)
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    await _commentsCol(postId).doc(commentId).delete();
  }
}
