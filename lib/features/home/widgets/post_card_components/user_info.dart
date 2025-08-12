import 'package:flutter/material.dart';

class UserInfoRow extends StatelessWidget {
  final String username;
  final String? userImageUrl; // nullable

  const UserInfoRow({
    super.key,
    required this.username,
    this.userImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                userImageUrl != null ? NetworkImage(userImageUrl!) : null,
            child: userImageUrl == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            username,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
