import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_plan.dart';

class WorkoutViewScreen extends StatefulWidget {
  const WorkoutViewScreen({super.key});

  @override
  State<WorkoutViewScreen> createState() => _WorkoutViewScreenState();
}

class _WorkoutViewScreenState extends State<WorkoutViewScreen> {
  WorkoutPlan? _plan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final String? planJson = prefs.getString('workout_plan');
    if (planJson != null) {
      setState(() {
        _plan = WorkoutPlan.fromMap(json.decode(planJson));
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Workout Plan"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plan == null
              ? _buildEmptyState()
              : _buildPlanList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "No workout plan created yet.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Go Back to Create"),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _plan!.dayWorkouts.length,
      itemBuilder: (context, index) {
        final dayWorkout = _plan!.dayWorkouts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                dayWorkout.day[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              dayWorkout.day,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              dayWorkout.muscleGroups.map((m) => m.name.toUpperCase()).join(" & "),
              style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          dayWorkout.isGymWorkout ? Icons.business : Icons.home,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dayWorkout.isGymWorkout ? "Gym / Machines" : "Home / Dumbbells",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      "Exercises:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dayWorkout.selectedExercises.length,
                      itemBuilder: (context, exIndex) {
                        final ex = dayWorkout.selectedExercises[exIndex];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.arrow_right, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(ex.name, style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
