import 'dart:io';

import 'package:drift/drift.dart';
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

Future<void> saveBalanceSnapshot({
  required double totalBalance,
  List<({String name, double balance, int type})>? accounts,
}) async {
  final db = await getDatabase();
  final snapshotId = await db.into(db.balanceSnapshots).insert(
    BalanceSnapshotsCompanion.insert(totalBalance: totalBalance),
  );

  if (accounts != null && accounts.isNotEmpty) {
    for (final a in accounts) {
      await db.into(db.accounts).insert(
        AccountsCompanion.insert(
          snapshotId: snapshotId,
          name: a.name,
          balance: a.balance,
          type: a.type,
        ),
      );
    }
  }
}

Future<void> recordTransaction({
  required int snapshotId,
  required double newBalance,
  required double amount,
  required TransactionType type,
  String? remark,
}) async {
  final db = await getDatabase();

  await (db.update(db.balanceSnapshots)..where((t) => t.id.equals(snapshotId)))
      .write(BalanceSnapshotsCompanion(totalBalance: Value(newBalance)));

  await db.into(db.transactions).insert(
    TransactionsCompanion.insert(
      snapshotId: snapshotId,
      amount: amount,
      type: type,
      remark: remark != null ? Value<String?>(remark) : const Value.absent(),
    ),
  );
}
