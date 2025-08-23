import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:travel_app/core/models/user_model.dart';
import 'package:travel_app/features/chat/models/conversation_model.dart';
import 'package:travel_app/features/chat/pages/chat_page.dart';
import 'package:travel_app/features/chat/providers/chat_providers.dart';
import 'package:travel_app/features/user/providers/user_provider.dart';

class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convosAsync = ref.watch(myConversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: convosAsync.when(
        data: (convos) {
          if (convos.isEmpty) {
            return const Center(child: Text('No conversations yet'));
          }
          final me = FirebaseAuth.instance.currentUser;
          final myUid = me?.uid ?? '';
          return ListView.separated(
            itemCount: convos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final c = convos[i];
              final other = c.otherUid(myUid);
              return _ConversationTile(convo: c, otherUid: other, myUid: myUid);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  final ConversationModel convo;
  final String otherUid;
  final String myUid;

  const _ConversationTile({
    required this.convo,
    required this.otherUid,
    required this.myUid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = ref.watch(userServiceProvider);
    final unread = convo.unreadFor(myUid);

    return FutureBuilder<UserModel?>(
      future: userService.getUserById(otherUid),
      builder: (ctx, snap) {
        final user = snap.data;
        final titleStyle = TextStyle(
          fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
        );

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                ? NetworkImage(user.photoUrl!)
                : null,
            child: (user?.photoUrl == null || (user?.photoUrl?.isEmpty ?? true))
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(
            user?.username ?? otherUid,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
          subtitle: Text(
            convo.lastMessage ?? 'Say hi 👋',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: unread > 0
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 10, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      '$unread',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                )
              : null,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ChatPage(otherUid: otherUid)),
            );
          },
          onLongPress: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Delete conversation?'),
                content: const Text('This will delete all messages for both participants.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                ],
              ),
            );
            if (ok == true) {
              await ref.read(chatServiceProvider).deleteConversation(convo.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Conversation deleted')),
                );
              }
            }
          },
        );
      },
    );
  }
}
