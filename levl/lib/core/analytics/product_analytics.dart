import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_service.dart';

enum ProductEvent {
  onboardingCompleted,
  questsGenerated,
  questGenerationFailed,
  verificationStarted,
  locationCheckpointRecorded,
  questCompleted,
  questRejected,
  completionImpactShown,
  lifeMapOpened,
}

final productAnalyticsProvider = Provider<ProductAnalytics>((ref) {
  return ProductAnalytics(ref.watch(supabaseClientProvider));
});

class ProductAnalytics {
  const ProductAnalytics(this._client);

  final SupabaseClient _client;

  Future<void> track(
    ProductEvent event, {
    Map<String, Object?> properties = const {},
  }) async {
    if (_client.auth.currentUser == null) return;

    try {
      await _client.from('product_events').insert({
        'event_name': _eventName(event),
        'properties': sanitizeProperties({
          ...properties,
          'platform': defaultTargetPlatform.name,
        }),
      });
    } catch (_) {
      // Analytics must never block the user's action or offline flow.
    }
  }

  @visibleForTesting
  static Map<String, Object?> sanitizeProperties(
    Map<String, Object?> properties,
  ) {
    final safe = <String, Object?>{};
    for (final entry in properties.entries.take(16)) {
      final key = entry.key.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
      if (key.isEmpty || key.length > 40) continue;
      final value = entry.value;
      if (value == null || value is num || value is bool) {
        safe[key] = value;
      } else if (value is String) {
        safe[key] = value.length <= 80 ? value : value.substring(0, 80);
      }
    }
    return safe;
  }

  String _eventName(ProductEvent event) {
    return switch (event) {
      ProductEvent.onboardingCompleted => 'onboarding_completed',
      ProductEvent.questsGenerated => 'quests_generated',
      ProductEvent.questGenerationFailed => 'quest_generation_failed',
      ProductEvent.verificationStarted => 'verification_started',
      ProductEvent.locationCheckpointRecorded => 'location_checkpoint_recorded',
      ProductEvent.questCompleted => 'quest_completed',
      ProductEvent.questRejected => 'quest_rejected',
      ProductEvent.completionImpactShown => 'completion_impact_shown',
      ProductEvent.lifeMapOpened => 'life_map_opened',
    };
  }
}
