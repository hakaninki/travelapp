import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class PostModel {
  final String id;
  final String uid;
  final String username;
  final String description;
  final String imageUrl;
  final String location;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.uid,
    required this.username,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'uid': uid,
        'username': username,
        'description': description,
        'imageUrl': imageUrl,
        'location': location,
        'createdAt': createdAt,
      };

  factory PostModel.fromMap(Map<String, dynamic> m) {
    final raw = m['createdAt'];
    DateTime created;
    if (raw is Timestamp) {
      created = raw.toDate();
    } else if (raw is DateTime) {
      created = raw;
    } else if (raw is int) {
      // ms since epoch gelirse
      created = DateTime.fromMillisecondsSinceEpoch(raw);
    } else {
      created = DateTime.now();
    }

    return PostModel(
      id: m['id'] as String,
      uid: m['uid'] as String,
      username: m['username'] as String,
      description: m['description'] as String,
      imageUrl: m['imageUrl'] as String,
      location: m['location'] as String,
      createdAt: created,
    );
  }
}
