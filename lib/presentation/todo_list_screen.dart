import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_app/data/models/todo.dart';
import 'package:sqflite_app/domain/intents/todo_intent.dart';
import 'package:sqflite_app/domain/view_models/todo_view_model.dart';
import 'package:sqflite_app/l10n/app_localizations.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  Future<void> _showAddTodoDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.addANewTodo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.todoTitle),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: l10n.description),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(todoViewModelProvider.notifier).processIntent(AddTodoIntent(
                  titleController.text,
                  descriptionController.text,
                  ));
                Navigator.of(context).pop();
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditTodoDialog(BuildContext context, WidgetRef ref, Todo todo) async {
    final TextEditingController titleController = TextEditingController(text: todo.title);
    final TextEditingController descriptionController = TextEditingController(text: todo.description); // New controller
    await showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.editTodo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.todoTitle),
              ),
              TextField( // New TextField for description
                controller: descriptionController,
                decoration: InputDecoration(labelText: l10n.description),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(todoViewModelProvider.notifier).processIntent(EditTodoIntent(
                  todo, 
                  titleController.text,
                  descriptionController.text,
                  ));
                Navigator.of(context).pop();
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todoViewModelProvider);
    final viewModel = ref.read(todoViewModelProvider.notifier);
    final l10n = AppLocalizations.of(context)!; // Get the localization object
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todoList), // Use localized string
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.todos.isEmpty
              ? Center(child: Text(l10n.noTodosYet)) // Use localized string
              : ListView.builder(
                  itemCount: state.todos.length,
                  itemBuilder: (context, index) {
                    final todo = state.todos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: Tooltip(
                          message: todo.isDone ? l10n.markAsIncomplete : l10n.markAsComplete, // Use localized strings
                          child: InkWell(
                            onTap: () {
                              viewModel.processIntent(ToggleTodoIntent(todo));
                            },
                            child: Icon(
                              todo.isDone ? Icons.check_circle : Icons.circle_outlined,
                              color: todo.isDone ? Colors.green : Colors.grey,
                            ),
                          ),
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            decoration: todo.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          todo.description,
                          style: TextStyle(
                            decoration: todo.isDone ? TextDecoration.lineThrough : null,
                            color: Colors.grey[600],
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
