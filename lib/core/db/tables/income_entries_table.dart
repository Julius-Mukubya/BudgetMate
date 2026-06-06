import 'package:drift/drift.dart';

class IncomeEntriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get periodId => text()();
  TextColumn get userId => text()();
  TextColumn get label => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn? get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}