import 'dart:io';

import 'package:flutter_better_auth/core/storage/storage.dart';

/// In-memory cookie persistence for tests (avoids Hive / path_provider).
class FakeCookieStorage implements StorageInterface {
  @override
  Future<List<Cookie>> loadCookies(String url) async => [];

  @override
  Future<void> saveCookies(String url, List<Cookie> cookies) async {}
}
