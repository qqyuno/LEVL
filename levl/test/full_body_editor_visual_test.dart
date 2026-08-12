import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levl/features/character/presentation/screens/full_body_editor_screen.dart';
import 'package:levl/shared/models/user_model.dart';

void main() {
  testWidgets('renders full-body studio on a mobile viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var editFaceTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FullBodyEditorContent(
            user: const UserProfile(
              id: 'preview',
              name: 'Алекс',
              level: 4,
              currentStreak: 6,
            ),
            onClose: () {},
            onEditFace: () => editFaceTapped = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Студия образа'), findsOneWidget);
    expect(find.text('УР. 4  ·  РИТМ 6'), findsOneWidget);
    expect(find.text('Лицо'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Лицо'));
    expect(editFaceTapped, isTrue);
  });
}
