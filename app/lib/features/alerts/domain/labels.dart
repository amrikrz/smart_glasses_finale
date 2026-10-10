const Map<String, Map<String, String>> kLabels = {
  'fr': {
    'person': 'personne', 'bicycle': 'vélo', 'car': 'voiture',
    'motorcycle': 'moto', 'bus': 'bus', 'truck': 'camion',
    'traffic light': 'feu de circulation', 'stop sign': 'panneau stop',
    'fire hydrant': 'borne d’incendie', 'bench': 'banc', 'bird': 'oiseau',
    'cat': 'chat', 'dog': 'chien', 'horse': 'cheval', 'cow': 'vache',
    'chair': 'chaise', 'couch': 'canapé', 'potted plant': 'plante',
    'bed': 'lit', 'dining table': 'table', 'toilet': 'toilettes',
    'tv': 'télévision', 'laptop': 'ordinateur', 'cell phone': 'téléphone',
    'bottle': 'bouteille', 'cup': 'tasse', 'backpack': 'sac à dos',
    'umbrella': 'parapluie', 'handbag': 'sac à main', 'suitcase': 'valise',
    'sink': 'évier', 'refrigerator': 'réfrigérateur', 'book': 'livre',
    'crosswalk': 'passage piéton', 'ped_red': 'feu piéton rouge',
    'ped_green': 'feu piéton vert', 'pothole': 'trou dans la route',
    'stairs': 'escaliers', 'curb': 'bordure', 'manhole': 'bouche d’égout',
    'pole': 'poteau', 'barrier': 'barrière',
  },
  'ar': {
    'person': 'شخص', 'bicycle': 'دراجة هوائية', 'car': 'سيارة',
    'motorcycle': 'دراجة نارية', 'bus': 'حافلة', 'truck': 'شاحنة',
    'traffic light': 'إشارة مرور', 'stop sign': 'علامة قف',
    'fire hydrant': 'صنبور إطفاء', 'bench': 'مقعد', 'bird': 'طائر',
    'cat': 'قطة', 'dog': 'كلب', 'horse': 'حصان', 'cow': 'بقرة',
    'chair': 'كرسي', 'couch': 'أريكة', 'potted plant': 'نبتة',
    'bed': 'سرير', 'dining table': 'طاولة', 'toilet': 'مرحاض',
    'tv': 'تلفاز', 'laptop': 'حاسوب محمول', 'cell phone': 'هاتف',
    'bottle': 'قارورة', 'cup': 'كوب', 'backpack': 'حقيبة ظهر',
    'umbrella': 'مظلة', 'handbag': 'حقيبة يد', 'suitcase': 'حقيبة سفر',
    'sink': 'مغسلة', 'refrigerator': 'ثلاجة', 'book': 'كتاب',
    'crosswalk': 'ممر مشاة', 'ped_red': 'إشارة مشاة حمراء',
    'ped_green': 'إشارة مشاة خضراء', 'pothole': 'حفرة في الطريق',
    'stairs': 'درج', 'curb': 'حافة الرصيف', 'manhole': 'فتحة صرف',
    'pole': 'عمود', 'barrier': 'حاجز',
  },
};

/// Unknown names stay in English (the voice reads them as they are).
String translateLabel(String lang, String en) => kLabels[lang]?[en] ?? en;