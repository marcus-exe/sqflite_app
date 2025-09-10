// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get todoList => 'Lista de Tareas';

  @override
  String get addANewTodo => 'Añadir una nueva tarea';

  @override
  String get todoTitle => 'Título de la tarea';

  @override
  String get description => 'Descripción';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get editTodo => 'Editar tarea';

  @override
  String get noTodosYet =>
      '¡Aún no hay tareas! Añade una con el botón de abajo.';

  @override
  String get markAsComplete => 'Marcar como completado';

  @override
  String get markAsIncomplete => 'Marcar como incompleto';
}
