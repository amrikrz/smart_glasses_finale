import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../shared/widgets/ui.dart';

class VisioAiScreen extends StatefulWidget {
  const VisioAiScreen({super.key});
  @override
  State<VisioAiScreen> createState() => _VisioAiScreenState();
}

class _VisioAiScreenState extends State<VisioAiScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<(String, bool)> _messages = [
    ('Bonjour ! Je suis VisioAI. Je peux vous aider avec la navigation, la '
        'traduction, les capteurs ou toute question. Comment puis-je vous aider ?',
        false),
  ];
  static const _quick = ['Comment ça marche ?', 'Détecter les obstacles', 'Aide'];

  String _answer(String q) {
    final s = q.toLowerCase();
    if (s.contains('obstacle')) {
      return 'Les lunettes détectent les objets devant vous avec YOLO et vous '
          'préviennent par la voix et la vibration, du plus proche au plus lointain.';
    }
    if (s.contains('comment')) {
      return 'Les lunettes filment, le Raspberry Pi analyse l’image, et '
          'l’application vous parle. L’alerte fonctionne sans internet.';
    }
    if (s.contains('aide')) {
      return 'Dites « Qu’y a-t-il devant moi ? » ou maintenez le bouton SOS '
          'pour prévenir un proche.';
    }
    return 'Je peux vous aider avec la navigation, la traduction et les '
        'capteurs. Pouvez-vous préciser votre question ?';
  }

  void _send(String text) {
    final q = text.trim();
    if (q.isEmpty) return;
    setState(() {
      _messages.add((q, true));
      _messages.add((_answer(q), false)); // TODO: call your backend (Claude API)
    });
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Row(children: [
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Propulsé par Claude',
                    style: TextStyle(fontSize: 12, color: C.muted)),
                Text('VisioAI',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              ]),
            ),
            const Pill(text: 'En ligne', fg: C.green, bg: C.greenSoft, dot: true),
          ]),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _quick.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) =>
                ChipButton(label: _quick[i], onTap: () => _send(_quick[i])),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(20),
            itemCount: _messages.length,
            itemBuilder: (_, i) {
              final (text, mine) = _messages[i];
              return Align(
                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78),
                  decoration: BoxDecoration(
                    color: mine ? C.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: mine ? null : Border.all(color: C.border),
                  ),
                  child: Text(text,
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: mine ? Colors.white : C.ink)),
                ),
              );
            },
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                onSubmitted: _send,
                decoration: InputDecoration(
                  hintText: 'Posez votre question...',
                  filled: true,
                  fillColor: C.bg,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Semantics(
              button: true,
              label: 'Envoyer',
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () => _send(_ctrl.text),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: C.primary, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}