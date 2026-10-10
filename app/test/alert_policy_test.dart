import 'package:flutter_test/flutter_test.dart';
import 'package:smart_vision_assistant/features/alerts/domain/alert_policy.dart';
import 'package:smart_vision_assistant/features/alerts/domain/detection.dart';

Detection d(String l, Danger dg, double m) => Detection(
    id: 1, label: l, confidence: .9, direction: 'front',
    distanceM: m, danger: dg);

void main() {
  test('high danger sorted first', () {
    final p = AlertPolicy();
    final r = p.filter([d('chair', Danger.medium, 2), d('car', Danger.high, .5)]);
    expect(r.first.label, 'car');
  });

  test('medium alert is blocked inside the cooldown', () {
    final p = AlertPolicy();
    final t = DateTime(2026);
    p.filter([d('chair', Danger.medium, 2)], now: t);
    final again = p.filter([d('chair', Danger.medium, 2)],
        now: t.add(const Duration(seconds: 1)));
    expect(again, isEmpty);
  });

  test('high danger is never blocked', () {
    final p = AlertPolicy();
    final t = DateTime(2026);
    p.filter([d('car', Danger.high, .5)], now: t);
    final again = p.filter([d('car', Danger.high, .5)],
        now: t.add(const Duration(seconds: 1)));
    expect(again.length, 1);
  });
}