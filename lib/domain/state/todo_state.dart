import 'package:sqflite_app/data/models/todo.dart';

class TodoState {
  final List<Todo> todos;
  final bool isLoading;
  final String? error;

  TodoState({
    this.todos = const [],
    this.isLoading = false,
    this.error,
  });

  TodoState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    String? error,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}