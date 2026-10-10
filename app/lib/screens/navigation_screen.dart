import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/alerts/domain/detection.dart';
import '../features/alerts/state/alert_notifier.dart';
import '../shared/widgets/ui.dart';

class NavigationScreen extends ConsumerWidget {
  const NavigationScreen({super.key});

  // Replace with real GPS routing later
  static const _instruction = 'Tournez à gauche dans 15m — Rue Ibn Badis';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(alertNotifierProvider).latest;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const ScreenHeader('Navigation'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Semantics(
              label: latest.isEmpty
                  ? 'Radar. Aucun objet détecté.'
                  : 'Radar. ${latest.length} objets détectés.',
              excludeSemantics: true,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                    color: C.ink, borderRadius: BorderRadius.circular(20)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _RadarPainter(latest),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // voice instruction
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Semantics(
              liveRegion: true,
              child: AppCard(
                color: C.primarySoft,
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('INSTRUCTION VOCALE',
                        style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                            color: C.primary)),
                    SizedBox(height: 8),
                    Text('“$_instruction”',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.3)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // itinerary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Itinéraire',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                _step(C.primary, 'Position actuelle', 'Place des Martyrs'),
                const Divider(height: 22, color: C.border),
                _step(C.orange, 'Tourner à gauche', 'Rue Ibn Badis · 15m'),
                const Divider(height: 22, color: C.border),
                _step(const Color(0xFFC9CDDB), 'Destination', 'Hôpital Central · 320m',
                    muted: true),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: C.red,
                    side: const BorderSide(color: C.border),
                    backgroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Arrêter',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: C.primary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Recalculer',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _step(Color dot, String title, String sub, {bool muted = false}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: muted ? C.muted : C.ink)),
          Text(sub, style: const TextStyle(fontSize: 12, color: C.muted)),
        ]),
      ),
    ]);
  }
}

class _RadarPainter extends CustomPainter {
  final List<Detection> items;
  _RadarPainter(this.items);

  static const maxM = 4.0;

  double _angle(String dir) => switch (dir) {
        'left' => -50 * pi / 180,
        'right' => 50 * pi / 180,
        _ => 0,
      };

  Color _color(Danger d) => switch (d) {
        Danger.high => C.red,
        Danger.medium => C.orange,
        Danger.low => const Color(0xFF4ADE80),
      };

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = min(size.width, size.height) / 2 - 12;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.12);

    for (final f in [1 / 3, 2 / 3, 1.0]) {
      canvas.drawCircle(c, r * f, line);
    }
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), line);
    canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), line);

    // sweep line
    const sweep = 20 * pi / 180;
    canvas.drawLine(
      c,
      c + Offset(sin(sweep), -cos(sweep)) * r,
      Paint()
        ..color = C.primary
        ..strokeWidth = 2,
    );

    // you
    canvas.drawCircle(c, 7, Paint()..color = Colors.white);
    canvas.drawCircle(
        c, 11, Paint()..color = C.primary.withValues(alpha: 0.4));

    // objects
    for (final d in items) {
      final dist = d.distanceM.clamp(0.3, maxM);
      final a = _angle(d.direction);
      final p = c + Offset(sin(a), -cos(a)) * (r * dist / maxM);
      final col = _color(d.danger);
      canvas.drawCircle(p, 12, Paint()..color = col.withValues(alpha: 0.25));
      canvas.drawCircle(p, 6, Paint()..color = col);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.items != items;
}