import 'dart:convert';

/// A selectable visual reward/style used by the avatar system.
class AvatarStyleOption {
  final String id;
  final String title;
  final String subtitle;
  final int requiredLevel;
  final int requiredStreak;

  const AvatarStyleOption({
    required this.id,
    required this.title,
    required this.subtitle,
    this.requiredLevel = 1,
    this.requiredStreak = 0,
  });

  bool get isAlwaysUnlocked => requiredLevel <= 1 && requiredStreak <= 0;
}

/// DiceBear Notionists avatar configuration + LEVL visual layers.
class AvatarConfig {
  final int hair; // 0-63 (variant01-variant63)
  final int eyes; // 0-4  (variant01-variant05)
  final int brows; // 0-12 (variant01-variant13)
  final int lips; // 0-29 (variant01-variant30)
  final int nose; // 0-19 (variant01-variant20)
  final int body; // 0-24 (variant01-variant25)
  final int glasses; // -1 = none, 0-10 (variant01-variant11)
  final int beard; // -1 = none, 0-11 (variant01-variant12)
  final int gesture; // -1 = none, 0-9
  final String bgColor; // DiceBear hex without #

  // LEVL layers. These make the avatar feel earned, not generated.
  final String backgroundId;
  final String frameId;
  final String auraId;
  final String badgeId;

  const AvatarConfig({
    this.hair = 0,
    this.eyes = 0,
    this.brows = 0,
    this.lips = 0,
    this.nose = 0,
    this.body = 0,
    this.glasses = -1,
    this.beard = -1,
    this.gesture = -1,
    this.bgColor = 'f0f0ed',
    this.backgroundId = 'clean',
    this.frameId = 'system',
    this.auraId = 'none',
    this.badgeId = 'none',
  });

  /// Curated hair presets - keeps the editor useful instead of overwhelming.
  static const hairPresets = [0, 3, 7, 12, 18, 25, 31, 38, 44, 50, 55, 62];
  static const lipsPresets = [0, 4, 8, 12, 16, 20, 24, 28];
  static const nosePresets = [0, 3, 7, 11, 15, 19];
  static const bodyPresets = [0, 3, 6, 9, 12, 15, 18, 21];
  static const browsPresets = [0, 2, 5, 7, 9, 12];

  static const backgroundOptions = [
    AvatarStyleOption(
      id: 'clean',
      title: 'Чистый',
      subtitle: 'База Системы',
    ),
    AvatarStyleOption(
      id: 'paper',
      title: 'Бумага',
      subtitle: 'Мягкий фокус',
    ),
    AvatarStyleOption(
      id: 'gold',
      title: 'Золото',
      subtitle: 'Уровень 3',
      requiredLevel: 3,
    ),
    AvatarStyleOption(
      id: 'night',
      title: 'Ночь',
      subtitle: 'Уровень 5',
      requiredLevel: 5,
    ),
    AvatarStyleOption(
      id: 'signal',
      title: 'Сигнал',
      subtitle: '7 дней подряд',
      requiredStreak: 7,
    ),
  ];

  static const frameOptions = [
    AvatarStyleOption(
      id: 'none',
      title: 'Без рамки',
      subtitle: 'Тишина',
    ),
    AvatarStyleOption(
      id: 'system',
      title: 'Система',
      subtitle: 'Стартовый контур',
    ),
    AvatarStyleOption(
      id: 'gold',
      title: 'Фиксация',
      subtitle: 'Уровень 3',
      requiredLevel: 3,
    ),
    AvatarStyleOption(
      id: 'black',
      title: 'Контроль',
      subtitle: 'Уровень 5',
      requiredLevel: 5,
    ),
    AvatarStyleOption(
      id: 'flame',
      title: 'Ритм',
      subtitle: '7 дней подряд',
      requiredStreak: 7,
    ),
  ];

  static const auraOptions = [
    AvatarStyleOption(
      id: 'none',
      title: 'Без ауры',
      subtitle: 'Спокойный режим',
    ),
    AvatarStyleOption(
      id: 'focus',
      title: 'Фокус',
      subtitle: 'Мягкое свечение',
    ),
    AvatarStyleOption(
      id: 'gold',
      title: 'Импульс',
      subtitle: 'Уровень 4',
      requiredLevel: 4,
    ),
    AvatarStyleOption(
      id: 'flame',
      title: 'Огонь',
      subtitle: '7 дней подряд',
      requiredStreak: 7,
    ),
    AvatarStyleOption(
      id: 'storm',
      title: 'Шторм',
      subtitle: '14 дней подряд',
      requiredStreak: 14,
    ),
  ];

  static const badgeOptions = [
    AvatarStyleOption(
      id: 'none',
      title: 'Без знака',
      subtitle: 'Чистый облик',
    ),
    AvatarStyleOption(
      id: 'first',
      title: 'Первый шаг',
      subtitle: 'Старт пути',
    ),
    AvatarStyleOption(
      id: 'level',
      title: 'Уровень',
      subtitle: 'Уровень 3',
      requiredLevel: 3,
    ),
    AvatarStyleOption(
      id: 'streak',
      title: 'Семь дней',
      subtitle: '7 дней подряд',
      requiredStreak: 7,
    ),
    AvatarStyleOption(
      id: 'system',
      title: 'Знак Системы',
      subtitle: 'Уровень 7',
      requiredLevel: 7,
    ),
  ];

  static const presets = [
    AvatarPreset(
      title: 'Чистый старт',
      subtitle: 'Минимальный облик',
      config: AvatarConfig(backgroundId: 'clean', frameId: 'system'),
    ),
    AvatarPreset(
      title: 'Фокус',
      subtitle: 'Собранный режим',
      config: AvatarConfig(
        hair: 18,
        brows: 5,
        body: 6,
        backgroundId: 'paper',
        frameId: 'black',
        auraId: 'focus',
        badgeId: 'first',
      ),
      requiredLevel: 2,
    ),
    AvatarPreset(
      title: 'Фиксация',
      subtitle: 'Золотой контур',
      config: AvatarConfig(
        hair: 38,
        eyes: 2,
        brows: 7,
        lips: 8,
        body: 12,
        backgroundId: 'gold',
        frameId: 'gold',
        auraId: 'gold',
        badgeId: 'level',
      ),
      requiredLevel: 3,
    ),
    AvatarPreset(
      title: 'Ритм',
      subtitle: 'Для серии дней',
      config: AvatarConfig(
        hair: 55,
        eyes: 1,
        brows: 9,
        body: 18,
        backgroundId: 'signal',
        frameId: 'flame',
        auraId: 'flame',
        badgeId: 'streak',
      ),
      requiredStreak: 7,
    ),
  ];

  static const gestureNames = [
    'Нет',
    'Рука',
    'Телефон',
    'OK',
    'OK long',
    'Указатель',
    'Указатель long',
    'Привет',
    'Привет 2',
    'Привет + OK',
    'Привет + указатель',
  ];

  static const _gestureValues = [
    '',
    'hand',
    'handPhone',
    'ok',
    'okLongArm',
    'point',
    'pointLongArm',
    'waveLongArm',
    'waveLongArms',
    'waveOkLongArms',
    'wavePointLongArms',
  ];

  static const glassesCount = 11;
  static const beardCount = 12;

  String _variant(int index) {
    final num = (index + 1).toString().padLeft(2, '0');
    return 'variant$num';
  }

  String toUrl({int size = 256}) {
    final params = <String, String>{
      'size': '$size',
      'backgroundColor': bgColor,
      'hair': _variant(hair),
      'eyes': _variant(eyes),
      'brows': _variant(brows),
      'lips': _variant(lips),
      'nose': _variant(nose),
      'body': _variant(body),
      'glassesProbability': glasses >= 0 ? '100' : '0',
      'beardProbability': beard >= 0 ? '100' : '0',
      'gestureProbability': gesture >= 0 ? '100' : '0',
    };

    if (glasses >= 0) params['glasses'] = _variant(glasses);
    if (beard >= 0) params['beard'] = _variant(beard);
    if (gesture >= 0 && gesture < _gestureValues.length - 1) {
      final g = _gestureValues[gesture + 1];
      if (g.isNotEmpty) params['gesture'] = g;
    }

    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return 'https://api.dicebear.com/9.x/notionists/svg?$query';
  }

  AvatarConfig copyWith({
    int? hair,
    int? eyes,
    int? brows,
    int? lips,
    int? nose,
    int? body,
    int? glasses,
    int? beard,
    int? gesture,
    String? bgColor,
    String? backgroundId,
    String? frameId,
    String? auraId,
    String? badgeId,
  }) {
    return AvatarConfig(
      hair: hair ?? this.hair,
      eyes: eyes ?? this.eyes,
      brows: brows ?? this.brows,
      lips: lips ?? this.lips,
      nose: nose ?? this.nose,
      body: body ?? this.body,
      glasses: glasses ?? this.glasses,
      beard: beard ?? this.beard,
      gesture: gesture ?? this.gesture,
      bgColor: bgColor ?? this.bgColor,
      backgroundId: backgroundId ?? this.backgroundId,
      frameId: frameId ?? this.frameId,
      auraId: auraId ?? this.auraId,
      badgeId: badgeId ?? this.badgeId,
    );
  }

  Map<String, dynamic> toJson() => {
        'hair': hair,
        'eyes': eyes,
        'brows': brows,
        'lips': lips,
        'nose': nose,
        'body': body,
        'glasses': glasses,
        'beard': beard,
        'gesture': gesture,
        'bgColor': bgColor,
        'backgroundId': backgroundId,
        'frameId': frameId,
        'auraId': auraId,
        'badgeId': badgeId,
      };

  factory AvatarConfig.fromJson(Map<String, dynamic> json) {
    return AvatarConfig(
      hair: json['hair'] as int? ?? 0,
      eyes: json['eyes'] as int? ?? 0,
      brows: json['brows'] as int? ?? 0,
      lips: json['lips'] as int? ?? 0,
      nose: json['nose'] as int? ?? 0,
      body: json['body'] as int? ?? 0,
      glasses: json['glasses'] as int? ?? -1,
      beard: json['beard'] as int? ?? -1,
      gesture: json['gesture'] as int? ?? -1,
      bgColor: json['bgColor'] as String? ?? 'f0f0ed',
      backgroundId: json['backgroundId'] as String? ?? 'clean',
      frameId: json['frameId'] as String? ?? 'system',
      auraId: json['auraId'] as String? ?? 'none',
      badgeId: json['badgeId'] as String? ?? 'none',
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory AvatarConfig.fromJsonString(String s) {
    try {
      return AvatarConfig.fromJson(jsonDecode(s) as Map<String, dynamic>);
    } catch (_) {
      return const AvatarConfig();
    }
  }
}

class AvatarPreset {
  final String title;
  final String subtitle;
  final AvatarConfig config;
  final int requiredLevel;
  final int requiredStreak;

  const AvatarPreset({
    required this.title,
    required this.subtitle,
    required this.config,
    this.requiredLevel = 1,
    this.requiredStreak = 0,
  });
}
