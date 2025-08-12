import 'package:flutter/material.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/home/widgets/post_card.dart';

class HomeSliverList extends StatelessWidget {
  final List<PostModel> posts;

  const HomeSliverList({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: posts.length,
        (context, index) {
          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: PostCard(post: post),
          );
        },
      ),
    );
  }
}
