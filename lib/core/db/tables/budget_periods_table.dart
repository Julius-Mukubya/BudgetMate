import 'package:drift/drift.dart';

class BudgetPeriodsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn? get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}