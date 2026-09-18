import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../services/conversation_service.dart';
import '../../theme/app_theme.dart';
import '../messages/chat_screen.dart';

class HostelBookingsScreen extends StatefulWidget {
  final int hostelId;
  const HostelBookingsScreen({super.key, required this.hostelId});

  @override
  State<HostelBookingsScreen> createState() => _HostelBookingsScreenState();
}

class _HostelBookingsScreenState extends State<HostelBookingsScreen> {
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
      final bookings = await _bookingService.fetchBookingsForHostel(widget.hostelId);
      setState(() { _bookings = bookings; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  Future<void> _decide(Booking booking, bool approve) async {
    setState(() => _actioningId = booking.id);
    try {
      if (approve) {
        await _bookingService.approveBooking(booking.id);
      } else {
        await _bookingService.rejectBooking(booking.id);
      }
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _actioningId = null);
    }
  }

  Future<void> _messageStudent(Booking booking) async {
    setState(() => _actioningId = booking.id);
    try {
      final result = await _conversationService.startOrSend(
        recipientId: booking.studentId,
        relatedType: 'hostel',
        relatedId: booking.hostelId,
        messageText: 'Hi, this is regarding your booking (${booking.bookingCode}).',
      );
      final conversationId = result['conversation']['id'];
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(conversationId: conversationId, otherUserName: booking.studentName ?? 'Student')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _actioningId = null);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'cancelled': return AppColors.danger;
      default: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Active = not cancelled, regardless of payment_status — this is the fix:
    // previously only status == 'confirmed' was shown, hiding awaiting-payment bookings.
    final active = _bookings.where((b) => b.status != 'cancelled').toList();
    final pending = active.where((b) => b.ownerDecision == 'pending').toList();
    final decided = active.where((b) => b.ownerDecision != 'pending').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookings'),
          bottom: TabBar(tabs: [Tab(text: 'Pending (${pending.length})'), const Tab(text: 'Approved / Denied')]),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : TabBarView(children: [_buildList(pending, showActions: true), _buildList(decided, showActions: false)]),
      ),
    );
  }

  Widget _buildList(List<Booking> bookings, {required bool showActions}) {
    if (bookings.isEmpty) return const Center(child: Text('Nothing here yet.'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final isActing = _actioningId == booking.id;

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
                        Expanded(child: Text(booking.studentName ?? 'Student', style: Theme.of(context).textTheme.titleMedium)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: _statusColor(booking.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            booking.paymentStatus == 'paid' ? 'PAID' : booking.paymentStatus.toUpperCase(),
                            style: TextStyle(color: _statusColor(booking.status), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${booking.roomType ?? ''} \u00b7 MWK ${booking.depositAmount.toStringAsFixed(0)} deposit', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Code: ${booking.bookingCode}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    if (!showActions)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          booking.ownerDecision == 'approved' ? 'Approved' : 'Denied',
                          style: TextStyle(fontSize: 12, color: booking.ownerDecision == 'approved' ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: isActing ? null : () => _messageStudent(booking), child: const Text('Message')),
                        if (showActions) ...[
                          TextButton(
                            onPressed: isActing ? null : () => _decide(booking, false),
                            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                            child: const Text('Deny'),
                          ),
                          ElevatedButton(
                            onPressed: isActing ? null : () => _decide(booking, true),
                            child: isActing ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Approve'),
                          ),
                        ],
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