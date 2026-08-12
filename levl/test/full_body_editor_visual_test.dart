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
    String? equippedOutfit;
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
            onEquip: (outfitId) async => equippedOutfit = outfitId,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Студия образа'), findsOneWidget);
    expect(find.text('УР. 4  ·  РИТМ 6'), findsOneWidget);
    expect(find.text('Лицо'), findsOneWidget);
    expect(find.text('Гардероб'), findsOneWidget);
    expect(find.text('Фокус'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Лицо'));
    expect(editFaceTapped, isTrue);

    await tester.drag(find.byType(ListView), const Offset(-180, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('outfit-operator')));
    await tester.pumpAndSettle();
    expect(find.text('Оператор'), findsWidgets);
    expect(find.text('Надеть'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('equip-outfit')));
    await tester.pumpAndSettle();
    expect(equippedOutfit, 'operator');
    expect(find.text('Надето'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(-180, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('outfit-breakthrough')));
    await tester.pumpAndSettle();

    final lockedButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('equip-outfit')),
    );
    expect(lockedButton.onPressed, isNull);
    expect(equippedOutfit, 'operator');
    expect(tester.takeException(), isNull);
  });
}
