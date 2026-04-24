import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workout_create_screen.dart';
import 'workout_view_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int _planCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPlanCount();
  }

  Future<void> _loadPlanCount() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? plans = prefs.getStringList('workout_plans');
    setState(() {
      _planCount = plans?.length ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Builder"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOptionCard(
              context,
              title: "View My Plans",
              subtitle: _planCount == 0 
                  ? "You haven't created any plans yet" 
                  : "You have $_planCount active workout plans",
              icon: Icons.assignment_outlined,
              color: Colors.orange.shade700,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutViewScreen()),
                ).then((_) => _loadPlanCount());
              },
            ),
            const SizedBox(height: 24),
            _buildOptionCard(
              context,
              title: "Create New Plan",
              subtitle: "Build a custom routine with sets and reps",
              icon: Icons.add_circle_outline,
              color: Colors.blue.shade700,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutCreateScreen()),
                );
                if (result == true) _loadPlanCount();
              },
            ),
            const SizedBox(height: 24),
            _buildOptionCard(
              context,
              title: "Explore workouts",
              subtitle: "Browse pre-made workout routines",
              icon: Icons.explore_outlined,
              color: Colors.green.shade700,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Explore workouts coming soon!")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
