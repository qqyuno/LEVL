import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../../../core/theme/app_colors.dart';

part 'saved_place.g.dart';

enum SavedPlaceType { home, work, training, focus }

@Collection()
class SavedPlaceLocal {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  late String name;

  @Enumerated(EnumType.name)
  late SavedPlaceType type;

  late double latitude;
  late double longitude;
  int radiusMeters = 150;
  DateTime createdAt = DateTime.now();

  bool containsCoordinates(double latitude, double longitude) {
    return distanceTo(latitude, longitude) <= radiusMeters;
  }

  double distanceTo(double targetLatitude, double targetLongitude) {
    const earthRadiusMeters = 6371000.0;
    final latitudeDelta = _toRadians(targetLatitude - latitude);
    final longitudeDelta = _toRadians(targetLongitude - longitude);
    final originLatitude = _toRadians(latitude);
    final destinationLatitude = _toRadians(targetLatitude);

    final haversine =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
            math.cos(originLatitude) *
                math.cos(destinationLatitude) *
                math.sin(longitudeDelta / 2) *
                math.sin(longitudeDelta / 2);
    final angle =
        2 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
    return earthRadiusMeters * angle;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
}

extension SavedPlaceTypeVisual on SavedPlaceType {
  String get label => switch (this) {
        SavedPlaceType.home => 'Дом',
        SavedPlaceType.work => 'Работа',
        SavedPlaceType.training => 'Тренировка',
        SavedPlaceType.focus => 'Фокус',
      };

  String get defaultName => switch (this) {
        SavedPlaceType.home => 'Моя база',
        SavedPlaceType.work => 'Рабочая точка',
        SavedPlaceType.training => 'Мой зал',
        SavedPlaceType.focus => 'Точка фокуса',
      };

  IconData get icon => switch (this) {
        SavedPlaceType.home => Icons.home_outlined,
        SavedPlaceType.work => Icons.work_outline,
        SavedPlaceType.training => Icons.fitness_center,
        SavedPlaceType.focus => Icons.center_focus_strong_outlined,
      };

  Color get color => switch (this) {
        SavedPlaceType.home => AppColors.sphereDiscipline,
        SavedPlaceType.work => AppColors.sphereKnowledge,
        SavedPlaceType.training => AppColors.sphereEnergy,
        SavedPlaceType.focus => AppColors.sphereWill,
      };
}
