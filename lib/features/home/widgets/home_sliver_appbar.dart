import 'package:flutter/material.dart';
import 'package:travel_app/features/home/widgets/search_bar.dart';

class HomeSliverAppBar extends StatelessWidget {
  const HomeSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
  backgroundColor: Colors.white,
  expandedHeight: 250,
  floating: true, // Scroll edince hemen aşağıdan title görünür
  snap: true,     // Yukarı çıkarken title hızlıca görünür
  pinned: true,  // Her zaman görünmesin, sadece scroll olunca görünsün
  flexibleSpace: FlexibleSpaceBar(
    background: Stack(
      children: [
        Image.asset(
          "images/splash5.png",
          fit: BoxFit.cover,
          width: double.infinity,
        ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "EUNOWA",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Places live through stories",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 10),
              ExploreBar(),
            ],
          ),
        ),
      ],
    ),
  ),
  title: const Text("EUNOWA", style: TextStyle(color: Colors.black)),
  actions: [
    IconButton(
      icon: const Icon(Icons.search, color: Colors.black),
      onPressed: () => showSearchDialog(context),
    ),
  ],
);
  }

  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Search"),
        content: const TextField(
          decoration: InputDecoration(hintText: "Type something..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
