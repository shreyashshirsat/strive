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
  bool _hasPlan = false;

  @override
  void initState() {
    super.initState();
    _checkPlan();
  }

  Future<void> _checkPlan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasPlan = prefs.containsKey('workout_plan');
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
            if (_hasPlan) ...[
              _buildOptionCard(
                context,
                title: "View My Plan",
                subtitle: "Check your current workout routine",
                icon: Icons.assignment_outlined,
                color: Colors.orange.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WorkoutViewScreen()),
                  ).then((_) => _checkPlan());
                },
              ),
              const SizedBox(height: 24),
            ],
            _buildOptionCard(
              context,
              title: _hasPlan ? "Re-create Plan" : "Create your workout",
              subtitle: _hasPlan 
                ? "Start over with a new routine" 
                : "Build a custom plan tailored to your goals",
              icon: Icons.add_circle_outline,
              color: Colors.blue.shade700,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutCreateScreen()),
                ).then((_) => _checkPlan());
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
            if (!_hasPlan) ...[
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  "You haven't created a workout plan yet.",
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            ],
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
