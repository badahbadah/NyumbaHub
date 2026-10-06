import 'package:flutter/material.dart';
import '../../models/hostel.dart';
import '../../models/room.dart';
import '../../models/review.dart';
import '../../models/hostel_media.dart';
import '../../services/room_service.dart';
import '../../services/review_service.dart';
import '../../services/hostel_media_service.dart';
import '../../services/conversation_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/auth_gate.dart';
import '../bookings/payment_pending_screen.dart';
import '../reviews/review_form_screen.dart';
import '../messages/chat_screen.dart';
import '../../services/booking_service.dart';
import '../../widgets/photo_slideshow.dart';

class HostelDetailScreen extends StatefulWidget {
  final Hostel hostel;
  const HostelDetailScreen({super.key, required this.hostel});

  @override
  State<HostelDetailScreen> createState() => _HostelDetailScreenState();
}

class _HostelDetailScreenState extends State<HostelDetailScreen> {
  final RoomService _roomService = RoomService();
  final ReviewService _reviewService = ReviewService();
  final HostelMediaService _mediaService = HostelMediaService();
  final ConversationService _conversationService = ConversationService();

  List<Room> _rooms = [];
  List<HostelMedia> _photos = [];
  ReviewAverages? _averages;
  List<Review> _reviews = [];
  bool _isLoading = true;
  bool _isMessaging = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final rooms = await _roomService.fetchRooms(widget.hostel.id);
      final reviewData = await _reviewService.fetchReviews(widget.hostel.id);
      final photos = await _mediaService.fetchMedia(widget.hostel.id);
      setState(() {
        _rooms = rooms;
        _averages = reviewData['averages'];
        _reviews = reviewData['reviews'];
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _onReserve(Room room) async {
    final ok = await requireAuth(context, reason: 'Log in to reserve a bed');
    if (!ok || !mounted) return;
    _showReserveSheet(room);
  }

  Future<void> _onMessageOwner() async {
    final ok = await requireAuth(
      context,
      reason: 'Log in to message the hostel owner',
    );
    if (!ok || !mounted) return;

    setState(() => _isMessaging = true);
    try {
      final result = await _conversationService.startOrSend(
        recipientId: widget.hostel.ownerId,
        relatedType: 'hostel',
        relatedId: widget.hostel.id,
        messageText: 'Hi, I\'m interested in ${widget.hostel.name}.',
      );
      final conversationId = result['conversation']['id'];
      if (mounted) {
        setState(() => _isMessaging = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversationId,
              otherUserName: 'Hostel Owner',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isMessaging = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Reserve ${room.roomType}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Deposit: MWK ${room.priceAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile money phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: provider,
                    decoration: const InputDecoration(
                      labelText: 'Payment provider',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'TNM Mpamba',
                        child: Text('TNM Mpamba'),
                      ),
                      DropdownMenuItem(
                        value: 'Airtel Money',
                        child: Text('Airtel Money'),
                      ),
                    ],
                    onChanged: (value) =>
                        setSheetState(() => provider = value!),
                  ),
                  if (sheetError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 16,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              sheetError!,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (phoneController.text.trim().isEmpty) {
                                setSheetState(
                                  () => sheetError = 'Enter a phone number',
                                );
                                return;
                              }
                              setSheetState(() {
                                isSubmitting = true;
                                sheetError = null;
                              });

                              try {
                                final bookingService = BookingService();
                                final booking = await bookingService
                                    .createBooking(
                                  roomId: room.id,
                                  depositAmount: room.priceAmount,
                                );
                                final transaction = await bookingService
                                    .payForBooking(
                                  bookingId: booking['id'],
                                  phoneNumber: phoneController.text.trim(),
                                  provider: provider,
                                );

                                if (sheetContext.mounted) {
                                  Navigator.of(sheetContext).pop();
                                }
                                if (mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PaymentPendingScreen(
                                        bookingCode: booking['booking_code'],
                                        providerReference:
                                            transaction['provider_reference'],
                                        depositAmount: room.priceAmount,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setSheetState(() {
                                  isSubmitting = false;
                                  sheetError = e
                                      .toString()
                                      .replaceFirst('Exception: ', '');
                                });
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirm Reservation',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
      MaterialPageRoute(
        builder: (_) => ReviewFormScreen(hostelId: widget.hostel.id),
      ),
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
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.danger,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      PhotoSlideshow(
                        imageUrls: _photos.map((p) => p.fullUrl).toList(),
                        height: 240,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ---- Description card ----
                            if (hostel.description != null &&
                                hostel.description!.isNotEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: Text(
                                  hostel.description!,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            if (hostel.description != null &&
                                hostel.description!.isNotEmpty)
                              const SizedBox(height: 16),

                            // ---- Message owner button (full width) ----
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                                onPressed:
                                    _isMessaging ? null : _onMessageOwner,
                                icon: _isMessaging
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.chat_bubble_outline,
                                        size: 18,
                                      ),
                                label: Text(
                                  _isMessaging
                                      ? 'Opening chat...'
                                      : 'Message Hostel Owner',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ---- Rooms header ----
                            Row(
                              children: [
                                Text(
                                  'Rooms',
                                  style:
                                      Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(width: 8),
                                if (_rooms.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${_rooms.length}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (isFull)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.danger.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: AppColors.danger,
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'This hostel is currently full. Check back later.',
                                        style: TextStyle(
                                          color: AppColors.danger,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (_rooms.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: const Text(
                                  'No rooms listed yet.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            else
                              ..._rooms.map(
                                (room) => _RoomTile(
                                  room: room,
                                  onReserve: () => _onReserve(room),
                                ),
                              ),

                            const SizedBox(height: 28),

                            // ---- Reviews header ----
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Reviews',
                                  style:
                                      Theme.of(context).textTheme.titleLarge,
                                ),
                                TextButton.icon(
                                  onPressed: _onLeaveReview,
                                  icon: const Icon(
                                    Icons.rate_review_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Leave a Review'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (_averages != null &&
                                _averages!.reviewCount > 0) ...[
                              _RatingSummary(averages: _averages!),
                              const SizedBox(height: 20),
                              ..._reviews.map((r) => _ReviewTile(review: r)),
                            ] else
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.rate_review_outlined,
                                      size: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'No reviews yet \u2014 be the first to share your experience.',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ---------------------------------------------------------------------------
// Room tile
// ---------------------------------------------------------------------------
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
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.roomType,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'MWK ${room.priceAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              ' / ${room.pricePeriod}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _AvailabilityPill(isAvailable: isAvailable),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.bed_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isAvailable
                        ? '${room.availableBeds} bed(s) available'
                        : 'Fully booked',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAvailable
                          ? AppColors.success
                          : AppColors.danger,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      onPressed: isAvailable ? onReserve : null,
                      child: const Text(
                        'Reserve',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  final bool isAvailable;
  const _AvailabilityPill({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isAvailable ? 'Available' : 'Full',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rating summary
// ---------------------------------------------------------------------------
class _RatingSummary extends StatelessWidget {
  final ReviewAverages averages;
  const _RatingSummary({required this.averages});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ratingRow('Water', averages.avgWater),
            _ratingRow('Electricity', averages.avgElectricity),
            _ratingRow('Safety', averages.avgSafety),
            _ratingRow('Responsiveness', averages.avgResponsiveness),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Based on ${averages.reviewCount} review(s)',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratingRow(String label, double? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (value ?? 0) / 5,
                backgroundColor: AppColors.divider,
                color: AppColors.primary,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 26,
            child: Text(
              value?.toStringAsFixed(1) ?? '-',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Review tile
// ---------------------------------------------------------------------------
class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Verified guest',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _ratingChip('Water', review.waterRating),
              _ratingChip('Power', review.electricityRating),
              _ratingChip('Safety', review.safetyRating),
              _ratingChip('Response', review.responsivenessRating),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratingChip(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 11, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            '$label $value',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}