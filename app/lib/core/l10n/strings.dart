/// All spoken and shown texts, in 3 languages.
class S {
  static String t(String lang, String key, {String? n}) {
    final v = _m[key]?[lang] ?? _m[key]?['en'] ?? key;
    return n == null ? v : v.replaceAll('{n}', n);
  }

  static const _m = <String, Map<String, String>>{
    'boot': {
      'fr': 'Assistant prêt. Vert : devant moi. Bleu : répéter. Orange : traverser. Rouge maintenu : SOS.',
      'ar': 'المساعد جاهز. الأخضر: ما أمامي. الأزرق: إعادة. البرتقالي: العبور. الأحمر مع الضغط المطوّل: النجدة.',
      'en': 'Assistant ready. Green: what is ahead. Blue: repeat. Orange: crossing. Hold red: SOS.',
    },
    'connectedSpoken': {
      'fr': 'Lunettes connectées.',
      'ar': 'تم الاتصال بالنظارات.',
      'en': 'Glasses connected.',
    },
    'lost': {
      'fr': 'Connexion perdue. Utilisez votre canne.',
      'ar': 'انقطع الاتصال. استخدم عصاك.',
      'en': 'Connection lost. Use your cane.',
    },
    'sosStart': {
      'fr': 'SOS dans 5 secondes. Touchez l’écran pour annuler.',
      'ar': 'النجدة خلال 5 ثوانٍ. المس الشاشة للإلغاء.',
      'en': 'SOS in 5 seconds. Touch the screen to cancel.',
    },
    'sosCancel': {
      'fr': 'SOS annulé.',
      'ar': 'تم إلغاء النجدة.',
      'en': 'SOS cancelled.',
    },
    'sosTest': {
      'fr': 'SOS déclenché. Test seulement.',
      'ar': 'تم تشغيل النجدة. للتجربة فقط.',
      'en': 'SOS triggered. Test only.',
    },
    'crossIntro': {
      'fr': 'Aide à la traversée. Elle ne remplace pas votre canne ni vos oreilles.',
      'ar': 'مساعدة العبور. لا تغني عن عصاك ولا عن سمعك.',
      'en': 'Crossing aid. It does not replace your cane or your hearing.',
    },
    'crossEnd': {
      'fr': 'Aide à la traversée terminée.',
      'ar': 'انتهت مساعدة العبور.',
      'en': 'Crossing aid finished.',
    },
    'langChanged': {
      'fr': 'Langue : français.',
      'ar': 'اللغة: العربية.',
      'en': 'Language: English.',
    },
    // ---- screen ----
    'ahead': {'fr': 'Devant moi ?', 'ar': 'ما أمامي؟', 'en': 'What is ahead?'},
    'repeat': {'fr': 'Répéter', 'ar': 'إعادة', 'en': 'Repeat'},
    'cross': {'fr': 'Traverser ?', 'ar': 'العبور؟', 'en': 'Cross?'},
    'stopAid': {'fr': 'Arrêter l’aide', 'ar': 'إيقاف المساعدة', 'en': 'Stop aid'},
    'sos': {'fr': 'SOS', 'ar': 'نجدة', 'en': 'SOS'},
    'cancel': {'fr': 'Annuler', 'ar': 'إلغاء', 'en': 'Cancel'},
    'connected': {'fr': 'Connecté', 'ar': 'متصل', 'en': 'Connected'},
    'notConnected': {'fr': 'Non connecté', 'ar': 'غير متصل', 'en': 'Not connected'},
    'received': {'fr': 'Reçus', 'ar': 'المستلمة', 'en': 'Received'},
    'idle': {
      'fr': 'Aucun objet signalé pour l’instant.',
      'ar': 'لا يوجد شيء للإبلاغ عنه حاليًا.',
      'en': 'Nothing to report yet.',
    },
    'connecting': {
      'fr': 'Connexion aux lunettes…',
      'ar': 'جارٍ الاتصال بالنظارات…',
      'en': 'Connecting to the glasses…',
    },
    'sosCount': {
      'fr': 'SOS dans {n}. Touchez pour annuler.',
      'ar': 'النجدة خلال {n}. المس للإلغاء.',
      'en': 'SOS in {n}. Tap to cancel.',
    },
    'unitM': {'fr': 'm', 'ar': 'م', 'en': 'm'},
    'voiceMissing': {
      'fr': 'Voix française non installée. Réglages > Gestion globale > Langue > Synthèse vocale.',
      'ar': 'الصوت العربي غير مثبّت. الإعدادات > الإدارة العامة > اللغة > تحويل النص إلى كلام.',
      'en': 'Voice not installed. Settings > General management > Language > Text-to-speech.',
    },
    'semAhead': {
      'fr': 'Dire ce qu’il y a devant moi',
      'ar': 'قول ما هو أمامي',
      'en': 'Say what is in front of me',
    },
    'semRepeat': {
      'fr': 'Répéter la dernière alerte',
      'ar': 'إعادة آخر تنبيه',
      'en': 'Repeat the last alert',
    },
    'semCross': {
      'fr': 'Aide à la traversée. Information seulement.',
      'ar': 'مساعدة العبور. معلومات فقط.',
      'en': 'Crossing aid. Information only.',
    },
    'semStopAid': {
      'fr': 'Arrêter l’aide à la traversée',
      'ar': 'إيقاف مساعدة العبور',
      'en': 'Stop the crossing aid',
    },
    'semSos': {
      'fr': 'SOS. Maintenez appuyé. Touchez pour annuler.',
      'ar': 'نجدة. اضغط مطوّلًا للإرسال. المس للإلغاء.',
      'en': 'SOS. Press and hold to send. Touch to cancel.',
    },
    'semLang': {
      'fr': 'Changer de langue',
      'ar': 'تغيير اللغة',
      'en': 'Change language',
    },
  };
}