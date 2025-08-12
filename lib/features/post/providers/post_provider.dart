import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/post/services/cloudinary_service.dart';
import 'package:travel_app/features/post/services/post_service.dart';
import 'package:travel_app/features/post/application/add_post_controller.dart';
import 'package:travel_app/features/post/application/add_post_state.dart';

final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService(
    cloudName: 'dt3ojv1nj',          // <— senin cloud name
    uploadPreset: 'unsigned_preset', // <— preset adı
  );
});

final postServiceProvider = Provider<PostService>((ref) {
  final cloud = ref.read(cloudinaryServiceProvider);
  return PostService(cloud);
});

final postsStreamProvider = StreamProvider<List<PostModel>>((ref) {
  return ref.read(postServiceProvider).watchPosts();
});
final postProvider = postsStreamProvider;

final addPostControllerProvider =
    StateNotifierProvider<AddPostController, AddPostState>(
  (ref) => AddPostController(ref),
);
