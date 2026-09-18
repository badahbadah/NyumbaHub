import 'package:flutter/material.dart';
import '../../models/hostel.dart';
import '../../services/hostel_service.dart';
import '../../theme/app_theme.dart';
import 'create_hostel_screen.dart';
import 'hostel_owner_detail_screen.dart';

class MyHostelsScreen extends StatefulWidget {
  const MyHostelsScreen({super.key});

  @override
  State<MyHostelsScreen> createState() => _MyHostelsScreenState();
}

class _MyHostelsScreenState extends State<MyHostelsScreen> {
  final HostelService _service = HostelService();
  List<Hostel> _hostels = [];
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
      final hostels = await _service.fetchMyHostels();
      setState(() { _hostels = hostels; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Hostels')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CreateHostelScreen()),
          );
          if (created == true) _load();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _hostels.isEmpty
                  ? const Center(child: Text('You haven\'t added a hostel yet. Tap + to add one.'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _hostels.length,
                        itemBuilder: (context, index) {
                          final hostel = _hostels[index];
                          final isFull = hostel.status == 'full';
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => HostelOwnerDetailScreen(hostel: hostel)),
                              );
                              _load();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(hostel.name, style: Theme.of(context).textTheme.titleMedium),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (isFull ? AppColors.danger : AppColors.success).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          isFull ? 'FULL' : 'Active',
                                          style: TextStyle(
                                            color: isFull ? AppColors.danger : AppColors.success,
                                            fontWeight: FontWeight.w600, fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                                    ],
                                  ),
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