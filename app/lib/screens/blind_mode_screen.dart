import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../features/alerts/domain/crossing.dart';
import '../features/alerts/domain/detection.dart';
import '../features/alerts/domain/labels.dart';
import '../features/alerts/state/alert_notifier.dart';
import '../features/connection/domain/pi_repository.dart';
import '../shared/widgets/live_frame.dart';
import '../shared/widgets/phone_camera_sender.dart';
import '../shell/main_shell.dart';

class BlindModeScreen extends ConsumerStatefulWidget {
  const BlindModeScreen({super.key});
  @override
  ConsumerState<BlindModeScreen> createState() => _BlindModeScreenState();
}

class _BlindModeScreenState extends ConsumerState<BlindModeScreen> {
  static const _langs = ['ar', 'fr', 'en'];
  static const _langTag = {'ar': 'عربي', 'fr': 'FR', 'en': 'EN'};

  Timer? _sos;
  int _count = 0;

  String get _lang => ref.read(languageProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final n = ref.read(alertNotifierProvider.notifier);
    await n.start();
    if (!ref.read(alertNotifierProvider).voiceMissing) await n.say('boot');
  }

  void _cycleLang() {
    final next = _langs[(_langs.indexOf(_lang) + 1) % _langs.length];
    ref.read(alertNotifierProvider.notifier).setLanguage(next);
  }

  void _startSos() {
    if (_sos != null) return;
    final n = ref.read(alertNotifierProvider.notifier);
    HapticFeedback.heavyImpact();
    setState(() => _count = 5);
    n.say('sosStart');
    _sos = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _count--);
      if (_count <= 0) {
        t.cancel();
        _sos = null;
        // TODO: real SOS (GPS + push + SMS)
        n.say('sosTest');
      }
    });
  }

  void _cancelSos() {
    if (_sos == null) return;
    _sos!.cancel();
    _sos = null;
    setState(() => _count = 0);
    ref.read(alertNotifierProvider.notifier).say('sosCancel');
  }

  @override
  void dispose() {
    _sos?.cancel();
    super.dispose();
  }

  Color _dangerColor(Danger d) => switch (d) {
        Danger.high => C.red,
        Danger.medium => const Color(0xFFD97706),
        Danger.low => const Color(0xFF15803D),
      };

  Color _crossColor(CrossState s) => switch (s) {
        CrossState.wait => C.red,
        CrossState.caution => const Color(0xFFD97706),
        CrossState.clear => const Color(0xFF15803D),
        CrossState.unknown => const Color(0xFF475569),
      };

  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(alertNotifierProvider);
    final status =
        ref.watch(connectionStatusProvider).value ?? PiStatus.disconnected;
    final lang = ref.watch(languageProvider);
    final notifier = ref.read(alertNotifierProvider.notifier);
    final connected = status == PiStatus.connected;
    String t(String k) => S.t(lang, k);

    ref.listen<AsyncValue<PiStatus>>(connectionStatusProvider, (prev, next) {
      final was = prev?.value == PiStatus.connected;
      final now = next.value == PiStatus.connected;
      if (now && !was) notifier.say('connectedSpoken');
      if (!now && was) {
        HapticFeedback.heavyImpact();
        notifier.say('lost');
      }
    });

    final message = _count > 0
        ? S.t(lang, 'sosCount', n: '$_count')
        : alerts.lastMessage.isNotEmpty
            ? alerts.lastMessage
            : connected
                ? t('idle')
                : t('connecting');

    return Scaffold(
      backgroundColor: C.ink,
      body: Stack(children: [
        const Positioned.fill(child: ColoredBox(color: C.ink, child: LiveFrame())),
        const Positioned(left: 12, top: 120, child: PhoneCameraSender()),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 130,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Column(children: [
            // top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
              child: Row(children: [
                _glass(Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.circle,
                      size: 10,
                      color: connected ? const Color(0xFF4ADE80) : C.orange),
                  const SizedBox(width: 6),
                  Text(connected ? t('connected') : t('notConnected'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ])),
                const SizedBox(width: 6),
                _glass(Text('${t('received')}: ${alerts.frames}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12))),
                const Spacer(),
                Semantics(
                  button: true,
                  label: t('semLang'),
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: _cycleLang,
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: C.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(_langTag[lang]!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Semantics(
                  button: true,
                  label: 'Companion',
                  excludeSemantics: true,
                  child: IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                    icon: const Icon(Icons.dashboard_outlined, color: Colors.white),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MainShell())),
                  ),
                ),
              ]),
            ),
            const Spacer(),

            // bottom panel (right-to-left for Arabic)
            Directionality(
              textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (alerts.voiceMissing)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB45309),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(t('voiceMissing'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ),
                    if (alerts.crossingActive)
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _crossColor(alerts.crossing.state),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(alerts.crossing.message(lang),
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.3)),
                        ),
                      ),
                    Semantics(
                      liveRegion: true,
                      child: Text(message,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.3)),
                    ),
                    if (alerts.latest.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final d in alerts.latest.take(4))
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _dangerColor(d.danger),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${translateLabel(lang, d.label)} · ${d.distanceM.toStringAsFixed(1)} ${t('unitM')}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                      ]),
                    ],
                    const SizedBox(height: 14),
                    _Action(
                      icon: Icons.directions_walk,
                      text: alerts.crossingActive ? t('stopAid') : t('cross'),
                      semantic:
                          alerts.crossingActive ? t('semStopAid') : t('semCross'),
                      color: const Color(0xFFB45309),
                      onTap: () {
                        _cancelSos();
                        alerts.crossingActive
                            ? notifier.stopCrossing()
                            : notifier.startCrossing();
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: _Action(
                          icon: Icons.visibility,
                          text: t('ahead'),
                          semantic: t('semAhead'),
                          color: C.green,
                          onTap: () {
                            _cancelSos();
                            notifier.describeScene();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Action(
                          icon: Icons.replay,
                          text: t('repeat'),
                          semantic: t('semRepeat'),
                          color: C.primary,
                          onTap: () {
                            _cancelSos();
                            notifier.repeatLast();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Action(
                          icon: Icons.emergency,
                          text: _count > 0 ? t('cancel') : t('sos'),
                          semantic: t('semSos'),
                          color: C.red,
                          onTap: _cancelSos,
                          onLongPress: _startSos,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _glass(Widget child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
            color: Colors.black54, borderRadius: BorderRadius.circular(999)),
        child: child,
      );
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String text;
  final String semantic;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _Action({
    required this.icon,
    required this.text,
    required this.semantic,
    required this.color,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantic,
      excludeSemantics: true,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          onLongPress: onLongPress == null
              ? null
              : () {
                  HapticFeedback.heavyImpact();
                  onLongPress!();
                },
          child: SizedBox(
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 30, color: Colors.white),
                const SizedBox(height: 4),
                Text(text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}