import 'package:dio/dio.dart';

class RemoveNullsInterceptor extends Interceptor {
  /// Better Auth expects JSON `null` for some organization bodies (clear active org/team).
  bool _preserveNullKeysForOrganizationBody(String urlPath) {
    return urlPath.contains('/organization/set-active-team') ||
        urlPath.endsWith('/organization/set-active');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final data = options.data;

    if (data != null &&
        !_preserveNullKeysForOrganizationBody(options.uri.path)) {
      if (_canCallToJson(data)) {
        final json = (data as dynamic).toJson();
        options.data = _removeNullsFromMap(json);
      } else if (data is Map<String, dynamic>) {
        options.data = _removeNullsFromMap(data);
      }
    }
    super.onRequest(options, handler);
  }

  Map<String, dynamic> _removeNullsFromMap(Map<String, dynamic> map) {
    return Map.fromEntries(
      map.entries
          .where((entry) {
            return entry.value != null;
          })
          .map((e) {
            if (_canCallToJson(e.value)) {
              return MapEntry(
                e.key,
                _removeNullsFromMap(e.value.toJson() as Map<String, dynamic>),
              );
            }
            if (e.value is Map) {
              return MapEntry(e.key, _removeNullsFromMap(e.value));
            }
            return e;
          }),
    );
  }

  bool _canCallToJson(Object? obj) {
    try {
      final result = (obj as dynamic).toJson();
      return result is Map<String, dynamic>;
    } catch (_) {
      return false;
    }
  }
}
