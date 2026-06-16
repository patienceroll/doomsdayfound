import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doomsdayfound/database/database.dart';
import 'package:doomsdayfound/database/db_helper.dart';

class BalanceProviderValue {
  final BalanceSnapshot? balanceSnapshots;
  final bool hasAccounts;

  const BalanceProviderValue({
    required this.balanceSnapshots,
    required this.hasAccounts,
  });
}

final balanceProvider = FutureProvider<BalanceProviderValue>((ref) async {
  var hasAccounts = false;
  final db = await getDatabase();
  final balanceSnapshot =
      await (db.select(db.balanceSnapshots)
            ..orderBy([(t) => OrderingTerm.desc(t.id)])
            ..limit(1))
          .getSingleOrNull();

  if (balanceSnapshot != null) {
    final accounts =
        await (db.select(db.accounts)
              ..where((t) => t.snapshotId.equals(balanceSnapshot.id))
              ..limit(1))
            .get();
    hasAccounts = accounts.isNotEmpty;
  }

  return Future.value(
    BalanceProviderValue(
      balanceSnapshots: balanceSnapshot,
      hasAccounts: hasAccounts,
    ),
  );
});
