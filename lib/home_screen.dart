import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString('todos');
    final String? lastResetDate = prefs.getString('last_todo_reset');
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    List<Todo> loadedTodos = [];
    if (todosJson != null) {
      final List<dynamic> decoded = json.decode(todosJson);
      loadedTodos = decoded.map((item) => Todo.fromMap(item)).toList();
    }

    if (lastResetDate != today) {
      for (var todo in loadedTodos) {
        if (todo.isDaily) {
          todo.isCompleted = false;
        }
      }
      await prefs.setString('last_todo_reset', today);
      final String encoded = json.encode(loadedTodos.map((todo) => todo.toMap()).toList());
      await prefs.setString('todos', encoded);
    }

    setState(() {
      _todos = loadedTodos;
    });
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_todos.map((todo) => todo.toMap()).toList());
    await prefs.setString('todos', encoded);
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
