import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/features/post/application/add_post_state.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';

class AddPostController extends StateNotifier<AddPostState> {
  AddPostController(this._ref) : super(const AddPostState());
  final Ref _ref;

  void setImage(File? f) => state = state.copyWith(image: f, error: null);
  void setDescription(String v) =>
      state = state.copyWith(description: v, error: null);
  void setLocation(String v) =>
      state = state.copyWith(location: v, error: null);

  Future<bool> submit() async {
    if (state.image == null) {
      state = state.copyWith(error: 'Select an image');
      return false;
    }
    if (state.description.trim().isEmpty) {
      state = state.copyWith(error: 'Description cannot be empty');
      return false;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(error: 'Please login');
      return false;
    }

    // username'i users/{uid} 'den çek
    String username = user.displayName ?? 'Unknown';
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final u = (doc.data()?['username'] as String?);
      if (u != null && u.trim().isNotEmpty) username = u.trim();
    } catch (_) {}

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _ref.read(postServiceProvider).createPost(
            imageFile: state.image!,
            uid: user.uid,
            username: username,
            description: state.description.trim(),
            location: state.location.trim(),
          );
      state = const AddPostState(); // formu sıfırla
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// ⬇️ Provider burada — add_post_page.dart bu ismi kullanıyor
final addPostControllerProvider =
    StateNotifierProvider<AddPostController, AddPostState>(
  (ref) => AddPostController(ref),
);
