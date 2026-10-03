import 'package:flutter/material.dart';
import '../../models/house_request.dart';
import '../../models/property.dart';
import '../../services/request_service.dart';
import '../../services/property_service.dart';
import '../../services/match_service.dart';
import '../../theme/app_theme.dart';

class BrowseRequestsScreen extends StatefulWidget {
  const BrowseRequestsScreen({super.key});

  @override
  State<BrowseRequestsScreen> createState() => _BrowseRequestsScreenState();
}

class _BrowseRequestsScreenState extends State<BrowseRequestsScreen> {
  final RequestService _requestService = RequestService();
  final _cityController = TextEditingController();

  List<HouseRequest> _requests = [];
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
      final requests = await _requestService.fetchRequests(city: _cityController.text, status: 'open');
      setState(() { _requests = requests; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  Future<void> _submitMatch(HouseRequest request) async {
    final propertyService = PropertyService();
    List<Property> myProperties;
    try {
      myProperties = await propertyService.fetchMyProperties();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      return;
    }

    if (myProperties.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You have no listings to offer yet. Create one first.')));
      return;
    }

    if (!mounted) return;
    final selected = await showModalBottomSheet<Property>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose a listing to offer', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...myProperties.map((p) => ListTile(
                  title: Text('${p.propertyType[0].toUpperCase()}${p.propertyType.substring(1)} \u2014 ${p.area ?? p.city}'),
                  subtitle: Text('MWK ${p.priceAmount.toStringAsFixed(0)}'),
                  onTap: () => Navigator.of(context).pop(p),
                )),
          ],
        ),
      ),
    );

    if (selected == null) return;

    try {
      await MatchService().submitMatch(requestId: request.id, propertyId: selected.id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offer submitted!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('House Wanted Requests')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Filter by city...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _cityController.clear(); _load(); }),
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _requests.isEmpty
                        ? const Center(child: Text('No open requests right now.'))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              itemCount: _requests.length,
                              itemBuilder: (context, index) {
                                final request = _requests[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${request.propertyType[0].toUpperCase()}${request.propertyType.substring(1)} in ${request.targetArea ?? request.city}', style: Theme.of(context).textTheme.titleMedium),
                                          const SizedBox(height: 6),
                                          Text('Budget: MWK ${request.budgetAmount.toStringAsFixed(0)}/${request.budgetPeriod ?? 'month'}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                                          if (request.notes != null && request.notes!.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(request.notes!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                          ],
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: ElevatedButton(onPressed: () => _submitMatch(request), child: const Text('Offer a Listing')),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}