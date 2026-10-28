import 'package:flutter_test/flutter_test.dart';
import 'package:filnera/features/auth/data/models/auth_response_model.dart';
import 'package:filnera/features/auth/presentation/auth_return_handler.dart';

void main() {
  group('AuthResponseModel', () {
    test('parses the backend session envelope', () {
      final session = AuthResponseModel.fromJson({
        'token': 'signed-token',
        'user': {
          'id': 'user-123',
          'email': 'shopper@example.com',
          'fullName': 'Shopper',
          'roles': ['customer'],
        },
      });

      expect(session.accessToken, 'signed-token');
      expect(session.userId, 'user-123');
      expect(session.email, 'shopper@example.com');
      expect(session.fullName, 'Shopper');
      expect(session.roles, ['customer']);
    });

    test('rejects a successful-looking response without a token', () {
      expect(
        () => AuthResponseModel.fromJson({
          'user': {'id': 'user-123'},
        }),
        throwsFormatException,
      );
    });
  });

  group('AuthReturnHandler.safeLocation', () {
    test('preserves an internal purchase intent', () {
      expect(
        AuthReturnHandler.safeLocation('/product/p-1?purchase=buy'),
        '/product/p-1?purchase=buy',
      );
    });

    test('rejects external and protocol-relative destinations', () {
      expect(AuthReturnHandler.safeLocation('https://example.com'), '/');
      expect(AuthReturnHandler.safeLocation('//example.com'), '/');
    });
  });
}
