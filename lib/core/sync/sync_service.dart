import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:budget_mate/core/db/database.dart';

/// Service that syncs local Drift data to/from Firebase Firestore.
///
/// Write path: Local write → mark unsynced → if online, push to Firestore
/// Read path: On start/reconnect → fetch remote records newer than last sync → merge local
/// Conflict resolution: Last-write-wins based on updatedAt timestamp
class SyncService {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final String _userId;

  SyncService({
    required AppDatabase db,
    required FirebaseFirestore firestore,
    required String userId,
  })  : _db = db,
        _firestore = firestore,
        _userId = userId;

  /// Pushes all unsynced local records to Firestore.
  Future<void> pushUnsynced() async {
    await _pushBudgetPeriods();
    await _pushIncomeEntries();
    await _pushCategories();
    await _pushAllocations();
    await _pushTransactions();
  }

  Future<void> _pushBudgetPeriods() async {
    final unsynced = await (_db.select(_db.budgetPeriodsTable)
          ..where((t) => t.syncedAt.isNull()))
        .get();

    for (final record in unsynced) {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budgetPeriods')
          .doc(record.id)
          .set({
        'id': record.id,
        'userId': record.userId,
        'name': record.name,
        'startDate': record.startDate.toIso8601String(),
        'endDate': record.endDate.toIso8601String(),
        'createdAt': record.createdAt.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await (_db.update(_db.budgetPeriodsTable)
            ..where((t) => t.id.equals(record.id)))
          .write(BudgetPeriodsTableCompanion(
            syncedAt: Value(DateTime.now()),
          ));
    }
  }

  Future<void> _pushIncomeEntries() async {
    final unsynced = await (_db.select(_db.incomeEntriesTable)
          ..where((t) => t.syncedAt.isNull()))
        .get();

    for (final record in unsynced) {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('incomeEntries')
          .doc(record.id)
          .set({
        'id': record.id,
        'periodId': record.periodId,
        'userId': record.userId,
        'label': record.label,
        'amount': record.amount,
        'date': record.date.toIso8601String(),
        'createdAt': record.createdAt.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await (_db.update(_db.incomeEntriesTable)
            ..where((t) => t.id.equals(record.id)))
          .write(IncomeEntriesTableCompanion(
            syncedAt: Value(DateTime.now()),
          ));
    }
  }

  Future<void> _pushCategories() async {
    final unsynced = await (_db.select(_db.categoriesTable)
          ..where((t) => t.syncedAt.isNull()))
        .get();

    for (final record in unsynced) {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('categories')
          .doc(record.id)
          .set({
        'id': record.id,
        'periodId': record.periodId,
        'userId': record.userId,
        'name': record.name,
        'plannedAmount': record.plannedAmount,
        'createdAt': record.createdAt.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await (_db.update(_db.categoriesTable)
            ..where((t) => t.id.equals(record.id)))
          .write(CategoriesTableCompanion(
            syncedAt: Value(DateTime.now()),
          ));
    }
  }

  Future<void> _pushAllocations() async {
    final unsynced = await (_db.select(_db.allocationsTable)
          ..where((t) => t.syncedAt.isNull()))
        .get();

    for (final record in unsynced) {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('allocations')
          .doc(record.id)
          .set({
        'id': record.id,
        'categoryId': record.categoryId,
        'periodId': record.periodId,
        'userId': record.userId,
        'amount': record.amount,
        'createdAt': record.createdAt.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await (_db.update(_db.allocationsTable)
            ..where((t) => t.id.equals(record.id)))
          .write(AllocationsTableCompanion(
            syncedAt: Value(DateTime.now()),
          ));
    }
  }

  Future<void> _pushTransactions() async {
    final unsynced = await (_db.select(_db.transactionsTable)
          ..where((t) => t.syncedAt.isNull()))
        .get();

    for (final record in unsynced) {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc(record.id)
          .set({
        'id': record.id,
        'categoryId': record.categoryId,
        'periodId': record.periodId,
        'userId': record.userId,
        'amount': record.amount,
        'date': record.date.toIso8601String(),
        'note': record.note,
        'createdAt': record.createdAt.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await (_db.update(_db.transactionsTable)
            ..where((t) => t.id.equals(record.id)))
          .write(TransactionsTableCompanion(
            syncedAt: Value(DateTime.now()),
          ));
    }
  }
}