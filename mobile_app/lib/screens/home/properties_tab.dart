import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import '../../theme/app_theme.dart';

class PropertiesTab extends StatefulWidget {
  const PropertiesTab({super.key});

  @override
  State<PropertiesTab> createState() => _PropertiesTabState();
}

class _PropertiesTabState extends State<PropertiesTab> {
  final PropertyService _service = PropertyService();
  List<Property> _properties = [];
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
      final properties = await _service.fetchProperties();
      setState(() { _properties = properties; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _load, child: const Text('Try Again')),
            ],
          ),
        ),
      );
    }

    if (_properties.isEmpty) {
      return const Center(child: Text('No properties listed yet.'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _properties.length,
        itemBuilder: (context, index) => _PropertyCard(property: _properties[index]),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final Property property;
  const _PropertyCard({required this.property});

  String _formatPrice() {
    final amountStr = property.priceAmount.toStringAsFixed(0);
    final withCommas = amountStr.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},',
    );
    final suffix = property.listingType == 'rent' ? '/${property.pricePeriod ?? 'month'}' : '';
    return 'MWK $withCommas$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final isTaken = property.status == 'taken';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      property.listingType.toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${property.propertyType[0].toUpperCase()}${property.propertyType.substring(1)} in ${property.area ?? property.city}',
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isTaken) const _TakenPill(),
                ],
              ),
              const SizedBox(height: 10),
              Text(_formatPrice(), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (property.bedrooms != null) _iconLabel(Icons.bed_outlined, '${property.bedrooms} bed'),
                  if (property.bathrooms != null) _iconLabel(Icons.bathtub_outlined, '${property.bathrooms} bath'),
                  _iconLabel(Icons.location_on_outlined, property.city),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconLabel(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TakenPill extends StatelessWidget {
  const _TakenPill();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text('Taken', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600, fontSize: 11)),
    );
  }
}