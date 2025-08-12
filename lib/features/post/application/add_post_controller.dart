import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/post/application/add_post_state.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';
import 'package:travel_app/features/auth/providers/auth_provider.dart';

class AddPostController extends StateNotifier<AddPostState> {
  final Ref _ref;
  AddPostController(this._ref) : super(const AddPostState());

  void setImage(File? f) => state = state.copyWith(image: f, error: null);
  void setDescription(String v) => state = state.copyWith(description: v, error: null);
  void setLocation(String v) => state = state.copyWith(location: v, error: null);

  Future<bool> submit() async {
    if (state.image == null) { state = state.copyWith(error: 'Select an image'); return false; }
    if (state.description.trim().isEmpty) { state = state.copyWith(error: 'Description cannot be empty'); return false; }

    final user = _ref.read(authServiceProvider).currentUser;
    if (user == null) { state = state.copyWith(error: 'Please login'); return false; }

    final firestore = _ref.read(postServiceProvider).firestore;
    final doc = await firestore.collection('users').doc(user.uid).get();
    final username = (doc.data()?['username'] as String?) ?? user.displayName ?? 'Unknown';

    print('🚀 submit(): uid=${user.uid}, username=$username');

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _ref.read(postServiceProvider).createPost(
        imageFile: state.image!,
        uid: user.uid,
        username: username,
        description: state.description.trim(),
        location: state.location.trim(),
      );
      state = const AddPostState();
      return true;
    } catch (e) {
      print('❌ submit error: $e');
      state = state.copyWith(error: e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
