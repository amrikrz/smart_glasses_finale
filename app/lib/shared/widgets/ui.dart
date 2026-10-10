import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = C.card,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: C.border),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color fg;
  final Color bg;
  final bool dot;
  const Pill({
    super.key,
    required this.text,
    required this.fg,
    required this.bg,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (dot) ...[
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          const SizedBox(width: 6),
        ],
        Text(text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      ]),
    );
  }
}

class IconBox extends StatelessWidget {
  final IconData icon;
  final Color fg;
  final Color bg;
  final double size;
  const IconBox({
    super.key,
    required this.icon,
    required this.fg,
    required this.bg,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * 0.3)),
        child: Icon(icon, color: fg, size: size * 0.5),
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      );
}

class ScreenHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const ScreenHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        child: Row(children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          ),
          if (trailing != null) trailing!,
        ]),
      );
}

class ChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const ChipButton({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? C.primary : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? C.primary : C.border),
            ),
            child: Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : C.muted,
                )),
          ),
        ),
      );
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final double size;
  final Color bg;
  final Color fg;
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.size = 48,
    this.bg = Colors.white,
    this.fg = C.ink,
  });

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: C.border),
            ),
            child: Icon(icon, color: fg, size: size * 0.45),
          ),
        ),
      );
}