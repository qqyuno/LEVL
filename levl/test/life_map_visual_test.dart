import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levl/features/dashboard/presentation/providers/quest_provider.dart';
import 'package:levl/features/life_map/domain/saved_place.dart';
import 'package:levl/features/life_map/presentation/providers/saved_places_provider.dart';
import 'package:levl/features/life_map/presentation/screens/life_map_page.dart';
import 'package:levl/shared/models/quest_model.dart';

void main() {
  testWidgets('renders Life Map on a mobile viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questNotifierProvider.overrideWith(_PreviewQuestNotifier.new),
          savedPlacesNotifierProvider.overrideWith(_PreviewPlacesNotifier.new),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LifeMapPage(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();

    expect(find.text('Точка опоры'), findsOneWidget);
    expect(find.text('Мой зал'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _PreviewQuestNotifier extends QuestNotifier {
  @override
  AsyncValue<List<Quest>> build() => const AsyncData([]);
}

class _PreviewPlacesNotifier extends SavedPlacesNotifier {
  @override
  Future<List<SavedPlaceLocal>> build() async => [
        SavedPlaceLocal()
          ..userId = 'preview'
          ..name = 'Мой зал'
          ..type = SavedPlaceType.training
          ..latitude = 55.75
          ..longitude = 37.61,
      ];
}
