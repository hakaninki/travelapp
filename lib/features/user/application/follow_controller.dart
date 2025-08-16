import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/features/user/services/follow_service.dart';

/// Service DI
final followServiceProvider = Provider<FollowService>((ref) {
  return FollowService();
});

/// current -> target ilişkisi: takip ediyor mu?
final isFollowingStreamProvider =
    StreamProvider.family<bool, String>((ref, targetUid) {
  final currentUid = FirebaseAuth.instance.currentUser?.uid;
  if (currentUid == null) return  Stream<bool>.value(false);
  final svc = ref.watch(followServiceProvider);
  return svc.isFollowingStream(currentUid: currentUid, targetUid: targetUid);
});

/// Takipçi sayısı (profil sahibinin followers sayısı)
final followersCountStreamProvider =
    StreamProvider.family<int, String>((ref, uid) {
  final svc = ref.watch(followServiceProvider);
  return svc.followersCountStream(uid);
});

/// Takip edilen sayısı (profil sahibinin following sayısı)
final followingCountStreamProvider =
    StreamProvider.family<int, String>((ref, uid) {
  final svc = ref.watch(followServiceProvider);
  return svc.followingCountStream(uid);
});

/// Follow/Unfollow aksiyonu (toggle)
final followToggleProvider = Provider.family<Future<void> Function(), String>(
  (ref, targetUid) {
    return () async {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid == null) {
        throw Exception('Not signed in');
      }
      final svc = ref.read(followServiceProvider);

      // Mevcut duruma bakıp toggle yap
      final isFollowing = await svc
          .isFollowingStream(currentUid: currentUid, targetUid: targetUid)
          .first;

      if (isFollowing) {
        await svc.unfollow(currentUid: currentUid, targetUid: targetUid);
      } else {
        await svc.follow(currentUid: currentUid, targetUid: targetUid);
      }
    };
  },
);
