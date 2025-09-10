import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The main entry point for the Flutter application.
void main() {
  runApp(
    // Riverpod's ProviderScope is required to use Riverpod.
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// A simple todo model class.
class Todo {
  final int? id;
  final String title;
  final bool isDone;

  Todo({
    this.id,
    required this.title,
    this.isDone = false,
  });

  // Method to convert a Todo object into a Map for database operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone ? 1 : 0, // SQLite stores booleans as integers (1 for true, 0 for false).
    };
  }

  // A factory constructor to create a Todo object from a Map.
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] == 1,
    );
  }

  // Method to create a new Todo instance with updated values.
  Todo copyWith({int? id, String? title, bool? isDone}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}

// Singleton class to manage the SQLite database operations.
class TodoDatabase {
  static final TodoDatabase _instance = TodoDatabase._internal();
  static Database? _database;

  // Private constructor to enforce the singleton pattern.
  TodoDatabase._internal();

  // Factory constructor to provide the single instance.
  factory TodoDatabase() {
    return _instance;
  }

  // A getter to get the database instance. If it doesn't exist, initialize it.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initializes the database.
  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = path.join(documentsDirectory.path, "todo_database.db");
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Create the 'todos' table with columns for id, title, and isDone.
        await db.execute(
          "CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, isDone INTEGER)",
        );
      },
    );
  }

  // Creates (inserts) a new todo into the database.
  Future<void> createTodo(Todo todo) async {
    final db = await database;
    await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieves all todos from the database.
  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  // Updates an existing todo in the database.
  Future<void> updateTodo(Todo todo) async {
    final db = await database;
    await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // Deletes a todo from the database.
  Future<void> deleteTodo(int id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// --- MVI ARCHITECTURE CLASSES ---

// Intent: Represents a user action.
abstract class TodoIntent {}

// Intents for various user actions.
class LoadTodosIntent extends TodoIntent {}
class AddTodoIntent extends TodoIntent {
  final String title;
  AddTodoIntent(this.title);
}
class ToggleTodoIntent extends TodoIntent {
  final Todo todo;
  ToggleTodoIntent(this.todo);
}
class EditTodoIntent extends TodoIntent {
  final Todo todo;
  final String newTitle;
  EditTodoIntent(this.todo, this.newTitle);
}
class DeleteTodoIntent extends TodoIntent {
  final int id;
  DeleteTodoIntent(this.id);
}

// State: Represents the UI state.
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

// Providers to manage state with Riverpod.
final todoDatabaseProvider = Provider<TodoDatabase>((ref) {
  return TodoDatabase();
});

final todoViewModelProvider = StateNotifierProvider<TodoViewModel, TodoState>((ref) {
  final db = ref.watch(todoDatabaseProvider);
  return TodoViewModel(db);
});

// ViewModel: Handles business logic and state management using Riverpod's StateNotifier.
class TodoViewModel extends StateNotifier<TodoState> {
  final TodoDatabase _db;

  TodoViewModel(this._db) : super(TodoState(isLoading: true)) {
    // Load initial todos when the ViewModel is created.
    _processIntent(LoadTodosIntent());
  }

  // Processes each intent and updates the state.
  Future<void> _processIntent(TodoIntent intent) async {
    try {
      if (intent is LoadTodosIntent) {
        state = state.copyWith(isLoading: true);
        final todos = await _db.getTodos();
        state = state.copyWith(todos: todos, isLoading: false);
      } else if (intent is AddTodoIntent) {
        if (intent.title.isNotEmpty) {
          final newTodo = Todo(title: intent.title);
          await _db.createTodo(newTodo);
          _refreshTodos();
        }
      } else if (intent is ToggleTodoIntent) {
        final updatedTodo = intent.todo.copyWith(isDone: !intent.todo.isDone);
        await _db.updateTodo(updatedTodo);
        _refreshTodos();
      } else if (intent is EditTodoIntent) {
        if (intent.newTitle.isNotEmpty) {
          final updatedTodo = intent.todo.copyWith(title: intent.newTitle);
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

  // Refreshes the list of todos and updates the state.
  Future<void> _refreshTodos() async {
    final todos = await _db.getTodos();
    state = state.copyWith(todos: todos);
  }

  // Public method to process intents.
  void processIntent(TodoIntent intent) {
    _processIntent(intent);
  }
}

// The main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // The screen will now access the ViewModel via Riverpod.
      home: const TodoListScreen(),
    );
  }
}

// The screen (View) that displays and manages the to-do list.
class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  // Shows an AlertDialog to add a new todo.
  Future<void> _showAddTodoDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController titleController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a new Todo'),
          content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Todo title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Read the ViewModel's notifier to process the intent.
                ref.read(todoViewModelProvider.notifier).processIntent(AddTodoIntent(titleController.text));
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Shows an AlertDialog to edit an existing todo.
  Future<void> _showEditTodoDialog(BuildContext context, WidgetRef ref, Todo todo) async {
    final TextEditingController titleController = TextEditingController(text: todo.title);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Todo title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Read the ViewModel's notifier to process the intent.
                ref.read(todoViewModelProvider.notifier).processIntent(EditTodoIntent(todo, titleController.text));
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the ViewModel's state to rebuild the UI when it changes.
    final state = ref.watch(todoViewModelProvider);
    final viewModel = ref.read(todoViewModelProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.todos.isEmpty
              ? const Center(child: Text('No todos yet! Add one with the button below.'))
              : ListView.builder(
                  itemCount: state.todos.length,
                  itemBuilder: (context, index) {
                    final todo = state.todos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: Checkbox(
                          value: todo.isDone,
                          onChanged: (bool? value) {
                            // Read the ViewModel's notifier to process the intent.
                            viewModel.processIntent(ToggleTodoIntent(todo));
                          },
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            decoration: todo.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditTodoDialog(context, ref, todo),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Read the ViewModel's notifier to process the intent.
                                viewModel.processIntent(DeleteTodoIntent(todo.id!));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
