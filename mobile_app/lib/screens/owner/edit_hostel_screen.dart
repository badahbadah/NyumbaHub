import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/hostel.dart';
import '../../models/hostel_media.dart';
import '../../models/institution.dart';
import '../../services/hostel_service.dart';
import '../../services/hostel_media_service.dart';
import '../../services/institution_service.dart';
import '../../theme/app_theme.dart';

class EditHostelScreen extends StatefulWidget {
  final Hostel hostel;
  const EditHostelScreen({super.key, required this.hostel});

  @override
  State<EditHostelScreen> createState() => _EditHostelScreenState();
}

class _EditHostelScreenState extends State<EditHostelScreen> {
  final HostelService _hostelService = HostelService();
  final HostelMediaService _mediaService = HostelMediaService();
  final InstitutionService _institutionService = InstitutionService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  List<Institution> _institutions = [];
  int? _selectedInstitutionId;
  late bool _hasWater, _hasElectricity, _hasSecurity, _hasWifi, _hasStudyArea;

  List<HostelMedia> _photos = [];
  final List<File> _newPhotos = [];
  bool _isLoadingPhotos = true;
  bool _isSaving = false;
  int? _deletingPhotoId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hostel.name);
    _descriptionController = TextEditingController(text: widget.hostel.description ?? '');
    _selectedInstitutionId = widget.hostel.institutionId;
    _hasWater = widget.hostel.hasWaterBackup;
    _hasElectricity = widget.hostel.hasElectricityBackup;
    _hasSecurity = widget.hostel.hasSecurity;
    _hasWifi = widget.hostel.hasWifi;
    _hasStudyArea = widget.hostel.hasStudyArea;
    _loadInstitutions();
    _loadPhotos();
  }

  Future<void> _loadInstitutions() async {
    try {
      final institutions = await _institutionService.fetchInstitutions();
      setState(() => _institutions = institutions);
    } catch (_) {}
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoadingPhotos = true);
    try {
      final photos = await _mediaService.fetchMedia(widget.hostel.id);
      setState(() { _photos = photos; _isLoadingPhotos = false; });
    } catch (_) {
      setState(() => _isLoadingPhotos = false);
    }
  }

  Future<void> _deletePhoto(HostelMedia photo) async {
    setState(() => _deletingPhotoId = photo.id);
    try {
      await _mediaService.deletePhoto(widget.hostel.id, photo.id);
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
    setState(() { _isSaving = true; _error = null; });
    try {
      await _hostelService.updateHostel(
        hostelId: widget.hostel.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        institutionId: _selectedInstitutionId,
        hasWaterBackup: _hasWater,
        hasElectricityBackup: _hasElectricity,
        hasSecurity: _hasSecurity,
        hasWifi: _hasWifi,
        hasStudyArea: _hasStudyArea,
      );

      if (_newPhotos.isNotEmpty) {
        await _mediaService.uploadPhotos(widget.hostel.id, _newPhotos);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() { _isSaving = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Hostel')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Hostel name')),
          const SizedBox(height: 14),
          TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true)),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            initialValue: _selectedInstitutionId,
            decoration: const InputDecoration(labelText: 'Targeted institution'),
            items: _institutions.map((inst) => DropdownMenuItem(value: inst.id, child: Text(inst.shortCode))).toList(),
            onChanged: (v) => setState(() => _selectedInstitutionId = v),
          ),
          const SizedBox(height: 20),
          Text('Amenities', style: Theme.of(context).textTheme.titleMedium),
          _amenitySwitch('Water backup', _hasWater, (v) => setState(() => _hasWater = v)),
          _amenitySwitch('Electricity backup', _hasElectricity, (v) => setState(() => _hasElectricity = v)),
          _amenitySwitch('Security', _hasSecurity, (v) => setState(() => _hasSecurity = v)),
          _amenitySwitch('WiFi', _hasWifi, (v) => setState(() => _hasWifi = v)),
          _amenitySwitch('Study area', _hasStudyArea, (v) => setState(() => _hasStudyArea = v)),
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
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(photo.fullUrl, width: 90, height: 90, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 2, right: 2,
                              child: GestureDetector(
                                onTap: isDeleting ? null : () => _deletePhoto(photo),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: isDeleting
                                      ? const SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white))
                                      : const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add More Photos', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(onPressed: _pickNewPhotos, icon: const Icon(Icons.add_photo_alternate_outlined, size: 18), label: const Text('Add')),
            ],
          ),
          if (_newPhotos.isNotEmpty)
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _newPhotos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) => Stack(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_newPhotos[index], width: 90, height: 90, fit: BoxFit.cover)),
                  Positioned(
                    top: 2, right: 2,
                    child: GestureDetector(
                      onTap: () => setState(() => _newPhotos.removeAt(index)),
                      child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                    ),
                  ),
                ]),
              ),
            ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            const SizedBox(height: 12),
          ],
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

  Widget _amenitySwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(label, style: const TextStyle(fontSize: 14)), value: value, activeThumbColor: AppColors.primary, onChanged: onChanged);
  }
}