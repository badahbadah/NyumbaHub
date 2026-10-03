import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/property_service.dart';
import '../../services/property_media_service.dart';
import '../../theme/app_theme.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final PropertyService _propertyService = PropertyService();
  final PropertyMediaService _mediaService = PropertyMediaService();
  final ImagePicker _picker = ImagePicker();

  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _listingType = 'rent';
  String _propertyType = 'house';
  String _pricePeriod = 'month';
  bool _isFenced = false, _hasWaterTank = false, _isPaved = false;
  final List<File> _photos = [];
  bool _isSubmitting = false;
  String? _error;

  Future<void> _pickPhotos() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) setState(() => _photos.addAll(picked.map((x) => File(x.path))));
  }

  Future<void> _submit() async {
    final price = double.tryParse(_priceController.text.trim());
    if (_cityController.text.trim().isEmpty) { setState(() => _error = 'City is required'); return; }
    if (price == null || price <= 0) { setState(() => _error = 'Enter a valid price'); return; }

    setState(() { _isSubmitting = true; _error = null; });
    try {
      final property = await _propertyService.createProperty(
        listingType: _listingType,
        propertyType: _propertyType,
        city: _cityController.text.trim(),
        area: _areaController.text.trim().isEmpty ? null : _areaController.text.trim(),
        bedrooms: int.tryParse(_bedroomsController.text.trim()),
        bathrooms: int.tryParse(_bathroomsController.text.trim()),
        priceAmount: price,
        pricePeriod: _listingType == 'rent' ? _pricePeriod : null,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        isFenced: _isFenced,
        hasWaterTank: _hasWaterTank,
        isPaved: _isPaved,
      );

      if (_photos.isNotEmpty) {
        await _mediaService.uploadPhotos(property.id, _photos);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() { _isSubmitting = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Listing')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _listingType,
                decoration: const InputDecoration(labelText: 'Listing type'),
                items: const [DropdownMenuItem(value: 'rent', child: Text('Rent')), DropdownMenuItem(value: 'sale', child: Text('Sale'))],
                onChanged: (v) => setState(() => _listingType = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _propertyType,
                decoration: const InputDecoration(labelText: 'Property type'),
                items: const [
                  DropdownMenuItem(value: 'house', child: Text('House')),
                  DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                  DropdownMenuItem(value: 'shop', child: Text('Shop')),
                  DropdownMenuItem(value: 'land', child: Text('Land')),
                ],
                onChanged: (v) => setState(() => _propertyType = v!),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'City')),
          const SizedBox(height: 14),
          TextField(controller: _areaController, decoration: const InputDecoration(labelText: 'Area / Neighborhood (optional)')),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: TextField(controller: _bedroomsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bedrooms'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _bathroomsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bathrooms'))),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              flex: 2,
              child: TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: _listingType == 'rent' ? 'Monthly rent (MWK)' : 'Sale price (MWK)')),
            ),
            if (_listingType == 'rent') ...[
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _pricePeriod,
                  decoration: const InputDecoration(labelText: 'Period'),
                  items: const [DropdownMenuItem(value: 'month', child: Text('Month'))],
                  onChanged: (v) => setState(() => _pricePeriod = v!),
                ),
              ),
            ],
          ]),
          const SizedBox(height: 14),
          TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description (optional)', alignLabelWithHint: true)),
          const SizedBox(height: 20),
          Text('Features', style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Fenced', style: TextStyle(fontSize: 14)), value: _isFenced, activeThumbColor: AppColors.primary, onChanged: (v) => setState(() => _isFenced = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Water tank', style: TextStyle(fontSize: 14)), value: _hasWaterTank, activeThumbColor: AppColors.primary, onChanged: (v) => setState(() => _hasWaterTank = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Paved', style: TextStyle(fontSize: 14)), value: _isPaved, activeThumbColor: AppColors.primary, onChanged: (v) => setState(() => _isPaved = v)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Photos (optional)', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(onPressed: _pickPhotos, icon: const Icon(Icons.add_photo_alternate_outlined, size: 18), label: const Text('Add')),
          ]),
          if (_photos.isNotEmpty)
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) => Stack(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_photos[index], width: 90, height: 90, fit: BoxFit.cover)),
                  Positioned(top: 2, right: 2, child: GestureDetector(
                    onTap: () => setState(() => _photos.removeAt(index)),
                    child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                  )),
                ]),
              ),
            ),
          const SizedBox(height: 20),
          if (_error != null) ...[Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)), const SizedBox(height: 12)],
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Create Listing'),
          ),
        ],
      ),
    );
  }
}