import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'database.dart';

AppDatabase? _database;

AppDatabase getDatabase() {
  _database ??= AppDatabase(_openConnection());
  return _database!;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'doomsdayfound.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
