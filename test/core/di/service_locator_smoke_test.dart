import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vestie/core/di/service_locator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServiceLocator', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('init registers core auth use cases without throwing', () async {
      final sl = ServiceLocator.instance;
      await sl.init();

      expect(sl.loginUseCase, isNotNull);
      expect(sl.getWalletUseCase, isNotNull);
      expect(sl.joinProjectUseCase, isNotNull);
      expect(sl.listMyVffsUseCase, isNotNull);
    });
  });
}
