import 'dart:io';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'database.dart';

AppDatabase? _database;

Future<AppDatabase> getDatabase() async {
  if (_database is AppDatabase) return Future.value(_database);
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(path.join(dbFolder.path, 'doomsdayfound.sqlite'));
  _database = AppDatabase(NativeDatabase.createInBackground(file));
  return Future.value(_database);
}
