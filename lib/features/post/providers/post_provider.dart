import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/constants/app_config.dart';
import 'package:travel_app/features/post/services/cloudinary_service.dart';
import 'package:travel_app/features/post/services/post_service.dart';
import 'package:travel_app/features/post/services/like_service.dart';
import 'package:travel_app/features/post/services/comment_service.dart';

/// Config
final appConfigProvider = Provider<AppConfig>((ref) => const AppConfig());

/// Cloudinary
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  final cfg = ref.watch(appConfigProvider);
  return CloudinaryService(
    cloudName: cfg.cloudName,
    uploadPreset: cfg.uploadPreset,
  );
});

/// Services
final postServiceProvider = Provider<PostService>((ref) {
  final cloud = ref.watch(cloudinaryServiceProvider);
  return PostService(cloud);
});
final likeServiceProvider = Provider<LikeService>((ref) => LikeService());
final commentServiceProvider = Provider<CommentService>((ref) => CommentService());
