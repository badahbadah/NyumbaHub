import 'package:flutter/material.dart';
import '../../models/hostel.dart';
import '../../models/room.dart';
import '../../models/review.dart';
import '../../services/room_service.dart';
import '../../services/review_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/auth_gate.dart';
import '../bookings/payment_pending_screen.dart';
import '../reviews/review_form_screen.dart';
import '../../services/booking_service.dart';

class HostelDetailScreen extends StatefulWidget {
  final Hostel hostel;
  const HostelDetailScreen({super.key, required this.hostel});

  @override
  State<HostelDetailScreen> createState() => _HostelDetailScreenState();
}

class _HostelDetailScreenState extends State<HostelDetailScreen> {
  final RoomService _roomService = RoomService();
  final ReviewService _reviewService = ReviewService();

  List<Room> _rooms = [];
  ReviewAverages? _averages;
  List<Review> _reviews = [];
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
      final rooms = await _roomService.fetchRooms(widget.hostel.id);
      final reviewData = await _reviewService.fetchReviews(widget.hostel.id);
      setState(() {
        _rooms = rooms;
        _averages = reviewData['averages'];
        _reviews = reviewData['reviews'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  Future<void> _onReserve(Room room) async {
    final ok = await requireAuth(context, reason: 'Log in to reserve a bed');
    if (!ok || !mounted) return;

    // ignore: use_build_context_synchronously
    _showReserveSheet(room);
  }

  void _showReserveSheet(Room room) {
    final phoneController = TextEditingController();
    String provider = 'TNM Mpamba';
    bool isSubmitting = false;
    String? sheetError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reserve ${room.roomType}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Deposit: MWK ${room.priceAmount.toStringAsFixed(0)}',
                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Mobile money phone number'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: provider,
                    decoration: const InputDecoration(labelText: 'Payment provider'),
                    items: const [
                      DropdownMenuItem(value: 'TNM Mpamba', child: Text('TNM Mpamba')),
                      DropdownMenuItem(value: 'Airtel Money', child: Text('Airtel Money')),
                    ],
                    onChanged: (value) => setSheetState(() => provider = value!),
                  ),
                  if (sheetError != null) ...[
                    const SizedBox(height: 12),
                    Text(sheetError!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (phoneController.text.trim().isEmpty) {
                                setSheetState(() => sheetError = 'Enter a phone number');
                                return;
                              }
                              setSheetState(() { isSubmitting = true; sheetError = null; });

                              try {
                                final bookingService = BookingService();
                                final booking = await bookingService.createBooking(
                                  roomId: room.id,
                                  depositAmount: room.priceAmount,
                                );
                                final transaction = await bookingService.payForBooking(
                                  bookingId: booking['id'],
                                  phoneNumber: phoneController.text.trim(),
                                  provider: provider,
                                );

                                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                                if (mounted) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => PaymentPendingScreen(
                                      bookingCode: booking['booking_code'],
                                      providerReference: transaction['provider_reference'],
                                      depositAmount: room.priceAmount,
                                    ),
                                  ));
                                }
                              } catch (e) {
                                setSheetState(() {
                                  isSubmitting = false;
                                  sheetError = e.toString().replaceFirst('Exception: ', '');
                                });
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Confirm Reservation'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onLeaveReview() async {
    final ok = await requireAuth(context, reason: 'Log in to leave a review');
    if (!ok || !mounted) return;

    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ReviewFormScreen(hostelId: widget.hostel.id)),
    );
    if (submitted == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final hostel = widget.hostel;
    final isFull = hostel.status == 'full';

    return Scaffold(
      appBar: AppBar(title: Text(hostel.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (hostel.description != null && hostel.description!.isNotEmpty)
                        Text(hostel.description!, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 20),
                      Text('Rooms', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      if (isFull)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'This hostel is currently full. Check back later.',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        )
                      else if (_rooms.isEmpty)
                        const Text('No rooms listed yet.')
                      else
                        ..._rooms.map((room) => _RoomTile(
                              room: room,
                              onReserve: () => _onReserve(room),
                            )),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Reviews', style: Theme.of(context).textTheme.titleLarge),
                          TextButton(onPressed: _onLeaveReview, child: const Text('Leave a Review')),
                        ],
                      ),
                      if (_averages != null && _averages!.reviewCount > 0) ...[
                        const SizedBox(height: 8),
                        _RatingSummary(averages: _averages!),
                        const SizedBox(height: 16),
                        ..._reviews.map((r) => _ReviewTile(review: r)),
                      ] else
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('No reviews yet — be the first to share your experience.'),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  final Room room;
  final VoidCallback onReserve;
  const _RoomTile({required this.room, required this.onReserve});

  @override
  Widget build(BuildContext context) {
    final isAvailable = room.availableBeds > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.roomType, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'MWK ${room.priceAmount.toStringAsFixed(0)} / ${room.pricePeriod}',
                      style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAvailable ? '${room.availableBeds} bed(s) available' : 'Fully booked',
                      style: TextStyle(
                        fontSize: 12,
                        color: isAvailable ? AppColors.success : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: isAvailable ? onReserve : null,
                child: const Text('Reserve'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final ReviewAverages averages;
  const _RatingSummary({required this.averages});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ratingRow('Water', averages.avgWater),
            _ratingRow('Electricity', averages.avgElectricity),
            _ratingRow('Safety', averages.avgSafety),
            _ratingRow('Responsiveness', averages.avgResponsiveness),
            const SizedBox(height: 6),
            Text('${averages.reviewCount} review(s)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _ratingRow(String label, double? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 13))),
          Expanded(
            child: LinearProgressIndicator(
              value: (value ?? 0) / 5,
              backgroundColor: AppColors.divider,
              color: AppColors.primary,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(value?.toStringAsFixed(1) ?? '-', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (review.comment != null && review.comment!.isNotEmpty)
            Text(review.comment!, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            'Water ${review.waterRating} · Power ${review.electricityRating} · Safety ${review.safetyRating} · Response ${review.responsivenessRating}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}