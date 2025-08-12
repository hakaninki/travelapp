import 'package:flutter/material.dart';

class LocationField extends StatelessWidget {
  final String initial;
  final ValueChanged<String> onChanged;
  const LocationField({super.key, required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial,
      onChanged: onChanged,
      decoration: const InputDecoration(
        labelText: 'Location (optional)',
        border: OutlineInputBorder(),
      ),
    );
  }
}
