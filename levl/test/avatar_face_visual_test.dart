import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levl/shared/models/avatar_config.dart';
import 'package:levl/shared/widgets/premium_face_avatar_widget.dart';

void main() {
  testWidgets('renders avatar face customization sheet', (tester) async {
    tester.view.physicalSize = const Size(1080, 1180);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final previewKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFFF4F4F1),
          body: Center(
            child: RepaintBoundary(
              key: previewKey,
              child: Container(
                width: 1000,
                height: 1100,
                padding: const EdgeInsets.all(32),
                color: const Color(0xFFF4F4F1),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Тон кожи'),
                    SizedBox(height: 12),
                    _VariantRow(
                      configs: [
                        AvatarConfig(skinTone: 0),
                        AvatarConfig(skinTone: 1),
                        AvatarConfig(skinTone: 2),
                        AvatarConfig(skinTone: 3),
                      ],
                      labels: ['Светлый', 'Натуральный', 'Теплый', 'Глубокий'],
                    ),
                    SizedBox(height: 28),
                    _SectionTitle('Брови'),
                    SizedBox(height: 12),
                    _VariantRow(
                      configs: [
                        AvatarConfig(brows: 0),
                        AvatarConfig(brows: 1),
                        AvatarConfig(brows: 2),
                        AvatarConfig(brows: 3),
                      ],
                      labels: ['Естественные', 'Прямые', 'Густые', 'Собранные'],
                    ),
                    SizedBox(height: 28),
                    _SectionTitle('Цвет глаз'),
                    SizedBox(height: 12),
                    _VariantRow(
                      configs: [
                        AvatarConfig(eyeColor: 0),
                        AvatarConfig(eyeColor: 1),
                        AvatarConfig(eyeColor: 2),
                      ],
                      labels: ['Карие', 'Серо-синие', 'Зеленые'],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));

    final boundary =
        previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final output = Platform.environment['AVATAR_PREVIEW_PATH'] ??
        '${Directory.systemTemp.path}\\levl_avatar_preview.png';
    await File(output).writeAsBytes(bytes!.buffer.asUint8List());

    expect(File(output).lengthSync(), greaterThan(1000));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFF171A1A),
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  final List<AvatarConfig> configs;
  final List<String> labels;

  const _VariantRow({required this.configs, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < configs.length; i++)
          Expanded(
            child: Column(
              children: [
                PremiumFaceAvatarWidget(
                  config: configs[i],
                  size: 190,
                  showFrame: false,
                  compact: true,
                  animate: false,
                ),
                const SizedBox(height: 8),
                Text(
                  labels[i],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF454B4B),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
