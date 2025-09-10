import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_app/data/models/todo.dart';
import 'package:sqflite_app/data/services/todo_database.dart';
import 'package:sqflite_app/domain/intents/todo_intent.dart';
import 'package:sqflite_app/domain/state/todo_state.dart';

final todoDatabaseProvider = Provider<TodoDatabase>((ref) {
  return TodoDatabase();
});

final todoViewModelProvider = StateNotifierProvider<TodoViewModel, TodoState>((ref) {
  final db = ref.watch(todoDatabaseProvider);
  return TodoViewModel(db);
});

class TodoViewModel extends StateNotifier<TodoState> {
  final TodoDatabase _db;

  TodoViewModel(this._db) : super(TodoState(isLoading: true)) {
    _processIntent(LoadTodosIntent());
  }

  Future<void> _processIntent(TodoIntent intent) async {
    try {
      if (intent is LoadTodosIntent) {
        state = state.copyWith(isLoading: true);
        final todos = await _db.getTodos();
        state = state.copyWith(todos: todos, isLoading: false);
      } else if (intent is AddTodoIntent) {
        if (intent.title.isNotEmpty) {
          final newTodo = Todo(title: intent.title, description: intent.description);
          await _db.createTodo(newTodo);
          _refreshTodos();
        }
      } else if (intent is ToggleTodoIntent) {
        final updatedTodo = intent.todo.copyWith(isDone: !intent.todo.isDone);
        await _db.updateTodo(updatedTodo);
        _refreshTodos();
      } else if (intent is EditTodoIntent) {
        if (intent.newTitle.isNotEmpty) {
          final updatedTodo = intent.todo.copyWith(title: intent.newTitle, description: intent.newDescription);
          await _db.updateTodo(updatedTodo);
          _refreshTodos();
        }
      } else if (intent is DeleteTodoIntent) {
        await _db.deleteTodo(intent.id);
        _refreshTodos();
      }
    } catch (e) {
      state = state.copyWith(error: 'An error occurred.');
    }
  }

  Future<void> _refreshTodos() async {
    final todos = await _db.getTodos();
    state = state.copyWith(todos: todos);
  }

  void processIntent(TodoIntent intent) {
    _processIntent(intent);
  }
}