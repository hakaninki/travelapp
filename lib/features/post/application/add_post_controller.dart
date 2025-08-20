import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:travel_app/core/constants/app_collection.dart';
import 'package:travel_app/features/post/application/add_post_state.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';

class AddPostController extends StateNotifier<AddPostState> {
  AddPostController(this._ref) : super(const AddPostState.initial());

  final Ref _ref;

  // ------- setters -------
  void setImage(File? img) => state = state.copyWith(image: img, error: '');
  void setDescription(String v) => state = state.copyWith(description: v, error: '');
  void setLocation(String v) => state = state.copyWith(location: v, error: '');
  void setLatLng(double? lat, double? lng) =>
      state = state.copyWith(lat: lat, lng: lng, error: '');

  // ------- submit -------
  Future<bool> submit() async {
    // temel doğrulamalar
    if (state.image == null) {
      state = state.copyWith(error: 'Please select an image');
      return false;
    }
    if (state.description.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter a description');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, error: '');

      // auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false, error: 'Not signed in');
        return false;
      }

      // username'i users/{uid} üzerinden al (fallback: displayName / email)
      String username = user.displayName ?? (user.email ?? 'user');
      try {
        final snap = await FirebaseFirestore.instance
            .collection(AppCollections.users)
            .doc(user.uid)
            .get();
        final m = snap.data();
        if (m != null && (m['username'] is String) && (m['username'] as String).trim().isNotEmpty) {
          username = (m['username'] as String).trim();
        }
      } catch (_) {/* ignore */ }

      // service
      final postService = _ref.read(postServiceProvider);

      await postService.createPost(
        imageFile: state.image!,
        uid: user.uid,
        username: username,
        description: state.description.trim(),
        location: state.location.trim(),
        lat: state.lat,          // ✅ seçildiyse yazılır, yoksa null
        lng: state.lng,
      );

      // başarı: state reset
      state = const AddPostState.initial();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to post: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// Riverpod provider
final addPostControllerProvider =
    StateNotifierProvider<AddPostController, AddPostState>((ref) {
  return AddPostController(ref);
});
