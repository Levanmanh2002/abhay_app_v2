import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/home/home_controller.dart';
import 'package:abhay_app_v2/pages/home/view/home_header_view.dart';
import 'package:abhay_app_v2/pages/home/view/sound_gauge_view.dart';
import 'package:abhay_app_v2/pages/home/view/speed_gauge_view.dart';
import 'package:abhay_app_v2/pages/profile/profile_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:abhay_app_v2/widget/sos_hold_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends GetWidget<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Obx(
        () => SosFab(
          isTracking: controller.isTracking.value,
          onConfirmed: controller.onSosTrigger,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: padding(horizontal: 16, top: 16, bottom: 100),
          child: Column(
            spacing: 16.h,
            children: [
              HomeHeaderView(),
              Obx(() {
                final kw = controller.detectedKeyword.value;
                if (kw == null) return const SizedBox.shrink();
                return _KeywordAlertBanner(
                  keyword: kw,
                  onDismiss: controller.dismissKeywordAlert,
                );
              }),
              SpeedGaugeView(),
              SoundGaugeView(),
              _buildTrackingButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingButton() {
    return Obx(() {
      final isTracking = controller.isTracking.value;
      final isLoading = controller.isTogglingTracking.value;

      return InkWell(
        onTap: isLoading
            ? null
            : () {
                final user = Get.find<ProfileController>().userModel.value;
                controller.onToggleTracking(user);
              },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isTracking ? [appTheme.errorColor, appTheme.red55Color] : [appTheme.appColor, appTheme.blueBFFColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isTracking ? appTheme.errorColor : appTheme.appColor).withAlpha(80),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10.w,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    color: appTheme.whiteColor,
                    strokeWidth: 2,
                  ),
                )
              else
                Icon(
                  isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: appTheme.whiteColor,
                  size: 24.w,
                ),
              Text(
                isLoading
                    ? 'loading'.tr
                    : isTracking
                        ? 'home_stop_tracking'.tr
                        : 'home_start_tracking'.tr,
                style: StyleThemeData.size16Weight700(color: appTheme.whiteColor),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _KeywordAlertBanner extends StatefulWidget {
  const _KeywordAlertBanner({
    required this.keyword,
    required this.onDismiss,
  });

  final String keyword;
  final VoidCallback onDismiss;

  @override
  State<_KeywordAlertBanner> createState() => _KeywordAlertBannerState();
}

class _KeywordAlertBannerState extends State<_KeywordAlertBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String _formatTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD), // amber-50
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon cảnh báo
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300).withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: Color(0xFFB45309),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'voice_keyword_detected'.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF78350F),
                        ),
                        children: [
                          const TextSpan(text: '"'),
                          TextSpan(
                            text: widget.keyword,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(text: '"'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
              // Nút dismiss
              GestureDetector(
                onTap: widget.onDismiss,
                child: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
