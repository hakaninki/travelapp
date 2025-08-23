import 'package:flutter/material.dart';
import 'package:travel_app/features/user/pages/user_search_page.dart';

class ExploreBar extends StatelessWidget {
  const ExploreBar({super.key});

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UserSearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _openSearch(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    "Search users",
                    style: TextStyle(
                      color: Color.fromARGB(143, 160, 84, 84),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.travel_explore_outlined,
                  color: Color.fromARGB(143, 160, 84, 84),
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
