import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/home/home_page.dart';
import 'package:travel_app/features/post/presentation/pages/add_post_page.dart';
import 'package:travel_app/features/main/providers/nav_provider.dart';
import 'package:travel_app/features/profile/pages/profile_page.dart';
import 'package:travel_app/features/notifications/pages/notifications_page.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);
    final pages = const [
      HomePage(),
      NotificationsPage(), 
      AddPostPage(),
      PlaceholderPage(title: 'Map'),
      ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => ref.read(navIndexProvider.notifier).state = i,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown[800],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.travel_explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_rounded), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({required this.title, super.key});
  @override
  Widget build(BuildContext context) =>
      Center(child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
}
