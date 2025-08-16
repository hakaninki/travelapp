import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/core/constants/app_collection.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/post/services/cloudinary_service.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinary;

  PostService(this._cloudinary);

  DocumentReference<Map<String, dynamic>> _postRef(String postId) =>
      _firestore.collection(AppCollections.posts).doc(postId);

  /// Yeni post oluştur
  Future<void> createPost({
    required File imageFile,
    required String uid,
    required String username,
    required String description,
    required String location,
  }) async {
    final imageUrl = await _cloudinary.uploadImage(imageFile);
    final docRef = _firestore.collection(AppCollections.posts).doc();

    final post = PostModel(
      id: docRef.id,
      uid: uid,
      username: username,
      description: description,
      imageUrl: imageUrl,
      location: location,
      createdAt: DateTime.now(),
    );

    await docRef.set({
      ...post.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Post feed akışı (tüm kullanıcılar)
  Stream<List<PostModel>> watchPosts() {
    return _firestore
        .collection(AppCollections.posts)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return PostModel.fromMap({...data, 'id': doc.id});
            }).toList());
  }

  /// Belirli kullanıcının postları
  Stream<List<PostModel>> watchPostsByUser(String uid) {
    return _firestore
        .collection(AppCollections.posts)
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return PostModel.fromMap({...data, 'id': doc.id});
            }).toList());
  }
}
