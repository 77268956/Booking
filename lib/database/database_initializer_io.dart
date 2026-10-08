import 'dart:io' show Platform;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializeDatabase() {
  if (Platform.isAndroid || Platform.isIOS) return;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
