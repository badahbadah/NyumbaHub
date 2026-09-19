import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/conversation.dart';
import '../../providers/auth_provider.dart';
import '../../services/conversation_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  final ConversationService _service = ConversationService();
  final UserService _userService = UserService();

  List<Conversation> _conversations = [];
  final Map<int, String> _namesCache = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final conversations = await _service.fetchMyConversations();
      final myId = context.read<AuthProvider>().currentUser!.id;

      for (final c in conversations) {
        final otherId = c.otherUserId(myId);
        if (!_namesCache.containsKey(otherId)) {
          try {
            final user = await _userService.fetchBasicUser(otherId);
            _namesCache[otherId] = user['full_name'];
          } catch (_) {
            _namesCache[otherId] = 'User';
          }
        }
      }

      setState(() { _conversations = conversations; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.read<AuthProvider>().currentUser!.id;

    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_conversations.isEmpty) return const Center(child: Text('No conversations yet.'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _conversations.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final conv = _conversations[index];
          final otherId = conv.otherUserId(myId);
          final name = _namesCache[otherId] ?? 'User';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary)),
            ),
            title: Text(name, style: TextStyle(fontWeight: conv.hasUnread ? FontWeight.w700 : FontWeight.w400)),
            subtitle: Text(conv.relatedType != null ? 'About a ${conv.relatedType}' : 'Conversation'),
            trailing: conv.hasUnread
                ? Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle))
                : null,
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(conversationId: conv.id, otherUserName: name)));
              _load(); // refresh so the read dot clears when coming back
            },
          );
        },
      ),
    );
  }
}