import '../../../core/constants/app_constants.dart';
import 'detection.dart';

class AlertPolicy {
  final Duration cooldown;
  final int maxItems;
  final Map<String, DateTime> _lastSpoken = {};

  AlertPolicy({
    this.cooldown = AppConstants.alertCooldown,
    this.maxItems = AppConstants.maxSpokenObjects,
  });

  List<Detection> filter(List<Detection> input, {DateTime? now}) {
    final t = now ?? DateTime.now();

    final sorted = [...input]..sort((a, b) {
        final byDanger = b.danger.index.compareTo(a.danger.index);
        return byDanger != 0 ? byDanger : a.distanceM.compareTo(b.distanceM);
      });

    final result = <Detection>[];
    for (final d in sorted) {
      if (d.danger == Danger.low) continue; // low = only when asked
      final key = '${d.label}_${d.direction}';
      final last = _lastSpoken[key];
      // high danger is never blocked by the cooldown
      final blocked = d.danger != Danger.high &&
          last != null &&
          t.difference(last) < cooldown;
      if (blocked) continue;
      _lastSpoken[key] = t;
      result.add(d);
      if (result.length >= maxItems) break;
    }
    return result;
  }
}