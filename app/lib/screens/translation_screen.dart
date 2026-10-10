import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../shared/widgets/ui.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});
  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  static const _langs = ['Anglais', 'Français', 'Arabe'];
  static const _results = {
    'Anglais': 'No parking any time',
    'Français': 'Stationnement interdit à tout moment',
    'Arabe': 'ممنوع الوقوف في أي وقت',
  };
  String _from = 'Anglais';
  String _to = 'Arabe';

  void _swap() => setState(() {
        final t = _from;
        _from = _to;
        _to = t;
      });

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      // camera placeholder (replace with real frames later)
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2F4F3A), Color(0xFF1E3326), Color(0xFF3A3A2C)],
          ),
        ),
      ),

      // detected sign
      Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            color: C.primary,
            child: const Text('Panneau détecté',
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 1.5)),
            child: Container(
              width: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC62828), width: 5),
              ),
              child: const Column(children: [
                Text('NO',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFC62828))),
                Text('PARKING\nANY\nTIME',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFC62828))),
              ]),
            ),
          ),
        ]),
      ),

      // top pills
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _glass(const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.access_time, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text('12:46 AM',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ])),
            _glass(const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.battery_5_bar, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text('87%', style: TextStyle(color: Colors.white, fontSize: 12)),
            ])),
          ]),
        ),
      ),

      // bottom panel
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // result
            Semantics(
              liveRegion: true,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Directionality(
                  textDirection:
                      _to == 'Arabe' ? TextDirection.rtl : TextDirection.ltr,
                  child: Text(_results[_to]!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // languages
            Row(children: [
              Expanded(child: _langBox('De', _from, (v) => setState(() => _from = v))),
              const SizedBox(width: 10),
              RoundIconButton(
                icon: Icons.swap_horiz,
                label: 'Inverser les langues',
                size: 40,
                bg: Colors.black54,
                fg: Colors.white,
                onTap: _swap,
              ),
              const SizedBox(width: 10),
              Expanded(child: _langBox('Vers', _to, (v) => setState(() => _to = v))),
            ]),
            const SizedBox(height: 14),

            // controls
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const RoundIconButton(
                  icon: Icons.edit_outlined,
                  label: 'Saisir du texte',
                  bg: Colors.black54,
                  fg: Colors.white),
              const SizedBox(width: 22),
              Semantics(
                button: true,
                label: 'Parler',
                excludeSemantics: true,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: C.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38, width: 3),
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 22),
              const RoundIconButton(
                  icon: Icons.photo_camera_outlined,
                  label: 'Prendre une photo',
                  bg: Colors.black54,
                  fg: Colors.white),
            ]),
          ]),
        ),
      ),
    ]);
  }

  Widget _glass(Widget child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
            color: Colors.black54, borderRadius: BorderRadius.circular(999)),
        child: child,
      );

  Widget _langBox(String label, String value, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.white60)),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          underline: const SizedBox.shrink(),
          dropdownColor: C.ink,
          iconEnabledColor: Colors.white70,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          items: [
            for (final l in _langs) DropdownMenuItem(value: l, child: Text(l))
          ],
          onChanged: (v) => onChanged(v!),
        ),
      ]),
    );
  }
}