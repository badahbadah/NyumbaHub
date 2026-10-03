import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import '../../theme/app_theme.dart';
import 'create_listing_screen.dart';
import 'edit_listing_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
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
      final properties = await _service.fetchMyProperties();
      setState(() { _properties = properties; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const CreateListingScreen()));
          if (created == true) _load();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _properties.isEmpty
                  ? const Center(child: Text('You haven\'t listed a property yet. Tap + to add one.'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _properties.length,
                        itemBuilder: (context, index) {
                          final property = _properties[index];
                          final isTaken = property.status == 'taken';
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditListingScreen(property: property)));
                              _load();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${property.propertyType[0].toUpperCase()}${property.propertyType.substring(1)} \u2014 ${property.area ?? property.city}', style: Theme.of(context).textTheme.titleMedium),
                                          const SizedBox(height: 4),
                                          Text('MWK ${property.priceAmount.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: (isTaken ? AppColors.danger : AppColors.success).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                      child: Text(isTaken ? 'TAKEN' : 'AVAILABLE', style: TextStyle(color: isTaken ? AppColors.danger : AppColors.success, fontWeight: FontWeight.w600, fontSize: 11)),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                                  ]),
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