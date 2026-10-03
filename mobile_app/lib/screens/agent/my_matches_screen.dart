import 'package:flutter/material.dart';
import '../../models/property_match.dart';
import '../../services/match_service.dart';
import '../../services/conversation_service.dart';
import '../../theme/app_theme.dart';
import '../messages/chat_screen.dart';

class MyMatchesScreen extends StatefulWidget {
  const MyMatchesScreen({super.key});

  @override
  State<MyMatchesScreen> createState() => _MyMatchesScreenState();
}

class _MyMatchesScreenState extends State<MyMatchesScreen> {
  final MatchService _matchService = MatchService();
  final ConversationService _conversationService = ConversationService();

  List<PropertyMatch> _matches = [];
  bool _isLoading = true;
  String? _error;
  int? _actioningId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final matches = await _matchService.fetchMyMatches();
      setState(() { _matches = matches; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  Future<void> _messageHunter(PropertyMatch match) async {
    if (match.hunterId == null) return;
    setState(() => _actioningId = match.id);
    try {
      final result = await _conversationService.startOrSend(
        recipientId: match.hunterId!,
        relatedType: 'request',
        relatedId: match.requestId,
        messageText: 'Hi, I submitted a property offer for your request in ${match.requestCity ?? ''}.',
      );
      final conversationId = result['conversation']['id'];
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(conversationId: conversationId, otherUserName: 'House Hunter')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _actioningId = null);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return AppColors.success;
      case 'declined': return AppColors.danger;
      default: return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _matches.where((m) => m.status == 'pending').toList();
    final decided = _matches.where((m) => m.status != 'pending').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Offers'),
          bottom: TabBar(tabs: [Tab(text: 'Pending (${pending.length})'), const Tab(text: 'Accepted / Declined')]),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : TabBarView(children: [_buildList(pending), _buildList(decided)]),
      ),
    );
  }

  Widget _buildList(List<PropertyMatch> matches) {
    if (matches.isEmpty) return const Center(child: Text('Nothing here yet.'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          final isActing = _actioningId == match.id;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text('${match.requestPropertyType ?? ''} in ${match.requestCity ?? ''}', style: Theme.of(context).textTheme.titleMedium)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: _statusColor(match.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text(match.status.toUpperCase(), style: TextStyle(color: _statusColor(match.status), fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text('Hunter\'s budget: MWK ${match.budgetAmount?.toStringAsFixed(0) ?? '-'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Your offer: MWK ${match.propertyPrice?.toStringAsFixed(0) ?? '-'}', style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: isActing ? null : () => _messageHunter(match), child: const Text('Message Hunter')),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}