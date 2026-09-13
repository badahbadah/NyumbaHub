import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../theme/app_theme.dart';

class PaymentPendingScreen extends StatefulWidget {
  final String bookingCode;
  final String providerReference;
  final double depositAmount;

  const PaymentPendingScreen({
    super.key,
    required this.bookingCode,
    required this.providerReference,
    required this.depositAmount,
  });

  @override
  State<PaymentPendingScreen> createState() => _PaymentPendingScreenState();
}

class _PaymentPendingScreenState extends State<PaymentPendingScreen> {
  final BookingService _bookingService = BookingService();
  bool _isProcessing = false;
  bool _isConfirmed = false;
  String? _error;

  Future<void> _confirmPayment() async {
    setState(() { _isProcessing = true; _error = null; });
    try {
      await _bookingService.simulateWebhook(
        providerReference: widget.providerReference,
        status: 'success',
      );
      setState(() { _isConfirmed = true; _isProcessing = false; });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _isConfirmed ? _buildSuccessContent() : _buildPendingContent(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPendingContent() {
    return [
      const Icon(Icons.phone_android_rounded, size: 56, color: AppColors.primary),
      const SizedBox(height: 20),
      Text('Approve MWK ${widget.depositAmount.toStringAsFixed(0)} on your phone',
          textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      const Text(
        'A payment prompt has been sent to your mobile money number. Approve it to confirm your booking.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary),
      ),
      const SizedBox(height: 32),
      const Divider(),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text(
              'Test mode — no real payment aggregator connected yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isProcessing ? null : _confirmPayment,
                child: _isProcessing
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simulate Payment Approval'),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildSuccessContent() {
    return [
      const Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success),
      const SizedBox(height: 20),
      Text('Booking Confirmed!', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      Text('Booking code', style: Theme.of(context).textTheme.bodySmall),
      Text(widget.bookingCode, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      const SizedBox(height: 28),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: const Text('Done'),
        ),
      ),
    ];
  }
}