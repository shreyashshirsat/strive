import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_plan.dart';
import '../models/exercise.dart';
import 'workout_create_screen.dart';

class WorkoutViewScreen extends StatefulWidget {
  final WorkoutPlan? plan; // Optional: view a specific plan
  const WorkoutViewScreen({super.key, this.plan});

  @override
  State<WorkoutViewScreen> createState() => _WorkoutViewScreenState();
}

class _WorkoutViewScreenState extends State<WorkoutViewScreen> {
  List<WorkoutPlan> _allPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? plansJson = prefs.getStringList('workout_plans');
    if (plansJson != null) {
      setState(() {
        _allPlans = plansJson.map((s) => WorkoutPlan.fromMap(json.decode(s))).toList();
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Workout Plans"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allPlans.isEmpty
              ? _buildEmptyState()
              : _buildPlansList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No workout plans created yet.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPlansList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allPlans.length,
      itemBuilder: (context, index) {
        final plan = _allPlans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            title: Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text("${plan.dayWorkouts.length} Training Days"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WorkoutCreateScreen(existingPlan: plan)),
                    );
                    if (result == true) _loadPlans();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () => _deletePlan(plan),
                ),
              ],
            ),
            children: plan.dayWorkouts.map((dw) => _buildDayTile(dw)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDayTile(DayWorkout dw) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(dw.day, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        subtitle: Text(
          dw.muscleGroups.map((m) => m.name.toUpperCase()).join(" / "),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: dw.selectedExercises.map((pe) => _buildExerciseCard(pe)).toList(),
      ),
    );
  }

  Widget _buildExerciseCard(PlannedExercise pe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 120, // Rectangular horizontal card
        child: Row(
          children: [
            // Left Half: Illustration/GIF Placeholder
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey.shade100,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIcon(pe.exercise.muscleGroup),
                        size: 48,
                        color: Colors.blue.withOpacity(0.4),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "GIF Placeholder",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Right Half: Details
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pe.exercise.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pe.exercise.isTimed 
                          ? "${pe.minutes}m ${pe.seconds}s" 
                          : "${pe.sets} Sets x ${pe.reps} Reps",
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(MuscleGroup g) {
    switch(g) {
      case MuscleGroup.chest: return Icons.fitness_center;
      case MuscleGroup.back: return Icons.accessibility_new;
      case MuscleGroup.legs: return Icons.directions_run;
      case MuscleGroup.shoulders: return Icons.hdr_strong;
      case MuscleGroup.biceps: return Icons.handyman;
      case MuscleGroup.triceps: return Icons.hardware;
      case MuscleGroup.abs: return Icons.grid_view;
    }
  }

  Future<void> _deletePlan(WorkoutPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allPlans.removeWhere((p) => p.id == plan.id);
      prefs.setStringList('workout_plans', _allPlans.map((p) => json.encode(p.toMap())).toList());
    });
  }
}
