import 'package:drift/drift.dart';

part 'database.g.dart';

class BalanceSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  RealColumn get totalBalance => real()();
  TextColumn get note => text().nullable()();
}

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get snapshotId =>
      integer().references(BalanceSnapshots, #id)();
  TextColumn get name => text()();
  RealColumn get balance => real()();
  IntColumn get type => integer()();
}

enum TransactionType {
  /// 收入
  income,
  /// 支出
  cost,
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get snapshotId =>
      integer().references(BalanceSnapshots, #id)();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  RealColumn get amount => real()();
  TextColumn get remark => text().nullable()();
  IntColumn get type => intEnum<TransactionType>()();
}

@DriftDatabase(tables: [BalanceSnapshots, Accounts, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
