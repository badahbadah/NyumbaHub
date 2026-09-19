import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PhotoSlideshow extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final Duration autoPlayInterval;

  const PhotoSlideshow({
    super.key,
    required this.imageUrls,
    this.height = 240,
    this.autoPlayInterval = const Duration(seconds: 4),
  });

  @override
  State<PhotoSlideshow> createState() => _PhotoSlideshowState();
}

class _PhotoSlideshowState extends State<PhotoSlideshow> {
  late final PageController _controller;
  Timer? _timer;
  int _currentIndex = 0;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    if (widget.imageUrls.length > 1) _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoPlayInterval, (_) => _goToNext());
  }

  void _stopAutoPlay() {
    _timer?.cancel();
  }

  void _togglePlayPause() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _startAutoPlay();
    } else {
      _stopAutoPlay();
    }
  }

  void _goToNext() {
    if (widget.imageUrls.isEmpty) return;
    final next = (_currentIndex + 1) % widget.imageUrls.length;
    _controller.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  void _goToPrevious() {
    if (widget.imageUrls.isEmpty) return;
    final prev = (_currentIndex - 1 + widget.imageUrls.length) % widget.imageUrls.length;
    _controller.animateToPage(prev, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  // Manual navigation (arrows or swipe) restarts the auto-play clock,
  // so the next auto-advance doesn't happen right after a user's own action.
  void _onManualInteraction(VoidCallback action) {
    action();
    if (_isPlaying) _startAutoPlay();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: widget.height,
        color: AppColors.divider,
        child: const Center(child: Icon(Icons.apartment, size: 48, color: AppColors.textSecondary)),
      );
    }

    final hasMultiple = widget.imageUrls.length > 1;

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => Image.network(
              widget.imageUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.divider,
                child: const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
              ),
            ),
          ),

          if (hasMultiple) ...[
            // Subtle gradient so white controls stay legible over bright photos
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.45)],
                  ),
                ),
              ),
            ),

            // Previous arrow
            Positioned(
              left: 8, top: 0, bottom: 0,
              child: Center(
                child: _CircleButton(
                  icon: Icons.chevron_left,
                  onTap: () => _onManualInteraction(_goToPrevious),
                ),
              ),
            ),

            // Next arrow
            Positioned(
              right: 8, top: 0, bottom: 0,
              child: Center(
                child: _CircleButton(
                  icon: Icons.chevron_right,
                  onTap: () => _onManualInteraction(_goToNext),
                ),
              ),
            ),

            // Play/pause + dot indicators
            Positioned(
              left: 0, right: 0, bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleButton(
                    icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 30,
                    iconSize: 16,
                    onTap: _togglePlayPause,
                  ),
                  const SizedBox(width: 10),
                  ...List.generate(widget.imageUrls.length, (index) {
                    final isActive = index == _currentIndex;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Photo count badge
            Positioned(
              top: 10, right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '${_currentIndex + 1}/${widget.imageUrls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _CircleButton({required this.icon, required this.onTap, this.size = 34, this.iconSize = 20});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}