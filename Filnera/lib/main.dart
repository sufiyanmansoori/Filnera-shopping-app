import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/profile_store.dart';
import 'core/services/session_service.dart';
import 'core/services/theme_service.dart';
import 'features/shop/shop_store.dart';
import 'features/notifications/data/notification_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProfileStore.initialize();
  await SessionService.bootstrap();
  await ShopStore.initialize();
  await NotificationStore.initialize();
  await ThemePreferenceService.bootstrap();
  runApp(const ManaraApp());
}
