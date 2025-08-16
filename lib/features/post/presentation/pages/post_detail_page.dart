import 'package:flutter/material.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/home/widgets/post_card.dart';

class PostDetailPage extends StatelessWidget {
  final PostModel post;
  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      // PostCard zaten like/comment + kullanıcı bilgisi içeriyor
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            PostCard(post: post),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
