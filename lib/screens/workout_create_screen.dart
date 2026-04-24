import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../models/workout_plan.dart';
import 'workout_view_screen.dart';

class WorkoutCreateScreen extends StatefulWidget {
  const WorkoutCreateScreen({super.key});

  @override
  State<WorkoutCreateScreen> createState() => _WorkoutCreateScreenState();
}

class _WorkoutCreateScreenState extends State<WorkoutCreateScreen> {
  final List<String> _allDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  final Set<String> _selectedDays = {};
  int _phase = 0;
  final Map<String, DayConfig> _dayConfigs = {};
  int _currentEditingDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_phase == 0 ? "Select Days" : "Plan Your Workout"),
        centerTitle: true,
      ),
      body: _phase == 0 ? _buildDaysSelection() : _buildDayConfiguration(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildDaysSelection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Which days do you want to workout?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _allDays.map((day) {
              bool isSelected = _selectedDays.contains(day);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDays.remove(day);
                      _dayConfigs.remove(day);
                    } else {
                      _selectedDays.add(day);
                      _dayConfigs[day] = DayConfig();
                    }
                  });
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day[0],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayConfiguration() {
    List<String> selectedList = _getSelectedDaysList();
    if (_currentEditingDayIndex >= selectedList.length) {
      return const Center(child: Text("Workout Creation Complete!"));
    }
    
    String day = selectedList[_currentEditingDayIndex];
    DayConfig config = _dayConfigs[day]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Configure $day",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          const Text("Muscle Group Count:", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              _buildChoiceChip("Single Muscle", config.isDoubleMuscle == false, () {
                setState(() {
                  config.isDoubleMuscle = false;
                  if (config.selectedMuscleGroups.isNotEmpty) {
                    config.selectedMuscleGroups = {config.selectedMuscleGroups.first};
                  }
                });
              }),
              const SizedBox(width: 12),
              _buildChoiceChip("Double Muscle", config.isDoubleMuscle == true, () {
                setState(() => config.isDoubleMuscle = true);
              }),
            ],
          ),
          const SizedBox(height: 24),

          const Text("Equipment Preference:", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              _buildChoiceChip("Home (Dumbbells)", config.equipment == Equipment.dumbbells, () {
                setState(() => config.equipment = Equipment.dumbbells);
              }),
              const SizedBox(width: 12),
              _buildChoiceChip("Gym (Machines)", config.equipment == Equipment.machines, () {
                setState(() => config.equipment = Equipment.machines);
              }),
            ],
          ),
          const SizedBox(height: 24),

          const Text("Select Muscle Group(s):", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: MuscleGroup.values.map((mg) {
              bool isSelected = config.selectedMuscleGroups.contains(mg);
              return FilterChip(
                label: Text(mg.name.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      if (config.isDoubleMuscle && config.selectedMuscleGroups.length < 2) {
                        config.selectedMuscleGroups.add(mg);
                      } else if (!config.isDoubleMuscle) {
                        config.selectedMuscleGroups.clear();
                        config.selectedMuscleGroups.add(mg);
                      }
                    } else {
                      config.selectedMuscleGroups.remove(mg);
                    }
                  });
                },
              );
            }).toList(),
          ),
          
          if (config.selectedMuscleGroups.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Text("Select Exercises:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildExerciseGrid(config),
          ]
        ],
      ),
    );
  }

  Widget _buildExerciseGrid(DayConfig config) {
    final filteredExercises = exerciseLibrary.where((ex) =>
        config.selectedMuscleGroups.contains(ex.muscleGroup) &&
        (ex.equipment == config.equipment || ex.equipment == Equipment.bodyweight)).toList();

    if (filteredExercises.isEmpty) {
      return const Text("No exercises found for these settings.", style: TextStyle(color: Colors.grey));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: filteredExercises.length,
      itemBuilder: (context, index) {
        final ex = filteredExercises[index];
        bool isSelected = config.selectedExercises.contains(ex);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                config.selectedExercises.remove(ex);
              } else {
                config.selectedExercises.add(ex);
              }
            });
          },
          child: Card(
            elevation: isSelected ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected ? BorderSide(color: Theme.of(context).primaryColor, width: 2) : BorderSide.none,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Icon(
                      _getExerciseIcon(ex.muscleGroup),
                      size: 40,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        ex.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getExerciseIcon(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest: return Icons.fitness_center;
      case MuscleGroup.back: return Icons.accessibility_new;
      case MuscleGroup.legs: return Icons.directions_run;
      case MuscleGroup.shoulders: return Icons.hdr_strong;
      case MuscleGroup.biceps: return Icons.handyman;
      case MuscleGroup.triceps: return Icons.hardware;
      case MuscleGroup.abs: return Icons.grid_view;
    }
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
    );
  }

  List<String> _getSelectedDaysList() {
    return _allDays.where((day) => _selectedDays.contains(day)).toList();
  }

  Widget _buildBottomBar() {
    bool canProceed = false;
    if (_phase == 0) {
      canProceed = _selectedDays.isNotEmpty;
    } else {
      List<String> selectedList = _getSelectedDaysList();
      String currentDay = selectedList[_currentEditingDayIndex];
      DayConfig config = _dayConfigs[currentDay]!;
      canProceed = config.selectedMuscleGroups.isNotEmpty && config.selectedExercises.isNotEmpty;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: canProceed ? _handleNext : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(_phase == 0 ? "Start Planning" : (_currentEditingDayIndex < _getSelectedDaysList().length - 1 ? "Next Day" : "Finish Workout Plan")),
      ),
    );
  }

  Future<void> _handleNext() async {
    if (_phase == 0) {
      setState(() {
        _phase = 1;
      });
    } else {
      if (_currentEditingDayIndex < _getSelectedDaysList().length - 1) {
        setState(() {
          _currentEditingDayIndex++;
        });
      } else {
        // Save Workout Plan
        await _saveWorkoutPlan();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WorkoutViewScreen()),
          );
        }
      }
    }
  }

  Future<void> _saveWorkoutPlan() async {
    final prefs = await SharedPreferences.getInstance();
    List<DayWorkout> dayWorkouts = [];
    
    for (String day in _getSelectedDaysList()) {
      DayConfig config = _dayConfigs[day]!;
      dayWorkouts.add(DayWorkout(
        day: day,
        muscleGroups: config.selectedMuscleGroups.toList(),
        selectedExercises: config.selectedExercises.toList(),
        isGymWorkout: config.equipment == Equipment.machines,
      ));
    }

    WorkoutPlan plan = WorkoutPlan(dayWorkouts: dayWorkouts);
    String planJson = json.encode(plan.toMap());
    await prefs.setString('workout_plan', planJson);
  }
}

class DayConfig {
  bool isDoubleMuscle = false;
  Equipment equipment = Equipment.dumbbells;
  Set<MuscleGroup> selectedMuscleGroups = {};
  Set<Exercise> selectedExercises = {};
}
