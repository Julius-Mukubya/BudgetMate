import 'package:drift/drift.dart';

class AllocationsTable extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  TextColumn get periodId => text()();
  TextColumn get userId => text()();
  RealColumn get amount => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn? get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}