import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:travel_app/core/models/user_model.dart';
import 'package:travel_app/features/user/application/follow_controller.dart';
import 'package:travel_app/features/user/widgets/follow_button.dart';
import 'package:travel_app/features/user/pages/followers_page.dart';
import 'package:travel_app/features/user/pages/following_page.dart';
import 'package:travel_app/features/chat/pages/chat_page.dart';

class ProfileHeader extends ConsumerWidget {
  final UserModel user;
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwnProfile = (currentUid != null && currentUid == user.id);

    final followersCount = ref.watch(followersCountStreamProvider(user.id));
    final followingCount = ref.watch(followingCountStreamProvider(user.id));

    Widget statBox(AsyncValue<int> count, String label, {VoidCallback? onTap}) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              count.when(
                data: (v) => Text(
                  '$v',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                loading: () => const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const Text('0',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                ? NetworkImage(user.photoUrl!)
                : null,
            child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                ? const Icon(Icons.person, size: 36)
                : null,
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username ?? 'user_${user.id.substring(0, 6)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  user.bio?.trim().isNotEmpty == true ? user.bio!.trim() : 'No bio yet',
                  style: const TextStyle(color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    statBox(
                      followersCount,
                      'Followers',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FollowersPage(userId: user.id),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    statBox(
                      followingCount,
                      'Following',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FollowingPage(userId: user.id),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                if (!isOwnProfile) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Follow button (existing)
                      FollowButton(targetUid: user.id),
                      const SizedBox(width: 8),
                      // Message button next to Follow
                      SizedBox(
                        height: 36,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Message'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatPage(otherUid: user.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
