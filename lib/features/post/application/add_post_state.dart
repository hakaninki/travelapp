import 'dart:io';

class AddPostState {
  final File? image;
  final String description;
  final String location;
  final bool isLoading;
  final String? error;

  const AddPostState({
    this.image,
    this.description = '',
    this.location = '',
    this.isLoading = false,
    this.error,
  });

  AddPostState copyWith({
    File? image,
    String? description,
    String? location,
    bool? isLoading,
    String? error,
  }) {
    return AddPostState(
      image: image ?? this.image,
      description: description ?? this.description,
      location: location ?? this.location,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
