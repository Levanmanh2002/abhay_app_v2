import 'package:abhay_app_v2/main.dart';
import 'package:flutter/cupertino.dart';

class AppSwitch extends StatelessWidget {
  final bool isActive;
  final Color? activeColor;
  final VoidCallback? onChange;
  final AlignmentGeometry alignment;

  const AppSwitch({
    super.key,
    this.activeColor,
    required this.isActive,
    this.onChange,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.7,
      alignment: alignment,
      child: CupertinoSwitch(
        value: isActive,
        activeTrackColor: activeColor ?? appTheme.green4EColor,
        inactiveTrackColor: appTheme.grayC0Color,
        onChanged: (bool value) {
          onChange?.call();
        },
      ),
    );
  }
}
