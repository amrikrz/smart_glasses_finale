import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/alerts/state/alert_notifier.dart';
import '../features/connection/domain/pi_repository.dart';
import '../shared/widgets/ui.dart';

class HomeScreen extends ConsumerWidget {
  final ValueChanged<int> onOpenTab;
  const HomeScreen({super.key, required this.onOpenTab});

  static const _features = [
    ('Caméra', 'Vue en direct', Icons.videocam_outlined, C.primary, C.primarySoft, 1),
    ('Navigation', 'Guidage vocal', Icons.navigation_outlined, C.green, C.greenSoft, 2),
    ('Traduction', 'Caméra IA', Icons.translate, C.purple, C.purpleSoft, 3),
    ('VisioAI', 'Assistant IA', Icons.auto_awesome_outlined, C.orange, C.orangeSoft, 4),
  ];

  static const _activity = [
    ('Panneau traduit → Arabe', 'il y a 1 min', 'OCR', C.purple, C.purpleSoft),
    ('Objet détecté : chaise', 'il y a 3 min', 'YOLO', C.primary, C.primarySoft),
    ('Navigation terminée', 'il y a 22 min', 'OK', C.green, C.greenSoft),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status =
        ref.watch(connectionStatusProvider).value ?? PiStatus.disconnected;
    final notifier = ref.read(alertNotifierProvider.notifier);
    final connected = status == PiStatus.connected;

    final (pillText, pillColor) = switch (status) {
      PiStatus.connected => ('Connecté', const Color(0xFF4ADE80)),
      PiStatus.connecting => ('Connexion…', C.orange),
      PiStatus.disconnected => ('Toucher pour connecter', C.orange),
    };

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          // header
          Row(children: [
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Bonjour, Ahmed',
                    style: TextStyle(fontSize: 13, color: C.muted)),
                Text('VisioNav',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              ]),
            ),
            Semantics(
              button: true,
              label: 'Notifications',
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: C.border),
                ),
                child: const Icon(Icons.notifications_none, size: 22),
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // glasses card
          Semantics(
            button: !connected,
            label: connected
                ? 'Lunettes VisioGlass Pro connectées'
                : 'Lunettes non connectées. Toucher pour connecter.',
            excludeSemantics: true,
            child: Material(
              color: C.ink,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: connected ? null : notifier.start,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LUNETTES ACTIVES',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8E95B5),
                              )),
                          SizedBox(height: 8),
                          Text('VisioGlass Pro',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                    Pill(
                      text: pillText,
                      fg: pillColor,
                      bg: pillColor.withValues(alpha: 0.15),
                      dot: true,
                    ),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // features
          const SectionTitle('Fonctionnalités'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              for (final f in _features)
                AppCard(
                  onTap: () => onOpenTab(f.$6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconBox(icon: f.$3, fg: f.$4, bg: f.$5),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(f.$1,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        Text(f.$2,
                            style: const TextStyle(fontSize: 12, color: C.muted)),
                      ]),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),

          // recent activity
          const SectionTitle('Activité récente'),
          AppCard(
            child: Column(children: [
              for (var i = 0; i < _activity.length; i++) ...[
                if (i > 0) const Divider(height: 22, color: C.border),
                Row(children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: _activity[i].$4, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_activity[i].$1,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      Text(_activity[i].$2,
                          style: const TextStyle(fontSize: 12, color: C.muted)),
                    ]),
                  ),
                  Pill(text: _activity[i].$3, fg: _activity[i].$4, bg: _activity[i].$5),
                ]),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}