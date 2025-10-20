// デスクトッププラットフォーム用のデータベース初期化
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializeDatabase() {
  // Windows/Linux/macOS用のsqflite初期化
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
