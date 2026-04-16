import 'dart:convert';

/// DiceBear Notionists avatar configuration.
/// Each field maps directly to a DiceBear API parameter.
class AvatarConfig {
  final int hair;        // 0–63 (variant01–variant63) or 64 for hat
  final int eyes;        // 0–4  (variant01–variant05)
  final int brows;       // 0–12 (variant01–variant13)
  final int lips;        // 0–29 (variant01–variant30)
  final int nose;        // 0–19 (variant01–variant20)
  final int body;        // 0–24 (variant01–variant25)
  final int glasses;     // -1 = none, 0–10 (variant01–variant11)
  final int beard;       // -1 = none, 0–11 (variant01–variant12)
  final int gesture;     // -1 = none, 0–9
  final String bgColor;  // hex without #

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
  });

  /// Curated hair presets — 12 best-looking styles from the 64 available.
  /// Keeps the editor manageable while offering variety.
  static const hairPresets = [0, 3, 7, 12, 18, 25, 31, 38, 44, 50, 55, 62];

  /// Curated lips presets — 8 distinct looks.
  static const lipsPresets = [0, 4, 8, 12, 16, 20, 24, 28];

  /// Curated nose presets — 6 distinct looks.
  static const nosePresets = [0, 3, 7, 11, 15, 19];

  /// Curated body/outfit presets — 8 distinct looks.
  static const bodyPresets = [0, 3, 6, 9, 12, 15, 18, 21];

  /// Curated brows presets — 6 distinct looks.
  static const browsPresets = [0, 2, 5, 7, 9, 12];

  /// Gesture options.
  static const gestureNames = [
    'Нет', 'Рука', 'Телефон', 'OK', 'OK (длинная)',
    'Указатель', 'Указатель (длинная)', 'Привет',
    'Привет 2', 'Привет + OK', 'Привет + Указатель',
  ];

  static const _gestureValues = [
    '', 'hand', 'handPhone', 'ok', 'okLongArm',
    'point', 'pointLongArm', 'waveLongArm',
    'waveLongArms', 'waveOkLongArms', 'wavePointLongArms',
  ];

  /// Glasses options.
  static const glassesCount = 11;

  /// Beard options.
  static const beardCount = 12;

  String _variant(int index) {
    final num = (index + 1).toString().padLeft(2, '0');
    return 'variant$num';
  }

  /// Build the DiceBear API URL for this configuration.
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
    if (gesture >= 0 && gesture < _gestureValues.length) {
      final g = _gestureValues[gesture + 1]; // +1 because 0 is "none"
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
