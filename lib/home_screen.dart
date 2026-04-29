import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'models/todo.dart';
import 'screens/quotes_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/todo_screen.dart';
import 'screens/workout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todoBox = await Hive.openBox('todos');
    final settingsBox = await Hive.openBox('settings');
    
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String? lastResetDate = settingsBox.get('last_todo_reset');

    List<Todo> loadedTodos = [];
    final todoData = todoBox.get('list');
    
    if (todoData != null) {
      final List<dynamic> decoded = todoData is String ? json.decode(todoData) : todoData;
      loadedTodos = decoded.map((item) => Todo.fromMap(item as Map)).toList();
    }

    if (lastResetDate != today) {
      for (var todo in loadedTodos) {
        if (todo.isDaily) {
          todo.isCompleted = false;
        }
      }
      await settingsBox.put('last_todo_reset', today);
      await todoBox.put('list', loadedTodos.map((todo) => todo.toMap()).toList());
    }

    if (mounted) {
      setState(() {
        _todos = loadedTodos;
      });
    }
  }

  Future<void> _saveTodos() async {
    final todoBox = await Hive.openBox('todos');
    await todoBox.put('list', _todos.map((todo) => todo.toMap()).toList());
  }

  void _onTodosChanged() {
    _saveTodos();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const QuotesScreen(),
      const CalendarScreen(),
      TodoScreen(todos: _todos, onTodosChanged: _onTodosChanged),
      const WorkoutScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'Quotes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Todo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
        ],
      ),
    );
  }
}
