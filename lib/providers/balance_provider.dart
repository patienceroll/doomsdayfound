import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doomsdayfound/database/database.dart';
import 'package:doomsdayfound/database/db_helper.dart';

final balanceProvider = FutureProvider<BalanceSnapshot?>((ref) async {
  final db = await getDatabase();
  return (db.select(db.balanceSnapshots)
        ..orderBy([(t) => OrderingTerm.desc(t.id)])
        ..limit(1))
      .getSingleOrNull();
});
