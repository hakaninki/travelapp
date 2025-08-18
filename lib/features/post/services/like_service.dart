import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/core/constants/app_collection.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _postRef(String postId) =>
      _firestore.collection(AppCollections.posts).doc(postId);

  CollectionReference<Map<String, dynamic>> _likesCol(String postId) =>
      _postRef(postId).collection(AppCollections.likes);

  /// Like/Unlike -> true dönerse LIKE yapıldı, false dönerse UNLIKE yapıldı.
  Future<bool> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final likeDoc = _likesCol(postId).doc(userId);
    final snap = await likeDoc.get();

    if (snap.exists) {
      await likeDoc.delete(); // unlike
      return false;
    } else {
      await likeDoc.set({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      }); // like
      return true;
    }
  }

  Stream<int> likeCountStream(String postId) {
    return _likesCol(postId).snapshots().map((s) => s.size);
  }

  Stream<bool> isLikedByUserStream({
    required String postId,
    required String userId,
  }) {
    return _likesCol(postId).doc(userId).snapshots().map((s) => s.exists);
  }

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
