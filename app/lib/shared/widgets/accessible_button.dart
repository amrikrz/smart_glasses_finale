import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccessibleButton extends StatelessWidget {
  final String semanticLabel; // read by TalkBack
  final String text;          // shown on screen
  final IconData icon;
  final Color color;
  final Color onColor;
  final bool outlined;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  const AccessibleButton({
    super.key,
    required this.semanticLabel,
    required this.text,
    required this.icon,
    required this.color,
    this.onColor = const Color(0xFF0A1A2F),
    this.outlined = false,
    this.onPressed,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final fg = outlined ? color : onColor;
    final radius = BorderRadius.circular(24);
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onPressed,
      onLongPress: onLongPress,
      child: Material(
        color: outlined ? Colors.transparent : color,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: outlined ? BorderSide(color: color, width: 3) : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed == null
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onPressed!();
                },
          onLongPress: onLongPress == null
              ? null
              : () {
                  HapticFeedback.heavyImpact();
                  onLongPress!();
                },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 88),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 34, color: fg),
                  const SizedBox(width: 12),
                  Text(text,
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: fg)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}