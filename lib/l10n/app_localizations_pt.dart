// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get todoList => 'Lista de Tarefas';

  @override
  String get addANewTodo => 'Adicionar uma nova Tarefa';

  @override
  String get todoTitle => 'Título da tarefa';

  @override
  String get description => 'Descrição';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get editTodo => 'Editar tarefa';

  @override
  String get noTodosYet =>
      'Ainda não há tarefas! Adicione uma com o botão abaixo.';

  @override
  String get markAsComplete => 'Marcar como concluído';

  @override
  String get markAsIncomplete => 'Marcar como incompleto';
}
