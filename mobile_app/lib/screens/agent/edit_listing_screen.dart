import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/property.dart';
import '../../models/property_media.dart';
import '../../services/property_service.dart';
import '../../services/property_media_service.dart';
import '../../theme/app_theme.dart';

class EditListingScreen extends StatefulWidget {
  final Property property;
  const EditListingScreen({super.key, required this.property});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final PropertyService _propertyService = PropertyService();
  final PropertyMediaService _mediaService = PropertyMediaService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _cityController;
  late TextEditingController _areaController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late bool _isFenced, _hasWaterTank, _isPaved;

  List<PropertyMedia> _photos = [];
  final List<File> _newPhotos = [];
  bool _isLoadingPhotos = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  int? _deletingPhotoId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.property.city);
    _areaController = TextEditingController(text: widget.property.area ?? '');
    _priceController = TextEditingController(text: widget.property.priceAmount.toStringAsFixed(0));
    _descriptionController = TextEditingController(text: widget.property.description ?? '');
    _isFenced = widget.property.isFenced;
    _hasWaterTank = widget.property.hasWaterTank;
    _isPaved = widget.property.isPaved;
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoadingPhotos = true);
    try {
      final photos = await _mediaService.fetchMedia(widget.property.id);
      setState(() { _photos = photos; _isLoadingPhotos = false; });
    } catch (_) {
      setState(() => _isLoadingPhotos = false);
    }
  }

  Future<void> _deletePhoto(PropertyMedia photo) async {
    setState(() => _deletingPhotoId = photo.id);
    try {
      await _mediaService.deletePhoto(widget.property.id, photo.id);
      await _loadPhotos();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _deletingPhotoId = null);
    }
  }

  Future<void> _pickNewPhotos() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) setState(() => _newPhotos.addAll(picked.map((x) => File(x.path))));
  }

  Future<void> _save() async {
    final price = double.tryParse(_priceController.text.trim());
    setState(() { _isSaving = true; _error = null; });
    try {
      await _propertyService.updateProperty(widget.property.id, {
        'city': _cityController.text.trim(),
        'area': _areaController.text.trim(),
        'price_amount': ?price,
        'description': _descriptionController.text.trim(),
        'is_fenced': _isFenced,
        'has_water_tank': _hasWaterTank,
        'is_paved': _isPaved,
      });

      if (_newPhotos.isNotEmpty) {
        await _mediaService.uploadPhotos(widget.property.id, _newPhotos);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() { _isSaving = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _toggleTaken() async {
    setState(() => _isSaving = true);
    try {
      await _propertyService.markTaken(widget.property.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing marked as taken')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete listing?'),
        content: const Text('This cannot be undone. Listings with an accepted match cannot be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes, delete')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isDeleting = true);
    try {
      await _propertyService.deleteProperty(widget.property.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _isDeleting = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTaken = widget.property.status == 'taken';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Listing'),
        actions: [
          IconButton(
            icon: _isDeleting ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.delete_outline),
            onPressed: _isDeleting ? null : _delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          OutlinedButton.icon(
            icon: Icon(isTaken ? Icons.check_circle_outline : Icons.block, size: 18),
            label: Text(isTaken ? 'Mark as Available' : 'Mark as Taken'),
            style: OutlinedButton.styleFrom(foregroundColor: isTaken ? AppColors.success : AppColors.danger),
            onPressed: _isSaving ? null : _toggleTaken,
          ),
          const SizedBox(height: 20),
          TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'City')),
          const SizedBox(height: 14),
          TextField(controller: _areaController, decoration: const InputDecoration(labelText: 'Area / Neighborhood')),
          const SizedBox(height: 14),
          TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (MWK)')),
          const SizedBox(height: 14),
          TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true)),
          const SizedBox(height: 20),
          Text('Features', style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Fenced', style: TextStyle(fontSize: 14)), value: _isFenced, activeThumbColor: AppColors.primary, onChanged: (v) => setState(() => _isFenced = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Water tank', style: TextStyle(fontSize: 14)), value: _hasWaterTank, activeThumbColor: AppColors.primary, onChanged: (v) => setState(() => _hasWaterTank = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Paved', style: TextStyle(fontSize: 14)), value: _isPaved, activeThumbColor: AppColors.primary, onChanged: (v) => setState(() => _isPaved = v)),
          const SizedBox(height: 24),
          Text('Current Photos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          _isLoadingPhotos
              ? const LinearProgressIndicator()
              : _photos.isEmpty
                  ? const Text('No photos yet.', style: TextStyle(color: AppColors.textSecondary))
                  : Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _photos.map((photo) {
                        final isDeleting = _deletingPhotoId == photo.id;
                        return Stack(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(photo.fullUrl, width: 90, height: 90, fit: BoxFit.cover)),
                          Positioned(top: 2, right: 2, child: GestureDetector(
                            onTap: isDeleting ? null : () => _deletePhoto(photo),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: isDeleting
                                  ? const SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white))
                                  : const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          )),
                        ]);
                      }).toList(),
                    ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Add More Photos', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(onPressed: _pickNewPhotos, icon: const Icon(Icons.add_photo_alternate_outlined, size: 18), label: const Text('Add')),
          ]),
          if (_newPhotos.isNotEmpty)
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _newPhotos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) => Stack(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_newPhotos[index], width: 90, height: 90, fit: BoxFit.cover)),
                  Positioned(top: 2, right: 2, child: GestureDetector(
                    onTap: () => setState(() => _newPhotos.removeAt(index)),
                    child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                  )),
                ]),
              ),
            ),
          const SizedBox(height: 24),
          if (_error != null) ...[Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)), const SizedBox(height: 12)],
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}