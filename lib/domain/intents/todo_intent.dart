import 'package:sqflite_app/data/models/todo.dart';

abstract class TodoIntent {}

class LoadTodosIntent extends TodoIntent {}
class AddTodoIntent extends TodoIntent {
  final String title;
  final String description;
  AddTodoIntent(this.title, this.description);
}
class ToggleTodoIntent extends TodoIntent {
  final Todo todo;
  ToggleTodoIntent(this.todo);
}
class EditTodoIntent extends TodoIntent {
  final Todo todo;
  final String newTitle;
  final String newDescription;
  EditTodoIntent(this.todo, this.newTitle, this.newDescription);
}
class DeleteTodoIntent extends TodoIntent {
  final int id;
  DeleteTodoIntent(this.id);
}
