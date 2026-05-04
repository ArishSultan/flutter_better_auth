import 'package:flutter/widgets.dart';

import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_cookie_storage.dart';

void main() {
  group('FlutterBetterAuth singleton', () {
    test('BetterAuthClient instance is stable across lookups', () async {
      WidgetsFlutterBinding.ensureInitialized();
      await FlutterBetterAuth.initialize(
        url: 'http://10.2.2.0',
        store: FakeCookieStorage(),
      );
      final a = FlutterBetterAuth.client;
      final b = FlutterBetterAuth.client;
      expect(identical(a, b), isTrue);
    });
  });
}
