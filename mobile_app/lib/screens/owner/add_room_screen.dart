import 'package:flutter/material.dart';
import '../../services/room_service.dart';
import '../../theme/app_theme.dart';

class AddRoomScreen extends StatefulWidget {
  final int hostelId;
  const AddRoomScreen({super.key, required this.hostelId});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final RoomService _service = RoomService();
  final _priceController = TextEditingController();
  final _bedsController = TextEditingController();

  String _roomType = '2-sharing';
  String _pricePeriod = 'month';
  bool _isSelfContained = false;
  bool _isSubmitting = false;
  String? _error;

  Future<void> _submit() async {
    final price = double.tryParse(_priceController.text.trim());
    final beds = int.tryParse(_bedsController.text.trim());

    if (price == null || price <= 0) {
      setState(() => _error = 'Enter a valid price');
      return;
    }
    if (beds == null || beds <= 0) {
      setState(() => _error = 'Enter a valid number of beds');
      return;
    }

    setState(() { _isSubmitting = true; _error = null; });
    try {
      await _service.createRoom(
        hostelId: widget.hostelId,
        roomType: _roomType,
        priceAmount: price,
        pricePeriod: _pricePeriod,
        totalBeds: beds,
        isSelfContained: _isSelfContained,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Room')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _roomType,
            decoration: const InputDecoration(labelText: 'Room type'),
            items: const [
              DropdownMenuItem(value: 'single', child: Text('Single')),
              DropdownMenuItem(value: '2-sharing', child: Text('2-sharing')),
              DropdownMenuItem(value: '4-sharing', child: Text('4-sharing')),
            ],
            onChanged: (v) => setState(() => _roomType = v!),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Price (MWK)'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _pricePeriod,
            decoration: const InputDecoration(labelText: 'Price period'),
            items: const [
              DropdownMenuItem(value: 'month', child: Text('Per month')),
              DropdownMenuItem(value: 'semester', child: Text('Per semester')),
            ],
            onChanged: (v) => setState(() => _pricePeriod = v!),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _bedsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Total beds'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Self-contained', style: TextStyle(fontSize: 14)),
            value: _isSelfContained,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _isSelfContained = v),
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            const SizedBox(height: 12),
          ],
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Add Room'),
          ),
        ],
      ),
    );
  }
}