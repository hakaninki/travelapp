// lib/features/notifications/pages/notifications_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/core/widgets/async_error.dart';
import 'package:travel_app/features/notifications/providers/notifications_provider.dart';
import 'package:travel_app/features/notifications/widgets/notification_tile.dart';
import 'package:travel_app/features/post/presentation/pages/post_detail_page.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotifs = ref.watch(notificationsStreamProvider);
    final svc = ref.read(notificationsServiceProvider);

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              'Notifications',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        asyncNotifs.when(
          data: (items) {
            if (items.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No notifications yet')),
                ),
              );
            }
            return SliverList.separated(
              itemBuilder: (context, i) {
                final n = items[i];
                return NotificationTile(
                  notif: n,
                  onTap: () async {
                    await svc.markAsRead(n.id);

                    // Yalnızca postId varsa detay sayfasına git
                    final postId = n.postId;
                    if (postId == null || postId.isEmpty) return;

                    try {
                      final doc = await FirebaseFirestore.instance
                          .collection('posts')
                          .doc(postId)
                          .get();

                      if (!doc.exists || doc.data() == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Post not found')),
                          );
                        }
                        return;
                      }

                      final data = doc.data()!;
                      final post = PostModel.fromMap({...data, 'id': doc.id});

                      if (context.mounted) {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PostDetailPage(post: post),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to open post: $e')),
                        );
                      }
                    }
                  },
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: items.length,
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (e, _) => SliverToBoxAdapter(
            child: AsyncErrorWidget(
              error: e,
              message: 'Failed to load notifications.',
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}
