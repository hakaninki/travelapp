import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:travel_app/features/chat/providers/chat_providers.dart';
import 'package:travel_app/features/chat/services/chat_service.dart';
import 'package:travel_app/features/user/providers/user_provider.dart';
import 'package:travel_app/core/models/user_model.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String otherUid;
  const ChatPage({super.key, required this.otherUid});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  String? _cid;
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final svc = ref.read(chatServiceProvider);
        final cid = await svc.openOrCreateConversation(widget.otherUid);
        if (!mounted) return;
        setState(() => _cid = cid);
        await svc.markAllAsRead(cid);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open chat: $e')),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _cid == null) return;
    final svc = ref.read(chatServiceProvider);
    await svc.sendMessage(cid: _cid!, text: text);
    _ctrl.clear();
    await Future.delayed(const Duration(milliseconds: 50));
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = ref.watch(userServiceProvider);

    return FutureBuilder<UserModel?>(
      future: userService.getUserById(widget.otherUid),
      builder: (ctx, snap) {
        final title = snap.data?.username ?? 'Chat';
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: (_cid == null)
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: Consumer(builder: (ctx, ref, _) {
                        final msgsAsync = ref.watch(messagesProvider(_cid!));
                        final me = FirebaseAuth.instance.currentUser;
                        return msgsAsync.when(
                          data: (msgs) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              // mark as read best-effort
                              ref.read(chatServiceProvider).markAllAsRead(_cid!);
                            });
                            return ListView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              itemCount: msgs.length,
                              itemBuilder: (ctx, i) {
                                final m = msgs[i];
                                final isMine = m.fromUid == me?.uid;
                                return Align(
                                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                                  child: GestureDetector(
                                    onLongPress: isMine
                                        ? () async {
                                            final ok = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text('Delete message?'),
                                                content: const Text('This will delete the message for everyone.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (ok == true) {
                                              await ref
                                                  .read(chatServiceProvider)
                                                  .deleteMessage(_cid!, m.id);
                                            }
                                          }
                                        : null,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isMine
                                            ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(m.text),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Error: $e')),
                        );
                      }),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _ctrl,
                                decoration: const InputDecoration(
                                  hintText: 'Message...',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _send(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _send,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
        );
      },
    );
  }
}
