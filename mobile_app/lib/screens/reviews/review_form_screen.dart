import 'package:flutter/material.dart';
import '../../services/review_service.dart';
import '../../theme/app_theme.dart';

class ReviewFormScreen extends StatefulWidget {
  final int hostelId;
  const ReviewFormScreen({super.key, required this.hostelId});

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final ReviewService _reviewService = ReviewService();
  final _commentController = TextEditingController();

  int _water = 3, _electricity = 3, _safety = 3, _responsiveness = 3;
  bool _isSubmitting = false;
  String? _error;

  Future<void> _submit() async {
    setState(() { _isSubmitting = true; _error = null; });
    try {
      await _reviewService.submitReview(
        hostelId: widget.hostelId,
        waterRating: _water,
        electricityRating: _electricity,
        safetyRating: _safety,
        responsivenessRating: _responsiveness,
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      );
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
      appBar: AppBar(title: const Text('Leave a Review')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _ratingSlider('Water backup', _water, (v) => setState(() => _water = v)),
          _ratingSlider('Electricity backup', _electricity, (v) => setState(() => _electricity = v)),
          _ratingSlider('Safety', _safety, (v) => setState(() => _safety = v)),
          _ratingSlider('Landlord responsiveness', _responsiveness, (v) => setState(() => _responsiveness = v)),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Comment (optional)', alignLabelWithHint: true),
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
                : const Text('Submit Review'),
          ),
        ],
      ),
    );
  }

  Widget _ratingSlider(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text('$value / 5', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 1, max: 5, divisions: 4,
            activeColor: AppColors.primary,
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}