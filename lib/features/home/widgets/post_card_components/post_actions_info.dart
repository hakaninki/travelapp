import 'package:flutter/material.dart';

class PostActionsInfo extends StatelessWidget {
  const PostActionsInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Icon(Icons.favorite_border_outlined, color: Colors.black54),
        ),
        const SizedBox(width: 10),
        const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Icon(Icons.comment, color: Colors.black54),
        ),
      ],
    );
  }
}
