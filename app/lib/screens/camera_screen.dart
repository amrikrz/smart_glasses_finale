import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/alerts/state/alert_notifier.dart';
import '../shared/widgets/ui.dart';
import '../shared/widgets/live_frame.dart';
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});
  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  static const _modes = ['Détection', 'Navigation', 'OCR', 'Traduction'];
  int _mode = 0;
  bool _recording = true;
  bool _vocal = true;
  bool _vibration = true;

  @override
  Widget build(BuildContext context) {
    final latest = ref.watch(alertNotifierProvider).latest;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const ScreenHeader('Contrôleur',
              trailing: Pill(
                  text: 'En direct',
                  fg: C.green,
                  bg: C.greenSoft,
                  dot: true)),

          // preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AspectRatio(
              aspectRatio: 1.45,
              child: Container(
                decoration: BoxDecoration(
                    color: C.ink, borderRadius: BorderRadius.circular(20)),
                child: Stack(children: [
                  const Positioned.fill(
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: LiveFrame()),),
                  if (_recording)
                    const Positioned(
                      top: 14,
                      left: 14,
                      child: Row(children: [
                        Icon(Icons.circle, size: 8, color: C.red),
                        SizedBox(width: 6),
                        Text('REC',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('1080p',
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                  // live detections from the Pi
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 72,
                    child: Wrap(spacing: 6, runSpacing: 6, children: [
                      for (final d in latest.take(3))
                        Pill(
                          text: '${d.label} ${d.distanceM.toStringAsFixed(1)} m',
                          fg: Colors.white,
                          bg: Colors.white24,
                        ),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // AI mode
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionTitle('Mode IA')),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _modes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ChipButton(
                label: _modes[i],
                selected: _mode == i,
                onTap: () => setState(() => _mode = i),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // controls
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const RoundIconButton(icon: Icons.flag_outlined, label: 'Marquer'),
            const SizedBox(width: 24),
            Semantics(
              button: true,
              label: _recording ? 'Arrêter l’enregistrement' : 'Enregistrer',
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () => setState(() => _recording = !_recording),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: C.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: C.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Icon(_recording ? Icons.stop_rounded : Icons.circle,
                      color: Colors.white, size: _recording ? 28 : 16),
                ),
              ),
            ),
            const SizedBox(width: 24),
            const RoundIconButton(icon: Icons.grid_view_rounded, label: 'Grille'),
          ]),
          const SizedBox(height: 22),

          // toggles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _tile(Icons.mic_none, C.primary, C.primarySoft, 'Vocal',
                    _vocal ? 'Actif' : 'Inactif',
                    () => setState(() => _vocal = !_vocal)),
                _tile(Icons.my_location, C.green, C.greenSoft, 'GPS',
                    '12m précision', null),
                _tile(Icons.bolt, C.orange, C.orangeSoft, 'Vibration',
                    _vibration ? 'Activée' : 'Désactivée',
                    () => setState(() => _vibration = !_vibration)),
                _tile(Icons.translate, C.purple, C.purpleSoft, 'Traduction',
                    'EN → AR', null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, Color fg, Color bg, String title, String sub,
      VoidCallback? onTap) {
    return AppCard(
      onTap: onTap,
      child: Row(children: [
        IconBox(icon: icon, fg: fg, bg: bg, size: 36),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                Text(sub, style: const TextStyle(fontSize: 12, color: C.muted)),
              ]),
        ),
      ]),
    );
  }
}