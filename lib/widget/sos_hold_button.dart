import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// SOS FAB — nút khẩn cấp luôn nổi trên màn hình.
///
/// Design:
/// - Đặt làm floatingActionButton trong Scaffold → không bao giờ bị scroll mất
/// - Pulse animation khi tracking active → thu hút mắt
/// - Giữ 2 giây để confirm → tránh bấm nhầm nhưng đủ nhanh khi khẩn cấp
/// - Progress arc hiển thị đếm ngược trực quan
/// - Haptic feedback mỗi 0.5 giây khi đang giữ → cảm giác đang tiến hành
class SosFab extends StatefulWidget {
  const SosFab({
    super.key,
    required this.onConfirmed,
    this.isTracking = false,
  });

  final VoidCallback onConfirmed;
  final bool isTracking; // pulse chỉ khi đang tracking

  @override
  State<SosFab> createState() => _SosFabState();
}

class _SosFabState extends State<SosFab> with TickerProviderStateMixin {
  // Progress khi đang giữ
  late final AnimationController _progressCtrl;

  // Pulse animation khi tracking
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  bool _isHolding = false;
  Timer? _hapticTimer;

  static const Duration _holdDuration = Duration(seconds: 2);
  static const double _btnSize = 68.0;
  static const Color _sosRed = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _onComplete();
      });

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    if (widget.isTracking) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(SosFab old) {
    super.didUpdateWidget(old);
    if (widget.isTracking && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isTracking && _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _pulseCtrl.dispose();
    _hapticTimer?.cancel();
    super.dispose();
  }

  // ─── Hold logic ───────────────────────────────────────────────────────────

  void _onHoldStart() {
    if (!widget.isTracking) {
      HapticFeedback.lightImpact();
      Get.snackbar(
        '',
        'sos_not_tracking'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        duration: const Duration(seconds: 2),
        borderRadius: 12,
      );
      return;
    }

    setState(() => _isHolding = true);
    _pulseCtrl.stop(); // dừng pulse khi đang hold
    HapticFeedback.mediumImpact();
    _progressCtrl.forward(from: 0);

    // Haptic mỗi 0.5s khi đang giữ — cảm giác đang tiến hành
    _hapticTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_isHolding) HapticFeedback.selectionClick();
    });
  }

  void _onHoldEnd() {
    if (!_isHolding) return;
    _hapticTimer?.cancel();
    setState(() => _isHolding = false);
    _progressCtrl.stop();
    _progressCtrl.reset();
    if (widget.isTracking) _pulseCtrl.repeat(reverse: true);
  }

  void _onComplete() {
    _hapticTimer?.cancel();
    if (!_isHolding) return;
    setState(() => _isHolding = false);
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), HapticFeedback.heavyImpact);
    widget.onConfirmed();
    if (widget.isTracking) _pulseCtrl.repeat(reverse: true);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _onHoldStart(),
      onLongPressEnd: (_) => _onHoldEnd(),
      onLongPressCancel: _onHoldEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([_progressCtrl, _pulseAnim]),
        builder: (_, __) {
          final isActive = widget.isTracking;
          final color = isActive ? _sosRed : Colors.grey.shade400;
          final scale = _isHolding ? 1.0 : _pulseAnim.value;

          return Transform.scale(
            scale: scale,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Outer pulse ring (chỉ khi tracking + không hold)
                if (isActive && !_isHolding)
                  Container(
                    width: _btnSize + 22,
                    height: _btnSize + 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _sosRed.withAlpha(
                        (30 * _pulseAnim.value).toInt(),
                      ),
                    ),
                  ),

                // Progress arc khi đang giữ
                if (_isHolding)
                  SizedBox(
                    width: _btnSize + 16,
                    height: _btnSize + 16,
                    child: CircularProgressIndicator(
                      value: _progressCtrl.value,
                      strokeWidth: 5,
                      color: _sosRed,
                      backgroundColor: _sosRed.withAlpha(30),
                      strokeCap: StrokeCap.round,
                    ),
                  ),

                // Main button body
                Container(
                  width: _btnSize,
                  height: _btnSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(_isHolding ? 120 : 80),
                        blurRadius: _isHolding ? 24 : 14,
                        spreadRadius: _isHolding ? 6 : 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sos_rounded,
                        color: Colors.white,
                        size: _isHolding ? 26 : 28,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _isHolding
                            ? '${((_holdDuration.inMilliseconds * (1 - _progressCtrl.value)) / 1000).ceil()}s'
                            : 'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _isHolding ? 13 : 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: _isHolding ? 0 : 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
