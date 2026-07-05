import 'package:flutter/material.dart';
import 'package:levl/shared/models/avatar_config.dart';
import 'package:levl/shared/widgets/premium_face_avatar_widget.dart';

void main() {
  runApp(const AvatarPreviewApp());
}

class AvatarPreviewApp extends StatelessWidget {
  const AvatarPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF4F4F1),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Heading('Skin tones across all hairstyles'),
              const SizedBox(height: 16),
              for (var hair = 0;
                  hair < AvatarConfig.premiumHairStyleCount;
                  hair++) ...[
                _VariantRow(
                  label: 'Hair ${hair + 1}',
                  configs: [
                    for (var tone = 0;
                        tone < AvatarConfig.premiumSkinToneCount;
                        tone++)
                      AvatarConfig(hair: hair, skinTone: tone),
                  ],
                ),
                const SizedBox(height: 18),
              ],
              const SizedBox(height: 24),
              const _Heading('Eye colors'),
              const SizedBox(height: 16),
              const _VariantRow(
                label: 'Brown / blue-grey / green',
                avatarSize: 220,
                configs: [
                  AvatarConfig(eyeColor: 0),
                  AvatarConfig(eyeColor: 1),
                  AvatarConfig(eyeColor: 2),
                ],
              ),
              const SizedBox(height: 34),
              const _Heading('Eyebrow shapes'),
              const SizedBox(height: 16),
              const _VariantRow(
                label: 'Natural / straight / full / focused',
                avatarSize: 210,
                configs: [
                  AvatarConfig(brows: 0),
                  AvatarConfig(brows: 1),
                  AvatarConfig(brows: 2),
                  AvatarConfig(brows: 3),
                ],
              ),
            ],
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
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: Color(0xFF171A1A),
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  final String label;
  final List<AvatarConfig> configs;
  final double avatarSize;

  const _VariantRow({
    required this.label,
    required this.configs,
    this.avatarSize = 170,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 180,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF454B4B),
            ),
          ),
        ),
        for (final config in configs)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PremiumFaceAvatarWidget(
              config: config,
              size: avatarSize,
              showFrame: false,
              compact: true,
              animate: false,
            ),
          ),
      ],
    );
  }
}
