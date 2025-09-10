// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get todoList => 'Todo List';

  @override
  String get addANewTodo => 'Add a new Todo';

  @override
  String get todoTitle => 'Todo title';

  @override
  String get description => 'Description';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get editTodo => 'Edit Todo';

  @override
  String get noTodosYet => 'No todos yet! Add one with the button below.';

  @override
  String get markAsComplete => 'Mark as complete';

  @override
  String get markAsIncomplete => 'Mark as incomplete';
}
