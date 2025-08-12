import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/home/widgets/home_sliver_appbar.dart';
import 'package:travel_app/features/home/widgets/home_sliver_list.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postProvider); // AsyncValue<List<PostModel>>

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const HomeSliverAppBar(),
          // AsyncValue'yi sliver'a çevir:
          postsAsync.when(
            data: (posts) => HomeSliverList(posts: posts),
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error loading posts: $e'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
