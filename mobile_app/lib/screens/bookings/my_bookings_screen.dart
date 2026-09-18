import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../services/conversation_service.dart';
import '../../theme/app_theme.dart';
import '../reviews/review_form_screen.dart';
import '../messages/chat_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingService _bookingService = BookingService();
  final ConversationService _conversationService = ConversationService();

  List<Booking> _bookings = [];
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
      final bookings = await _bookingService.fetchMyBookings();
      setState(() { _bookings = bookings; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  Future<void> _delete(Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete booking?'),
        content: const Text('This will free up the bed and remove this booking permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes, delete')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _actioningId = booking.id);
    try {
      await _bookingService.deleteBooking(booking.id);
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _actioningId = null);
    }
  }

  Future<void> _messageOwner(Booking booking) async {
    if (booking.hostelOwnerId == null) return;
    setState(() => _actioningId = booking.id);
    try {
      final result = await _conversationService.startOrSend(
        recipientId: booking.hostelOwnerId!,
        relatedType: 'hostel',
        relatedId: booking.hostelId,
        messageText: 'Hi, I have a question about my booking (${booking.bookingCode}).',
      );
      final conversationId = result['conversation']['id'];
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(conversationId: conversationId, otherUserName: 'Hostel Owner')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _actioningId = null);
    }
  }

  Color _decisionColor(String decision) {
    switch (decision) {
      case 'approved': return AppColors.success;
      case 'denied': return AppColors.danger;
      default: return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _bookings.where((b) => b.ownerDecision == 'pending').toList();
    final decided = _bookings.where((b) => b.ownerDecision != 'pending').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: TabBar(tabs: [Tab(text: 'Pending (${pending.length})'), const Tab(text: 'Approved / Denied')]),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : TabBarView(children: [_buildList(pending, canDelete: true), _buildList(decided, canDelete: false)]),
      ),
    );
  }

  Widget _buildList(List<Booking> bookings, {required bool canDelete}) {
    if (bookings.isEmpty) return const Center(child: Text('Nothing here yet.'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final isActing = _actioningId == booking.id;
          final canReallyDelete = canDelete && booking.ownerDecision != 'approved';

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(booking.hostelName ?? 'Hostel', style: Theme.of(context).textTheme.titleMedium)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: _decisionColor(booking.ownerDecision).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            booking.ownerDecision == 'pending' ? 'PENDING' : booking.ownerDecision.toUpperCase(),
                            style: TextStyle(color: _decisionColor(booking.ownerDecision), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${booking.roomType ?? ''} \u00b7 MWK ${booking.depositAmount.toStringAsFixed(0)} deposit', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Code: ${booking.bookingCode} \u00b7 Payment: ${booking.paymentStatus}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: isActing ? null : () => _messageOwner(booking), child: const Text('Message')),
                        if (booking.ownerDecision == 'approved')
                          TextButton(
                            onPressed: () async {
                              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReviewFormScreen(hostelId: booking.hostelId)));
                            },
                            child: const Text('Review'),
                          ),
                        if (canReallyDelete)
                          TextButton(
                            onPressed: isActing ? null : () => _delete(booking),
                            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                            child: isActing ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Delete'),
                          ),
                      ],
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