// lib/features/post/presentation/pages/post_detail_page.dart
import 'package:flutter/material.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/home/widgets/post_card.dart';
import 'package:travel_app/features/post/presentation/widgets/comments_section.dart';
import 'package:travel_app/features/post/presentation/widgets/comment_input_bar.dart';

class PostDetailPage extends StatelessWidget {
  final PostModel post;
  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: SafeArea(
        child: Column(
          children: [
            // İçerik: scrollable
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  PostCard(post: post),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Comments',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  CommentsSection(post: post),
                  const SizedBox(height: 80), // alttaki input için boşluk
                ],
              ),
            ),
            // Alt input bar (sabit)
            CommentInputBar(postId: post.id),
          ],
        ),
      ),
    );
  }
}
