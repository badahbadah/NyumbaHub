import 'package:flutter/material.dart';
import '../../models/room.dart';
import '../../services/hostel_service.dart';
import '../../services/room_service.dart';
import '../../theme/app_theme.dart';

Future<bool?> showManageAvailabilitySheet(BuildContext context, {required int hostelId, required List<Room> rooms}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => _ManageAvailabilitySheet(hostelId: hostelId, rooms: rooms),
  );
}

class _ManageAvailabilitySheet extends StatefulWidget {
  final int hostelId;
  final List<Room> rooms;
  const _ManageAvailabilitySheet({required this.hostelId, required this.rooms});

  @override
  State<_ManageAvailabilitySheet> createState() => _ManageAvailabilitySheetState();
}

class _ManageAvailabilitySheetState extends State<_ManageAvailabilitySheet> {
  final RoomService _roomService = RoomService();
  final HostelService _hostelService = HostelService();
  late Map<int, int> _values;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _values = {for (final r in widget.rooms) r.id: r.availableBeds};
  }

  Future<void> _save() async {
    setState(() { _isSaving = true; _error = null; });
    try {
      for (final room in widget.rooms) {
        final newValue = _values[room.id]!;
        if (newValue != room.availableBeds) {
          await _roomService.updateAvailableBeds(hostelId: widget.hostelId, roomId: room.id, availableBeds: newValue);
        }
      }
      await _hostelService.markActive(widget.hostelId);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() { _isSaving = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mark Hostel as Not Full', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text('Set how many beds are currently free in each room.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          ...widget.rooms.map((room) {
            final value = _values[room.id]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(room.roomType, style: Theme.of(context).textTheme.titleMedium),
                        Text('of ${room.totalBeds} total beds', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: value > 0 ? () => setState(() => _values[room.id] = value - 1) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$value', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  IconButton(
                    onPressed: value < room.totalBeds ? () => setState(() => _values[room.id] = value + 1) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            );
          }),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save & Mark Not Full'),
            ),
          ),
        ],
      ),
    );
  }
}