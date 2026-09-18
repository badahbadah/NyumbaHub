import 'package:flutter/material.dart';
import '../../models/hostel.dart';
import '../../models/room.dart';
import '../../services/hostel_service.dart';
import '../../services/room_service.dart';
import '../../theme/app_theme.dart';
import 'add_room_screen.dart';
import 'edit_hostel_screen.dart';
import 'hostel_bookings_screen.dart';
import 'manage_availability_sheet.dart';

class HostelOwnerDetailScreen extends StatefulWidget {
  final Hostel hostel;
  const HostelOwnerDetailScreen({super.key, required this.hostel});

  @override
  State<HostelOwnerDetailScreen> createState() => _HostelOwnerDetailScreenState();
}

class _HostelOwnerDetailScreenState extends State<HostelOwnerDetailScreen> {
  final RoomService _roomService = RoomService();
  final HostelService _hostelService = HostelService();

  List<Room> _rooms = [];
  bool _isLoading = true;
  bool _isMarkingFull = false;
  String? _error;
  late Hostel _hostel;

  @override
  void initState() {
    super.initState();
    _hostel = widget.hostel;
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final rooms = await _roomService.fetchRooms(_hostel.id);
      setState(() { _rooms = rooms; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  Future<void> _markFull() async {
    setState(() => _isMarkingFull = true);
    try {
      await _hostelService.markFull(_hostel.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hostel marked as full')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isMarkingFull = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  Future<void> _openManageAvailability() async {
    if (_rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a room first before setting availability.')));
      return;
    }
    final saved = await showManageAvailabilitySheet(context, hostelId: _hostel.id, rooms: _rooms);
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hostel is now active with updated availability')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFull = _hostel.status == 'full';

    return Scaffold(
      appBar: AppBar(
        title: Text(_hostel.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => EditHostelScreen(hostel: _hostel)));
              if (saved == true) _load();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => AddRoomScreen(hostelId: _hostel.id)));
          if (added == true) _load();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.receipt_long_outlined, size: 18),
                              label: const Text('View Bookings'),
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HostelBookingsScreen(hostelId: _hostel.id))),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: isFull
                                ? ElevatedButton.icon(
                                    icon: const Icon(Icons.check_circle_outline, size: 18),
                                    label: const Text('Mark Not Full'),
                                    onPressed: _openManageAvailability,
                                  )
                                : ElevatedButton.icon(
                                    icon: _isMarkingFull
                                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Icon(Icons.block, size: 18),
                                    label: const Text('Mark Full'),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                                    onPressed: _isMarkingFull ? null : _markFull,
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Rooms', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      if (_rooms.isEmpty)
                        const Text('No rooms added yet. Tap + to add one.')
                      else
                        ..._rooms.map((room) => Container(
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
                                            Text('MWK ${room.priceAmount.toStringAsFixed(0)} / ${room.pricePeriod}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('${room.availableBeds}/${room.totalBeds}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                          const Text('beds free', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                    ],
                  ),
                ),
    );
  }
}