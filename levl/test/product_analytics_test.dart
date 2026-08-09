import 'package:flutter_test/flutter_test.dart';
import 'package:levl/core/analytics/product_analytics.dart';

void main() {
  test('analytics properties exclude structured and oversized values', () {
    final safe = ProductAnalytics.sanitizeProperties({
      'category': 'will',
      'proof added': true,
      'minutes': 25,
      'private_payload': {'goal': 'must not leave the device'},
      'long_value': 'x' * 120,
    });

    expect(safe['category'], 'will');
    expect(safe['proof_added'], true);
    expect(safe['minutes'], 25);
    expect(safe.containsKey('private_payload'), isFalse);
    expect((safe['long_value'] as String).length, 80);
  });
}
