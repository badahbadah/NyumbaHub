import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/institution.dart';
import '../../services/hostel_service.dart';
import '../../services/hostel_media_service.dart';
import '../../services/institution_service.dart';
import '../../theme/app_theme.dart';

class CreateHostelScreen extends StatefulWidget {
  const CreateHostelScreen({super.key});

  @override
  State<CreateHostelScreen> createState() => _CreateHostelScreenState();
}

class _CreateHostelScreenState extends State<CreateHostelScreen> {
  final HostelService _hostelService = HostelService();
  final HostelMediaService _mediaService = HostelMediaService();
  final InstitutionService _institutionService = InstitutionService();
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Institution> _institutions = [];
  int? _selectedInstitutionId;
  final List<File> _photos = [];

  bool _hasWater = false, _hasElectricity = false, _hasSecurity = false, _hasWifi = false, _hasStudyArea = false;
  bool _isSubmitting = false;
  bool _isLoadingInstitutions = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
  }

  Future<void> _loadInstitutions() async {
    try {
      final institutions = await _institutionService.fetchInstitutions();
      setState(() { _institutions = institutions; _isLoadingInstitutions = false; });
    } catch (e) {
      setState(() => _isLoadingInstitutions = false);
    }
  }

  Future<void> _pickPhotos() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        _photos.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Hostel name is required');
      return;
    }
    if (_photos.length < 3) {
      setState(() => _error = 'Please add at least 3 photos of the hostel');
      return;
    }

    setState(() { _isSubmitting = true; _error = null; });
    try {
      final hostel = await _hostelService.createHostel(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        institutionId: _selectedInstitutionId,
        hasWaterBackup: _hasWater,
        hasElectricityBackup: _hasElectricity,
        hasSecurity: _hasSecurity,
        hasWifi: _hasWifi,
        hasStudyArea: _hasStudyArea,
      );

      await _mediaService.uploadPhotos(hostel.id, _photos);

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
      appBar: AppBar(title: const Text('Add Hostel')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Hostel name'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description (optional)', alignLabelWithHint: true),
          ),
          const SizedBox(height: 14),
          _isLoadingInstitutions
              ? const LinearProgressIndicator()
              : DropdownButtonFormField<int>(
                  initialValue: _selectedInstitutionId,
                  decoration: const InputDecoration(labelText: 'Targeted institution (optional)'),
                  items: _institutions
                      .map((inst) => DropdownMenuItem(value: inst.id, child: Text(inst.shortCode)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedInstitutionId = v),
                ),
          const SizedBox(height: 20),
          Text('Amenities', style: Theme.of(context).textTheme.titleMedium),
          _amenitySwitch('Water backup', _hasWater, (v) => setState(() => _hasWater = v)),
          _amenitySwitch('Electricity backup', _hasElectricity, (v) => setState(() => _hasElectricity = v)),
          _amenitySwitch('Security', _hasSecurity, (v) => setState(() => _hasSecurity = v)),
          _amenitySwitch('WiFi', _hasWifi, (v) => setState(() => _hasWifi = v)),
          _amenitySwitch('Study area', _hasStudyArea, (v) => setState(() => _hasStudyArea = v)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Photos (min. 3)', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: _pickPhotos,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          if (_photos.isNotEmpty)
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_photos[index], width: 90, height: 90, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 2, right: 2,
                      child: GestureDetector(
                        onTap: () => setState(() => _photos.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            const SizedBox(height: 12),
          ],
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Create Hostel'),
          ),
        ],
      ),
    );
  }

  Widget _amenitySwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}