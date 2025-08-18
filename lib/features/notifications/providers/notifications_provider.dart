// lib/features/notifications/providers/notifications_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/notifications/services/notifications_service.dart';

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService();
});

// NotificationsPage bu provider'ı dinliyor
final notificationsStreamProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(notificationsServiceProvider).watchMyNotifications();
});
