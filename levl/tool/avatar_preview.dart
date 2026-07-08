import 'package:flutter/material.dart';
import 'package:levl/shared/models/avatar_config.dart';
import 'package:levl/shared/widgets/premium_face_avatar_widget.dart';

void main() {
  runApp(const AvatarPreviewApp());
}

class AvatarPreviewApp extends StatelessWidget {
  const AvatarPreviewApp({super.key});

  static const _hairLabels = [
    'Volume',
    'Crop',
    'Side part',
    'Buzz',
    'Slick back',
    'Curly',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF4F4F1),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final groupWidth = (constraints.maxWidth - 56) / 2;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Heading('Skin tones across all hairstyles'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 10,
                      children: [
                        for (var hair = 0;
                            hair < AvatarConfig.premiumHairStyleCount;
                            hair++)
                          SizedBox(
                            width: groupWidth,
                            child: _HairToneGroup(
                              label: _hairLabels[hair],
                              hair: hair,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _DetailGroup(
                            title: 'Eye colors',
                            configs: [
                              AvatarConfig(eyeColor: 0),
                              AvatarConfig(eyeColor: 1),
                              AvatarConfig(eyeColor: 2),
                            ],
                            labels: ['Brown', 'Blue-grey', 'Green'],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _DetailGroup(
                            title: 'Eyebrow shapes',
                            configs: [
                              AvatarConfig(brows: 0),
                              AvatarConfig(brows: 1),
                              AvatarConfig(brows: 2),
                              AvatarConfig(brows: 3),
                            ],
                            labels: ['Natural', 'Straight', 'Full', 'Focused'],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;

  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Color(0xFF171A1A),
      ),
    );
  }
}

class _HairToneGroup extends StatelessWidget {
  final String label;
  final int hair;

  const _HairToneGroup({required this.label, required this.hair});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF454B4B),
            ),
          ),
        ),
        for (var tone = 0; tone < AvatarConfig.premiumSkinToneCount; tone++)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: PremiumFaceAvatarWidget(
              config: AvatarConfig(hair: hair, skinTone: tone),
              size: 108,
              showFrame: false,
              compact: true,
              animate: false,
            ),
          ),
      ],
    );
  }
}

class _DetailGroup extends StatelessWidget {
  final String title;
  final List<AvatarConfig> configs;
  final List<String> labels;

  const _DetailGroup({
    required this.title,
    required this.configs,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF171A1A),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < configs.length; i++)
              _DetailOption(config: configs[i], label: labels[i]),
          ],
        ),
      ],
    );
  }
}

class _DetailOption extends StatelessWidget {
  final AvatarConfig config;
  final String label;

  const _DetailOption({required this.config, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 122,
      child: Column(
        children: [
          PremiumFaceAvatarWidget(
            config: config,
            size: 108,
            showFrame: false,
            compact: true,
            animate: false,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF454B4B),
            ),
          ),
        ],
      ),
    );
  }
}
