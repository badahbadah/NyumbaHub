import 'package:flutter/material.dart';
import '../../models/hostel.dart';
import '../../models/institution.dart';
import '../../services/hostel_service.dart';
import '../../services/institution_service.dart';
import '../../theme/app_theme.dart';
import '../hostels/hostel_detail_screen.dart';

class HostelsTab extends StatefulWidget {
  const HostelsTab({super.key});

  @override
  State<HostelsTab> createState() => _HostelsTabState();
}

class _HostelsTabState extends State<HostelsTab> {
  final HostelService _service = HostelService();
  final InstitutionService _institutionService = InstitutionService();
  final _searchController = TextEditingController();

  List<Hostel> _hostels = [];
  List<Institution> _institutions = [];
  int? _selectedInstitutionId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
    _load();
  }

  Future<void> _loadInstitutions() async {
    try {
      final institutions = await _institutionService.fetchInstitutions();
      setState(() => _institutions = institutions);
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final hostels = await _service.fetchHostels(
        institutionId: _selectedInstitutionId,
        search: _searchController.text,
      );
      setState(() { _hostels = hostels; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search hostel name...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchController.clear(); _load(); })
                      : null,
                ),
                onSubmitted: (_) => _load(),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(label: 'All Campuses', selected: _selectedInstitutionId == null, onTap: () { setState(() => _selectedInstitutionId = null); _load(); }),
                    ..._institutions.map((inst) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _FilterChip(
                            label: inst.shortCode,
                            selected: _selectedInstitutionId == inst.id,
                            onTap: () { setState(() => _selectedInstitutionId = inst.id); _load(); },
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorState(message: _error!, onRetry: _load);
    if (_hostels.isEmpty) return const _EmptyState(message: 'No hostels found.');

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _hostels.length,
        itemBuilder: (context, index) => _HostelCard(hostel: _hostels[index]),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondary)),
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

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HostelDetailScreen(hostel: hostel))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(hostel.name, style: Theme.of(context).textTheme.titleLarge)),
                    _StatusPill(isFull: isFull),
                  ],
                ),
                if (hostel.description != null && hostel.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(hostel.description!, style: Theme.of(context).textTheme.bodyMedium),
                ],
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    if (hostel.hasWaterBackup) const _Tag(icon: Icons.water_drop_outlined, label: 'Water'),
                    if (hostel.hasElectricityBackup) const _Tag(icon: Icons.bolt_outlined, label: 'Power'),
                    if (hostel.hasSecurity) const _Tag(icon: Icons.shield_outlined, label: 'Security'),
                    if (hostel.hasWifi) const _Tag(icon: Icons.wifi, label: 'WiFi'),
                    if (hostel.hasStudyArea) const _Tag(icon: Icons.menu_book_outlined, label: 'Study Area'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isFull;
  const _StatusPill({required this.isFull});
  @override
  Widget build(BuildContext context) {
    final color = isFull ? AppColors.danger : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(isFull ? 'FULL' : 'Available', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tag({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});
  @override
  Widget build(BuildContext context) => Center(child: Text(message, style: Theme.of(context).textTheme.bodyMedium));
}