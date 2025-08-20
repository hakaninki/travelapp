// lib/features/user/application/follow_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/features/user/services/follow_service.dart';
import 'package:travel_app/features/notifications/providers/notifications_provider.dart';

/// Service DI
final followServiceProvider = Provider<FollowService>((ref) {
  return FollowService();
});

/// current -> target ilişkisi: takip ediyor mu?
final isFollowingStreamProvider =
    StreamProvider.family<bool, String>((ref, targetUid) {
  final currentUid = FirebaseAuth.instance.currentUser?.uid;
  if (currentUid == null) return const Stream<bool>.empty();
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

/// Follow/Unfollow aksiyonu (toggle) + **follow bildirimi**
final followToggleProvider = Provider.family<Future<void> Function(), String>(
  (ref, targetUid) {
    return () async {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid == null) {
        throw Exception('Not signed in');
      }
      if (currentUid == targetUid) {
        // kendini takip etme durumunda sessizce çık
        return;
      }

      final svc = ref.read(followServiceProvider);
      final notifSvc = ref.read(notificationsServiceProvider);

      // Mevcut duruma bak
      final isFollowing = await svc
          .isFollowingStream(currentUid: currentUid, targetUid: targetUid)
          .first;

      if (isFollowing) {
        // UNFOLLOW (bildirim yok)
        await svc.unfollow(currentUid: currentUid, targetUid: targetUid);
      } else {
        // FOLLOW + bildirim
        await svc.follow(currentUid: currentUid, targetUid: targetUid);

        // Bildirim hataya düşse bile UI'yı bozmayalım
        try {
          await notifSvc.createFollowNotification(
            targetUid: targetUid,
            fromUid: currentUid,
            // istersen fromUsername / fromPhotoUrl de ekleyebiliriz:
            // fromUsername: ...,
            // fromPhotoUrl: ...,
          );
          // ignore: avoid_print
          print('DEBUG notif.follow: created target=$targetUid from=$currentUid');
        } catch (e) {
          // ignore: avoid_print
          print('DEBUG notif.follow: failed (ignored): $e');
        }
      }
    };
  },
);
