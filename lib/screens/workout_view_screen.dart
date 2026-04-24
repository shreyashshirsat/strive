import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_plan.dart';
import '../models/exercise.dart';
import 'workout_create_screen.dart';

class WorkoutViewScreen extends StatefulWidget {
  const WorkoutViewScreen({super.key});

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
        _allPlans = plansJson.map((s) => WorkoutPlan.fromMap(json.decode(s) as Map<String, dynamic>)).toList();
      });
    } else {
      setState(() {
        _allPlans = [];
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
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text("${plan.dayWorkouts.length} Training Days"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutPlanDetailsScreen(
                    plan: plan,
                    onUpdate: _loadPlans,
                  ),
                ),
              );
              _loadPlans();
            },
          ),
        );
      },
    );
  }
}

class WorkoutPlanDetailsScreen extends StatefulWidget {
  final WorkoutPlan plan;
  final VoidCallback onUpdate;

  const WorkoutPlanDetailsScreen({
    super.key,
    required this.plan,
    required this.onUpdate,
  });

  @override
  State<WorkoutPlanDetailsScreen> createState() => _WorkoutPlanDetailsScreenState();
}

class _WorkoutPlanDetailsScreenState extends State<WorkoutPlanDetailsScreen> {
  Future<void> _deletePlan(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> plansJson = prefs.getStringList('workout_plans') ?? [];
    plansJson.removeWhere((s) => WorkoutPlan.fromMap(json.decode(s) as Map<String, dynamic>).id == widget.plan.id);
    await prefs.setStringList('workout_plans', plansJson);
    widget.onUpdate();
    if (context.mounted) Navigator.pop(context);
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Plan?"),
        content: const Text(
          "Are you sure you want to delete this workout plan? You will lose all your progress and your previously well-created plan.",
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlan(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Yes, Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WorkoutCreateScreen(existingPlan: widget.plan)),
              );
              if (result == true) {
                widget.onUpdate();
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.plan.dayWorkouts.length,
        itemBuilder: (context, index) {
          final dw = widget.plan.dayWorkouts[index];
          return _buildDaySection(context, dw);
        },
      ),
    );
  }

  Widget _buildDaySection(BuildContext context, DayWorkout dw) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          _getFullDayName(dw.day),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
        ),
        subtitle: Text(
          dw.muscleGroups.map((m) => m.name.toUpperCase()).join(" / "),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        childrenPadding: const EdgeInsets.symmetric(vertical: 8),
        children: dw.selectedExercises.map((pe) => _buildExerciseCard(context, pe)).toList(),
      ),
    );
  }

  String _getFullDayName(String shortDay) {
    switch (shortDay) {
      case "Sun": return "Sunday";
      case "Mon": return "Monday";
      case "Tue": return "Tuesday";
      case "Wed": return "Wednesday";
      case "Thu": return "Thursday";
      case "Fri": return "Friday";
      case "Sat": return "Saturday";
      default: return shortDay;
    }
  }

  Widget _buildExerciseCard(BuildContext context, PlannedExercise pe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 120,
        child: Row(
          children: [
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
                        color: Colors.blue.withValues(alpha: 0.4),
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
}
