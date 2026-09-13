import 'package:flutter/material.dart';
import '../../models/hostel.dart';
import '../../services/hostel_service.dart';

class HostelListScreen extends StatefulWidget {
  const HostelListScreen({super.key});

  @override
  State<HostelListScreen> createState() => _HostelListScreenState();
}

class _HostelListScreenState extends State<HostelListScreen> {
  final HostelService _hostelService = HostelService();

  List<Hostel> _hostels = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHostels();
  }

  Future<void> _loadHostels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hostels = await _hostelService.fetchHostels();
      setState(() {
        _hostels = hostels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hostels')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadHostels, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_hostels.isEmpty) {
      return const Center(child: Text('No hostels found yet.'));
    }

    return RefreshIndicator(
      onRefresh: _loadHostels,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _hostels.length,
        itemBuilder: (context, index) => _HostelCard(hostel: _hostels[index]),
      ),
    );
  }
}

class _HostelCard extends StatelessWidget {
  final Hostel hostel;

  const _HostelCard({required this.hostel});

  @override
  Widget build(BuildContext context) {
    final isFull = hostel.status == 'full';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    hostel.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isFull ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isFull ? 'FULL' : 'Available',
                    style: TextStyle(
                      color: isFull ? Colors.red.shade800 : Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (hostel.description != null && hostel.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(hostel.description!, style: TextStyle(color: Colors.grey.shade700)),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (hostel.hasWaterBackup) _amenityChip(Icons.water_drop, 'Water'),
                if (hostel.hasElectricityBackup) _amenityChip(Icons.bolt, 'Power'),
                if (hostel.hasSecurity) _amenityChip(Icons.security, 'Security'),
                if (hostel.hasWifi) _amenityChip(Icons.wifi, 'WiFi'),
                if (hostel.hasStudyArea) _amenityChip(Icons.menu_book, 'Study Area'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _amenityChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}