import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';

class NotifToggle extends StatelessWidget {
  const NotifToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = value ? _activeColor : Colors.grey.shade400;
    final bg = value ? _activeColor.withAlpha(20) : Colors.grey.shade100;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: bg,
          border: Border.all(color: color.withAlpha(80), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            SizedBox(width: 3.w),
            Text(
              label,
              style: StyleThemeData.size10Weight700(color: color),
            ),
          ],
        ),
      ),
    );
  }

  static const Color _activeColor = Color(0xFF4A6FA5);
}
