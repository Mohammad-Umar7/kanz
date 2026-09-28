import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:kanz/core/data/db/database.dart';

/// A fresh in-memory database per test.
AppDatabase memoryDatabase() {
  // Several containers in one test isolate may each open a database.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}
