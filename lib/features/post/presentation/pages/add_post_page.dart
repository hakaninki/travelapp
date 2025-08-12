import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:travel_app/features/post/providers/post_provider.dart';
//import 'package:travel_app/features/post/application/add_post_state.dart';
import 'package:travel_app/features/post/presentation/widgets/image_picker_field.dart';
import 'package:travel_app/features/post/presentation/widgets/description_field.dart';
import 'package:travel_app/features/post/presentation/widgets/location_field.dart';
import 'package:travel_app/features/main/providers/nav_provider.dart';

class AddPostPage extends ConsumerWidget {
  const AddPostPage({super.key});

  Future<void> _pick(WidgetRef ref) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      ref.read(addPostControllerProvider.notifier).setImage(File(picked.path));
    }
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(addPostControllerProvider.notifier).submit();
    final st = ref.read(addPostControllerProvider);
    if (!context.mounted) return;

    if (ok) {
      // 🔽 Home tab'a geç, pop yok
      ref.read(navIndexProvider.notifier).state = 0;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Posted ✅')));
    } else if (st.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(st.error!)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(addPostControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          TextButton(
            onPressed: st.isLoading ? null : () => _submit(context, ref),
            child: const Text('Publish', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ImagePickerField(
            image: st.image,
            onPick: () => _pick(ref),
            onClear: () =>
                ref.read(addPostControllerProvider.notifier).setImage(null),
          ),
          const SizedBox(height: 16),
          DescriptionField(
            initial: st.description,
            onChanged: (v) =>
                ref.read(addPostControllerProvider.notifier).setDescription(v),
          ),
          const SizedBox(height: 12),
          LocationField(
            initial: st.location,
            onChanged: (v) =>
                ref.read(addPostControllerProvider.notifier).setLocation(v),
          ),
          const SizedBox(height: 24),
          if (st.isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
