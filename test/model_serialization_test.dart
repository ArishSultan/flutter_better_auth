import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_better_auth/core/api/default/sign_in/models/email/sign_in_email_response.dart';
import 'package:flutter_better_auth/core/api/models/result/better_error.dart';
import 'package:flutter_better_auth/core/api/models/result/result.dart';
import 'package:flutter_better_auth/core/api/models/result/result_extension.dart';
import 'package:flutter_better_auth/core/models/user/user.dart';
import 'package:flutter_better_auth/plugins/api_key/api_key_plugin.dart';
import 'package:flutter_better_auth/plugins/one_time_token/one_time_token_plugin.dart';
import 'package:flutter_better_auth/plugins/organization/organization_plugin.dart';
import 'package:flutter_better_auth/plugins/passkey/passkey_plugin.dart';
import 'package:flutter_better_auth/plugins/two_factor/two_factor_plugin.dart';

void main() {
  group('SignInEmailResponse', () {
    test('parses successful email sign-in payload', () {
      final parsed = SignInEmailResponse.fromJson(<String, dynamic>{
        'token': 'session-token',
        'user': <String, dynamic>{
          'id': 'user-1',
          'name': 'Test User',
          'email': 'a@b.c',
          'emailVerified': true,
        },
      });

      expect(parsed.twoFactorRedirect, isFalse);
      expect(parsed.token, 'session-token');
      expect(parsed.user?.id, 'user-1');
      expect(parsed.user?.email, 'a@b.c');
    });

    test('parses two-factor redirect without token or user', () {
      final parsed = SignInEmailResponse.fromJson(<String, dynamic>{
        'twoFactorRedirect': true,
        'twoFactorMethods': <String>['totp', 'otp'],
      });

      expect(parsed.twoFactorRedirect, isTrue);
      expect(parsed.twoFactorMethods, equals(<String>['totp', 'otp']));
      expect(parsed.token, isNull);
      expect(parsed.user, isNull);
    });
  });

  group('Result', () {
    test('exposes data on success branch', () {
      final r = Result<User>.ok(User(id: '1', name: 'n', email: 'e@e.e'));
      expect(r.data?.id, '1');
      expect(r.error, isNull);
    });

    test('exposes error on failure branch', () {
      final r = Result<User>.err(
        const BetterError(code: 'BAD_REQUEST', message: 'fail', stack: null),
      );
      expect(r.data, isNull);
      expect(r.error?.code, 'BAD_REQUEST');
      expect(r.error?.message, 'fail');
    });
  });

  group('Two-factor models', () {
    test('TwoFactorEnableResponse round-trips', () {
      const original = TwoFactorEnableResponse(
        totpURI: 'otpauth://totp/x',
        backupCodes: <String>['a-b-c-d-e', '1-2-3-4-5'],
      );
      final json = original.toJson();
      expect(TwoFactorEnableResponse.fromJson(json), equals(original));
    });

    test('TwoFactorTotpUriResponse round-trips', () {
      const original = TwoFactorTotpUriResponse(totpURI: 'otpauth://totp/app');
      final json = original.toJson();
      expect(TwoFactorTotpUriResponse.fromJson(json), equals(original));
    });

    test('TwoFactorBackupCodesResponse parses with codes', () {
      final parsed = TwoFactorBackupCodesResponse.fromJson(<String, dynamic>{
        'status': true,
        'backupCodes': <String>['xx-xx-xx-xx-xx'],
      });
      expect(parsed.status, isTrue);
      expect(parsed.backupCodes, equals(<String>['xx-xx-xx-xx-xx']));
    });

    test('TwoFactorBackupCodesResponse parses status only', () {
      final parsed = TwoFactorBackupCodesResponse.fromJson(<String, dynamic>{
        'status': true,
      });
      expect(parsed.status, isTrue);
      expect(parsed.backupCodes, isNull);
    });
  });

  group('API Key models', () {
    test('ApiKeyModel parses create response shape with plaintext key', () {
      final parsed = ApiKeyModel.fromJson(<String, dynamic>{
        'id': 'key_1',
        'configId': 'default',
        'name': 'CI',
        'start': 'ab_cdef',
        'prefix': 'ab_',
        'key': 'ab_plaintext-secret',
        'referenceId': 'user_1',
        'refillInterval': 3600000,
        'refillAmount': 10,
        'enabled': true,
        'rateLimitEnabled': true,
        'rateLimitTimeWindow': 86400000,
        'rateLimitMax': 10,
        'requestCount': 0,
        'remaining': 100,
        'createdAt': '2026-01-15T10:00:00.000Z',
        'updatedAt': '2026-01-15T10:00:00.000Z',
        'metadata': <String, dynamic>{'tier': 'pro'},
        'permissions': <String, dynamic>{
          'posts': <String>['read', 'write'],
        },
      });

      expect(parsed.key, 'ab_plaintext-secret');
      expect(parsed.metadata?['tier'], 'pro');
      expect(parsed.permissions?['posts'], equals(<dynamic>['read', 'write']));
    });

    test('VerifyApiKeyResponse parses invalid key envelope', () {
      final parsed = VerifyApiKeyResponse.fromJson(<String, dynamic>{
        'valid': false,
        'error': <String, dynamic>{
          'message': 'Invalid API key',
          'code': 'INVALID_API_KEY',
        },
        'key': null,
      });

      expect(parsed.valid, isFalse);
      expect(parsed.error?.code, 'INVALID_API_KEY');
      expect(parsed.error?.message, 'Invalid API key');
      expect(parsed.key, isNull);
    });

    test('VerifyApiKeyResponse parses valid envelope', () {
      final parsed = VerifyApiKeyResponse.fromJson(<String, dynamic>{
        'valid': true,
        'error': null,
        'key': <String, dynamic>{
          'id': 'kid',
          'configId': 'default',
          'referenceId': 'uid',
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-01T00:00:00.000Z',
        },
      });
      expect(parsed.valid, isTrue);
      expect(parsed.error, isNull);
      expect(parsed.key?.referenceId, 'uid');
    });

    test('ApiKeysListResponse parses', () {
      final parsed = ApiKeysListResponse.fromJson(<String, dynamic>{
        'apiKeys': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'k1',
            'configId': 'default',
            'referenceId': 'u1',
            'enabled': true,
            'rateLimitEnabled': true,
            'requestCount': 3,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          },
        ],
        'total': 1,
        'limit': 10,
        'offset': 0,
      });

      expect(parsed.apiKeys, hasLength(1));
      expect(parsed.apiKeys.single.id, 'k1');
      expect(parsed.total, 1);
      expect(parsed.limit, 10);
      expect(parsed.offset, 0);
    });

    test('DeleteExpiredApiKeysResponse parses success', () {
      final parsed = DeleteExpiredApiKeysResponse.fromJson(<String, dynamic>{
        'success': true,
        'error': null,
      });
      expect(parsed.success, isTrue);
      expect(parsed.error, isNull);
    });
  });

  group('One-time token models', () {
    test('OneTimeTokenGenerateResponse parses', () {
      final parsed = OneTimeTokenGenerateResponse.fromJson(<String, dynamic>{
        'token': 'ott-secret',
      });
      expect(parsed.token, 'ott-secret');
    });
  });

  group('Passkey models', () {
    test('PasskeyRecord parses list row shape', () {
      final parsed = PasskeyRecord.fromJson(<String, dynamic>{
        'id': 'pk-1',
        'userId': 'u1',
        'credentialID': 'cred',
        'publicKey': 'cHVi',
        'counter': 0,
        'deviceType': 'singleDevice',
        'backedUp': false,
        'name': 'Primary',
        'transports': 'usb,internal',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'aaguid': '00000000-0000-0000-0000-000000000000',
      });
      expect(parsed.id, 'pk-1');
      expect(parsed.counter, 0);
      expect(parsed.deviceType, 'singleDevice');
    });

    test('PasskeyUpdateResponse parses', () {
      final parsed = PasskeyUpdateResponse.fromJson(<String, dynamic>{
        'passkey': <String, dynamic>{
          'id': 'pk-1',
          'userId': 'u1',
          'credentialID': 'cred',
          'publicKey': 'cHVi',
          'counter': 1,
          'deviceType': 'singleDevice',
          'backedUp': true,
        },
      });
      expect(parsed.passkey.id, 'pk-1');
      expect(parsed.passkey.counter, 1);
    });
  });

  group('Organization models', () {
    test('OrganizationSlugCheckResponse parses check-slug success', () {
      final parsed = OrganizationSlugCheckResponse.fromJson(<String, dynamic>{
        'status': true,
      });
      expect(parsed.status, isTrue);
    });

    test('OrganizationPayload parses get-full-organization merged shape', () {
      final parsed = OrganizationPayload.fromJson(<String, dynamic>{
        'id': 'org-1',
        'name': 'Acme',
        'slug': 'acme',
        'members': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'mem-1',
            'organizationId': 'org-1',
            'userId': 'user-1',
            'role': 'owner',
          },
        ],
        'invitations': <dynamic>[],
      });
      expect(parsed.id, 'org-1');
      expect(parsed.members, hasLength(1));
      expect(parsed.members!.single.userId, 'user-1');
    });
  });
}
