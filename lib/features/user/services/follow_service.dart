import 'package:cloud_firestore/cloud_firestore.dart';

class FollowService {
  FollowService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  static const _users = 'users';
  static const _followers = 'followers';
  static const _following = 'following';

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection(_users).doc(uid);

  CollectionReference<Map<String, dynamic>> _followersCol(String uid) =>
      _userDoc(uid).collection(_followers);

  CollectionReference<Map<String, dynamic>> _followingCol(String uid) =>
      _userDoc(uid).collection(_following);

  /// currentUid -> targetUid takip et
  Future<void> follow({
    required String currentUid,
    required String targetUid,
  }) async {
    if (currentUid == targetUid) return;

    final followingRef = _followingCol(currentUid).doc(targetUid);
    final followersRef = _followersCol(targetUid).doc(currentUid);

    await _db.runTransaction((tx) async {
      tx.set(followingRef, {'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      tx.set(followersRef, {'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    });
  }

  /// currentUid -> targetUid takibi bırak
  Future<void> unfollow({
    required String currentUid,
    required String targetUid,
  }) async {
    if (currentUid == targetUid) return;

    final followingRef = _followingCol(currentUid).doc(targetUid);
    final followersRef = _followersCol(targetUid).doc(currentUid);

    await _db.runTransaction((tx) async {
      tx.delete(followingRef);
      tx.delete(followersRef);
    });
  }

  /// currentUid, targetUid'i takip ediyor mu?
  Stream<bool> isFollowingStream({
    required String currentUid,
    required String targetUid,
  }) {
    if (currentUid == targetUid) {
      // Kendini her zaman 'following' kabul etmeye gerek yok; false döndürelim.
      return  Stream<bool>.value(false);
    }
    return _followingCol(currentUid)
        .doc(targetUid)
        .snapshots()
        .map((d) => d.exists);
  }

  /// Takipçi sayısı (targetUid'i takip edenler)
  Stream<int> followersCountStream(String targetUid) {
    return _followersCol(targetUid).snapshots().map((s) => s.size);
  }

  /// Takip edilen sayısı (currentUid'in takip ettikleri)
  Stream<int> followingCountStream(String currentUid) {
    return _followingCol(currentUid).snapshots().map((s) => s.size);
  }
}
