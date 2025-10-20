// Web用のデータベース初期化
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common/sqflite.dart';

void initializeDatabase() {
  // Web版ではIndexedDBベースのsqfliteを使用
  databaseFactory = databaseFactoryFfiWeb;
}
