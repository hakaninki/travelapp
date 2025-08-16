import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/profile/providers/profile_stream_provider.dart';
import 'package:travel_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:travel_app/features/profile/presentation/widgets/profile_post_grid.dart';
import 'package:travel_app/features/auth/providers/auth_provider.dart';
import 'package:travel_app/features/profile/presentation/pages/edit_profile_page.dart';

class ProfilePage extends ConsumerWidget {
  final String? userId; // null ise current user
  const ProfilePage({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final targetUid = userId ?? currentUid;

    if (targetUid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    final userAsync = ref.watch(userStreamProvider(targetUid));
    final isOwnProfile = (currentUid != null && targetUid == currentUid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color.fromARGB(255, 240, 146, 69),
        actions: [
          if (isOwnProfile)
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EditProfilePage(uid: targetUid)),
                );
              },
            ),
          if (isOwnProfile)
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: ProfileHeader(user: user)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                sliver: ProfilePostGrid(userId: targetUid),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
