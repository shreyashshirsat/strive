import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class TodoScreen extends StatefulWidget {
  final List<Todo> todos;
  final VoidCallback onTodosChanged;

  const TodoScreen({
    super.key,
    required this.todos,
    required this.onTodosChanged,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _taskController = TextEditingController();
  bool _isDailyTask = false;
  DateTime? _selectedReminder;

  void _saveTask(Todo? existingTodo) {
    if (_taskController.text.isNotEmpty) {
      Todo todoToSchedule;
      if (existingTodo != null) {
        // Update existing task
        existingTodo.title = _taskController.text;
        existingTodo.isDaily = _isDailyTask;
        existingTodo.reminderDateTime = _selectedReminder;
        todoToSchedule = existingTodo;
      } else {
        // Add new task
        todoToSchedule = Todo(
          id: DateTime.now().toString(),
          title: _taskController.text,
          isDaily: _isDailyTask,
          reminderDateTime: _selectedReminder,
        );
        widget.todos.add(todoToSchedule);
      }

      // Handle notification
      if (todoToSchedule.reminderDateTime != null) {
        NotificationService().scheduleTodoNotification(todoToSchedule);
      } else {
        NotificationService().cancelNotification(todoToSchedule.id);
      }

      _taskController.clear();
      _isDailyTask = false;
      _selectedReminder = null;
      widget.onTodosChanged();
      Navigator.pop(context);
    }
  }

  void _toggleTodo(Todo todo) {
    todo.isCompleted = !todo.isCompleted;
    if (todo.isCompleted) {
      NotificationService().cancelNotification(todo.id);
    } else if (todo.reminderDateTime != null) {
      NotificationService().scheduleTodoNotification(todo);
    }
    widget.onTodosChanged();
  }

  void _deleteTodo(Todo todo) {
    NotificationService().cancelNotification(todo.id);
    widget.todos.remove(todo);
    widget.onTodosChanged();
  }

  Future<void> _pickReminder(BuildContext context, StateSetter setModalState) async {
    if (_isDailyTask) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: _selectedReminder != null 
            ? TimeOfDay.fromDateTime(_selectedReminder!) 
            : TimeOfDay.now(),
      );
      if (time != null) {
        setModalState(() {
          final now = DateTime.now();
          _selectedReminder = DateTime(now.year, now.month, now.day, time.hour, time.minute);
        });
      }
    } else {
      final DateTime? date = await showDatePicker(
        context: context,
        initialDate: _selectedReminder ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow picking past for editing if needed, but usually now is better
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (date != null) {
        if (!context.mounted) return;
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: _selectedReminder != null 
              ? TimeOfDay.fromDateTime(_selectedReminder!) 
              : TimeOfDay.now(),
        );
        if (time != null) {
          setModalState(() {
            _selectedReminder = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          });
        }
      }
    }
  }

  void _showTaskDialog({Todo? todo}) {
    if (todo != null) {
      _taskController.text = todo.title;
      _isDailyTask = todo.isDaily;
      _selectedReminder = todo.reminderDateTime;
    } else {
      _taskController.clear();
      _isDailyTask = false;
      _selectedReminder = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                todo == null ? "Add New Task" : "Edit Task",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _taskController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "What needs to be done?",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text("Daily Task"),
                value: _isDailyTask,
                onChanged: (bool value) {
                  setModalState(() {
                    _isDailyTask = value;
                  });
                },
              ),
              ListTile(
                title: const Text("Reminder Time"),
                subtitle: Text(_selectedReminder == null
                    ? "No reminder set"
                    : _isDailyTask 
                        ? "Every day at ${DateFormat('hh:mm a').format(_selectedReminder!)}"
                        : DateFormat('MMM d, yyyy - hh:mm a').format(_selectedReminder!)),
                trailing: Icon(_isDailyTask ? Icons.access_time : Icons.calendar_month),
                onTap: () => _pickReminder(context, setModalState),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _saveTask(todo),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(todo == null ? "Add Task" : "Save Changes"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo List"),
        centerTitle: true,
      ),
      body: widget.todos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checklist_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    "No tasks yet. Enjoy your day!",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.todos.length,
              itemBuilder: (context, index) {
                final todo = widget.todos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (_) => _toggleTodo(todo),
                      activeColor: Colors.blue,
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        color: todo.isCompleted ? Colors.grey : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todo.isDaily)
                          Row(
                            children: [
                              Icon(Icons.repeat, size: 14, color: Colors.blue.withValues(alpha: 0.7)),
                              const SizedBox(width: 4),
                              Text("Daily", style: TextStyle(fontSize: 12, color: Colors.blue.withValues(alpha: 0.7))),
                            ],
                          ),
                        if (todo.reminderDateTime != null)
                          Row(
                            children: [
                              Icon(Icons.alarm, size: 14, color: Colors.orange.withValues(alpha: 0.7)),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d, hh:mm a').format(todo.reminderDateTime!),
                                style: TextStyle(fontSize: 12, color: Colors.orange.withValues(alpha: 0.7)),
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                          onPressed: () => _showTaskDialog(todo: todo),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _deleteTodo(todo),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
