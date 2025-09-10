import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_app/data/models/todo.dart';
import 'package:sqflite_app/domain/intents/todo_intent.dart';
import 'package:sqflite_app/domain/view_models/todo_view_model.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

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
