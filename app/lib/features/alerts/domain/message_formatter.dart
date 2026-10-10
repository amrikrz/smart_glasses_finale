import 'detection.dart';
import 'labels.dart';

class MessageFormatter {
  final String lang; // en | fr | ar
  const MessageFormatter(this.lang);

  static const _dir = {
    'en': {'left': 'on your left', 'front': 'in front', 'right': 'on your right'},
    'fr': {'left': 'à gauche', 'front': 'devant', 'right': 'à droite'},
    'ar': {'left': 'على يسارك', 'front': 'أمامك', 'right': 'على يمينك'},
  };
  static const _veryClose = {'en': 'very close', 'fr': 'très proche', 'ar': 'قريب جدًا'};
  static const _stop = {'en': 'Stop!', 'fr': 'Stop !', 'ar': 'قف!'};
  static const _none = {
    'en': 'No objects detected.',
    'fr': 'Aucun objet détecté.',
    'ar': 'لم يتم اكتشاف أي شيء.',
  };

  /// Distance rounded to the nearest half meter.
  String _dist(double m) {
    final r = (m * 2).round() / 2;
    if (r <= 0.5) return _veryClose[lang]!;
    if (lang == 'ar') return _distAr(r);
    final one = r == 1.0;
    var n = r == r.roundToDouble() ? r.toInt().toString() : r.toString();
    if (lang == 'fr') {
      n = n.replaceAll('.', ',');
      return '$n ${one ? 'mètre' : 'mètres'}';
    }
    return '$n ${one ? 'meter' : 'meters'}';
  }

  String _distAr(double r) {
    final whole = r.floor();
    final half = r - whole >= 0.5;
    String w;
    if (whole == 1) {
      w = half ? 'متر' : 'متر واحد';
    } else if (whole == 2) {
      w = 'مترين';
    } else if (whole <= 10) {
      w = '$whole أمتار';
    } else {
      w = '$whole مترًا';
    }
    return half ? '$w ونصف' : w;
  }

  /// Order: what, where, how far.
  String format(Detection d) {
    final label = translateLabel(lang, d.label);
    final dir = _dir[lang]![d.direction] ?? d.direction;
    final base = '$label، $dir، ${_dist(d.distanceM)}';
    return d.danger == Danger.high ? '${_stop[lang]} $base' : base;
  }

  String describeScene(List<Detection> all) {
    if (all.isEmpty) return _none[lang]!;
    final sorted = [...all]..sort((a, b) => a.distanceM.compareTo(b.distanceM));
    return sorted.take(5).map(format).join('. ');
  }
}