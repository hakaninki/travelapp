import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/post/services/cloudinary_service.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore; // controller kullanıyor
  final CloudinaryService _cloudinary;
  PostService(this._cloudinary);

  Future<void> createPost({
    required File imageFile,
    required String uid,
    required String username,
    required String description,
    required String location,
  }) async {
    // 1) Görseli Cloudinary'e yükle
    final imageUrl = await _cloudinary.uploadImage(imageFile);

    // 2) Firestore'a yaz (koleksiyon yoksa otomatik oluşur)
    final docRef = _firestore.collection('posts').doc();
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
    print('✅ Firestore write done: posts/${docRef.id}');
  }

  Stream<List<PostModel>> watchPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) {
              final data = d.data();
              return PostModel.fromMap({...data, 'id': data['id'] ?? d.id});
            }).toList());
  }
}
