enum CrossState { unknown, wait, caution, clear }

class CrossingInfo {
  final CrossState state;
  final String reason;
  final String signal;
  final bool? crosswalk;

  const CrossingInfo({
    this.state = CrossState.unknown,
    this.reason = 'no_data',
    this.signal = 'none',
    this.crosswalk,
  });

  static const unknown = CrossingInfo();

  factory CrossingInfo.fromJson(Map<String, dynamic> j) => CrossingInfo(
        state: CrossState.values.firstWhere((s) => s.name == j['state'],
            orElse: () => CrossState.unknown),
        reason: (j['reason'] ?? '') as String,
        signal: (j['signal'] ?? 'none') as String,
        crosswalk: j['crosswalk'] as bool?,
      );

  String get key => switch (state) {
        CrossState.wait =>
          reason == 'signal_red' ? 'wait_signal_red' : 'wait_vehicle',
        CrossState.caution => 'caution',
        CrossState.clear => 'clear',
        CrossState.unknown => 'unknown',
      };

  static const _msg = {
    'fr': {
      'wait_vehicle': 'Attendez. Véhicule proche ou qui approche.',
      'wait_signal_red': 'Attendez. Feu rouge.',
      'caution': 'Attention. Véhicule visible. Attendez.',
      'clear':
          'Aucun véhicule détecté devant. Écoutez la circulation avant de traverser.',
      'unknown': 'Je ne peux pas évaluer. Ne traversez pas sans aide.',
    },
    'en': {
      'wait_vehicle': 'Wait. Vehicle close or approaching.',
      'wait_signal_red': 'Wait. Red light.',
      'caution': 'Careful. Vehicle in view. Wait.',
      'clear': 'No vehicle detected ahead. Listen to the traffic before crossing.',
      'unknown': 'I cannot assess this. Do not cross without help.',
    },
    'ar': {
      'wait_vehicle': 'انتظر. مركبة قريبة أو تقترب.',
      'wait_signal_red': 'انتظر. الإشارة حمراء.',
      'caution': 'انتبه. توجد مركبة. انتظر.',
      'clear': 'لا توجد مركبة أمامك. استمع إلى حركة المرور قبل العبور.',
      'unknown': 'لا أستطيع التقييم. لا تعبر دون مساعدة.',
    },
  };

  String message(String lang) => _msg[lang]?[key] ?? _msg['fr']![key]!;
}