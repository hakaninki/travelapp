import 'package:flutter/material.dart';
import 'package:travel_app/features/home/widgets/post_card_components/location_info.dart';
import 'package:travel_app/features/home/widgets/post_card_components/post_actions_info.dart';
import 'package:travel_app/features/home/widgets/post_card_components/post_description.dart';
import 'package:travel_app/features/home/widgets/post_card_components/user_info.dart';
import 'package:travel_app/core/models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Material(
        elevation: 3.0,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 Kullanıcı bilgisi (Riverpod ile)
              UserInfoRow(
                uid: post.uid,
                fallbackUsername: post.username,
              ),

              const SizedBox(height: 5),

              // 📍 Konum
              LocationInfoRow(location: post.location),

              const SizedBox(height: 5),

              // 🖼 Görsel
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.zero),
                child: Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (c, w, progress) =>
                      progress == null
                          ? w
                          : const AspectRatio(
                              aspectRatio: 4 / 3,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                  errorBuilder: (c, e, s) => const AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              // ✍️ Açıklama
              PostDescription(description: post.description),

              const SizedBox(height: 10),

              // ❤️💬 Etkileşim ikonları
              PostActionsInfo(
                postId: post.id,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
