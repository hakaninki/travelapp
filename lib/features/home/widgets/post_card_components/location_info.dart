import 'package:flutter/material.dart';

class LocationInfoRow extends StatelessWidget {
  final String location;

  const LocationInfoRow({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Icon(Icons.location_on_sharp, color: Colors.blueAccent),
          Text(
            location,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
