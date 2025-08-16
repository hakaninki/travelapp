import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/profile/providers/profile_stream_provider.dart';
import 'package:travel_app/features/post/presentation/pages/post_detail_page.dart';

class ProfilePostGrid extends ConsumerWidget {
  final String userId;
  const ProfilePostGrid({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(userPostsStreamProvider(userId));

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No posts yet')),
            ),
          );
        }
        return SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final p = posts[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PostDetailPage(post: p)),
                    );
                  },
                  child: Image.network(
                    p.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image)),
                    loadingBuilder: (c, w, prog) =>
                        prog == null ? w : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                ),
              );
            },
            childCount: posts.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
