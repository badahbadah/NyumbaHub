import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../theme/app_theme.dart';
import '../reviews/review_form_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingService _bookingService = BookingService();
  List<Booking> _bookings = [];
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
      final bookings = await _bookingService.fetchMyBookings();
      setState(() { _bookings = bookings; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return AppColors.success;
      case 'cancelled': return AppColors.danger;
      default: return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _bookings.isEmpty
                  ? const Center(child: Text('You have no bookings yet.'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
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
                                        Expanded(
                                          child: Text(
                                            booking.hostelName ?? 'Hostel',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _statusColor(booking.status).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            booking.status.toUpperCase(),
                                            style: TextStyle(color: _statusColor(booking.status), fontSize: 11, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('${booking.roomType ?? ''} · MWK ${booking.depositAmount.toStringAsFixed(0)} deposit',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text('Code: ${booking.bookingCode}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    if (booking.status == 'confirmed') ...[
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () async {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => ReviewFormScreen(hostelId: booking.hostelId)),
                                            );
                                          },
                                          child: const Text('Leave a Review'),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}