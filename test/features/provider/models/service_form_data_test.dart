import 'package:festum/features/provider/models/service_form_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServiceFormData helpers', () {
    test('parses decimal input into cents', () {
      expect(ServiceFormData.parseCurrencyToCents('2500'), 250000);
      expect(ServiceFormData.parseCurrencyToCents('2500.50'), 250050);
      expect(ServiceFormData.parseCurrencyToCents('0'), 0);
    });

    test('parses image keys from comma and line breaks', () {
      expect(
        ServiceFormData.parseImageKeys('main.webp, side.webp\nextra.webp'),
        <String>['main.webp', 'side.webp', 'extra.webp'],
      );
    });
  });
}
