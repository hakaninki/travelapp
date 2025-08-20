// lib/features/post/services/like_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/core/constants/app_collection.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _postRef(String postId) =>
      _firestore.collection(AppCollections.posts).doc(postId);

  CollectionReference<Map<String, dynamic>> _likesCol(String postId) =>
      _postRef(postId).collection(AppCollections.likes);

  /// Like/Unlike (post dokümanını güncellemiyoruz)
  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final likeDoc = _likesCol(postId).doc(userId);
    final snap = await likeDoc.get();

    if (snap.exists) {
      await likeDoc.delete(); // unlike
    } else {
      await likeDoc.set({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      }); // like
    }
  }

  /// Like sayısı: alt koleksiyon boyutu
  Stream<int> likeCountStream(String postId) {
    return _likesCol(postId).snapshots().map((s) => s.size);
  }

  /// Bu kullanıcı beğenmiş mi? (stream)
  Stream<bool> isLikedByUserStream({
    required String postId,
    required String userId,
  }) {
    return _likesCol(postId).doc(userId).snapshots().map((s) => s.exists);
  }

  /// 🔹 Tek seferlik "şu an liked mı?" kontrolü (bildirim için)
  Future<bool> isLikedOnce({
    required String postId,
    required String userId,
  }) async {
    final snap = await _likesCol(postId).doc(userId).get();
    return snap.exists;
  }

  /// Liker ID listesi
  Future<List<String>> getLikerIds({
    required String postId,
    int limit = 30,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> q =
        _likesCol(postId).orderBy('createdAt', descending: true).limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final res = await q.get();
    return res.docs.map((d) => d.id).toList();
  }
}
