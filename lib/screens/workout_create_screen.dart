import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../models/workout_plan.dart';

class WorkoutCreateScreen extends StatefulWidget {
  final WorkoutPlan? existingPlan;
  const WorkoutCreateScreen({super.key, this.existingPlan});

  @override
  State<WorkoutCreateScreen> createState() => _WorkoutCreateScreenState();
}

class _WorkoutCreateScreenState extends State<WorkoutCreateScreen> {
  final List<String> _allDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  final Set<String> _selectedDays = {};
  int _phase = 0; // 0: Name/Days, 1: Details
  final Map<String, DayConfig> _dayConfigs = {};
  int _currentEditingDayIndex = 0;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initName();
    if (widget.existingPlan != null) {
      _nameController.text = widget.existingPlan!.name;
      for (var dw in widget.existingPlan!.dayWorkouts) {
        _selectedDays.add(dw.day);
        final config = DayConfig();
        config.isDoubleMuscle = dw.muscleGroups.length > 1;
        config.equipment = dw.isGymWorkout ? Equipment.machines : Equipment.dumbbells;
        config.selectedMuscleGroups = dw.muscleGroups.toSet();
        config.selectedExercises = dw.selectedExercises.toSet();
        _dayConfigs[dw.day] = config;
      }
    }
  }

  Future<void> _initName() async {
    if (widget.existingPlan == null) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedStrings = prefs.getStringList('workout_plans') ?? [];
      int count = savedStrings.length + 1;
      
      String defaultName = "Workout Plan $count";
      bool nameExists = savedStrings.any((s) => WorkoutPlan.fromMap(json.decode(s)).name == defaultName);
      
      while (nameExists) {
        count++;
        defaultName = "Workout Plan $count";
        nameExists = savedStrings.any((s) => WorkoutPlan.fromMap(json.decode(s)).name == defaultName);
      }
      
      setState(() {
        _nameController.text = defaultName;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_phase == 0 ? "Create Workout" : "Plan Details"),
        centerTitle: true,
      ),
      body: _phase == 0 ? _buildInitialSetup() : _buildDayConfiguration(),
      bottomNavigationBar: _buildNavigationButtons(),
    );
  }

  Widget _buildNavigationButtons() {
    bool canProceed = _phase == 0 ? _selectedDays.isNotEmpty : true;
    List<String> selectedList = _getSelectedDaysList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_phase == 1) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    if (_currentEditingDayIndex > 0) {
                      _currentEditingDayIndex--;
                    } else {
                      _phase = 0;
                    }
                  });
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_currentEditingDayIndex > 0 ? "Previous Day" : "Back"),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: canProceed
                  ? () {
                      setState(() {
                        if (_phase == 0) {
                          _phase = 1;
                        } else if (_currentEditingDayIndex < selectedList.length - 1) {
                          _currentEditingDayIndex++;
                        } else {
                          _savePlan();
                        }
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_phase == 0
                  ? "Next"
                  : (_currentEditingDayIndex < selectedList.length - 1 ? "Next Day" : "Save Plan")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialSetup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Plan Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: "e.g. Summer Shred",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
          const Text("Select Training Days", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
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
    String day = selectedList[_currentEditingDayIndex];
    String fullDayName = _getFullDayName(day);
    DayConfig config = _dayConfigs[day]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Configure $fullDayName", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text("Muscle Group Count:", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              ChoiceChip(
                label: const Text("Single"),
                selected: !config.isDoubleMuscle,
                onSelected: (_) => setState(() => config.isDoubleMuscle = false),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text("Double"),
                selected: config.isDoubleMuscle,
                onSelected: (_) => setState(() => config.isDoubleMuscle = true),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Equipment:", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              ChoiceChip(
                label: const Text("Dumbbells"),
                selected: config.equipment == Equipment.dumbbells,
                onSelected: (_) => setState(() => config.equipment = Equipment.dumbbells),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text("Machines"),
                selected: config.equipment == Equipment.machines,
                onSelected: (_) => setState(() => config.equipment = Equipment.machines),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Muscle Groups:", style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: MuscleGroup.values.map((mg) {
              return FilterChip(
                label: Text(mg.name.toUpperCase()),
                selected: config.selectedMuscleGroups.contains(mg),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      if (config.isDoubleMuscle && config.selectedMuscleGroups.length < 2) {
                        config.selectedMuscleGroups.add(mg);
                      } else if (!config.isDoubleMuscle) {
                        config.selectedMuscleGroups = {mg};
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
    final filtered = exerciseLibrary.where((ex) =>
        config.selectedMuscleGroups.contains(ex.muscleGroup) &&
        (ex.equipment == config.equipment || ex.equipment == Equipment.bodyweight)).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final ex = filtered[index];
        final plannedEx = config.getPlanned(ex);
        bool isSelected = plannedEx != null;
        
        return InkWell(
          onTap: () => _showExerciseDetailsDialog(ex, config),
          child: Card(
            elevation: isSelected ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected ? const BorderSide(color: Colors.blue, width: 2) : BorderSide.none,
            ),
            child: Column(
              children: [
                Expanded(child: Icon(_getIcon(ex.muscleGroup), size: 40, color: isSelected ? Colors.blue : Colors.grey)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(ex.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      if (isSelected) ...[
                        const SizedBox(height: 4),
                        Text(ex.isTimed ? "${plannedEx.minutes}m ${plannedEx.seconds}s" : "${plannedEx.sets} x ${plannedEx.reps}",
                            style: const TextStyle(fontSize: 11, color: Colors.blue)),
                      ]
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

  void _showExerciseDetailsDialog(Exercise ex, DayConfig config) {
    PlannedExercise? existing = config.getPlanned(ex);
    final setsController = TextEditingController(text: existing?.sets?.toString() ?? "3");
    final repsController = TextEditingController(text: existing?.reps?.toString() ?? "12");
    final minsController = TextEditingController(text: existing?.minutes?.toString() ?? "1");
    final secsController = TextEditingController(text: existing?.seconds?.toString() ?? "0");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ex.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ex.isTimed) ...[
              Row(children: [
                Expanded(child: TextField(controller: minsController, decoration: const InputDecoration(labelText: "Mins"), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: secsController, decoration: const InputDecoration(labelText: "Secs"), keyboardType: TextInputType.number)),
              ])
            ] else ...[
              Row(children: [
                Expanded(child: TextField(controller: setsController, decoration: const InputDecoration(labelText: "Sets"), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: repsController, decoration: const InputDecoration(labelText: "Reps"), keyboardType: TextInputType.number)),
              ])
            ]
          ],
        ),
        actions: [
          TextButton(onPressed: () {
            setState(() => config.selectedExercises.removeWhere((p) => p.exercise.name == ex.name));
            Navigator.pop(context);
          }, child: const Text("Remove", style: TextStyle(color: Colors.red))),
          ElevatedButton(onPressed: () {
            setState(() {
              config.selectedExercises.removeWhere((p) => p.exercise.name == ex.name);
              config.selectedExercises.add(PlannedExercise(
                exercise: ex,
                sets: int.tryParse(setsController.text),
                reps: int.tryParse(repsController.text),
                minutes: int.tryParse(minsController.text),
                seconds: int.tryParse(secsController.text),
              ));
            });
            Navigator.pop(context);
          }, child: const Text("Save")),
        ],
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

  List<String> _getSelectedDaysList() => _allDays.where((day) => _selectedDays.contains(day)).toList();


  Future<void> _savePlan() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedStrings = prefs.getStringList('workout_plans') ?? [];
    
    // Check for unique name
    bool nameExists = savedStrings.any((s) {
      final p = WorkoutPlan.fromMap(json.decode(s));
      return p.name.trim().toLowerCase() == _nameController.text.trim().toLowerCase() && 
             (widget.existingPlan == null || p.id != widget.existingPlan!.id);
    });

    if (nameExists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("A plan with this name already exists. Please choose a different name.")),
        );
      }
      return;
    }

    List<DayWorkout> dws = [];
    for (var day in _getSelectedDaysList()) {
      var config = _dayConfigs[day]!;
      dws.add(DayWorkout(
        day: day, 
        muscleGroups: config.selectedMuscleGroups.toList(), 
        selectedExercises: config.selectedExercises.toList(), 
        isGymWorkout: config.equipment == Equipment.machines
      ));
    }

    final plan = WorkoutPlan(
      id: widget.existingPlan?.id ?? DateTime.now().toString(), 
      name: _nameController.text, 
      dayWorkouts: dws
    );
    
    if (widget.existingPlan != null) {
      savedStrings.removeWhere((s) => WorkoutPlan.fromMap(json.decode(s)).id == widget.existingPlan!.id);
    }
    savedStrings.add(json.encode(plan.toMap()));
    await prefs.setStringList('workout_plans', savedStrings);
    if (mounted) Navigator.pop(context, true);
  }
}

class DayConfig {
  bool isDoubleMuscle = false;
  Equipment equipment = Equipment.dumbbells;
  Set<MuscleGroup> selectedMuscleGroups = {};
  Set<PlannedExercise> selectedExercises = {};
  PlannedExercise? getPlanned(Exercise ex) => selectedExercises.cast<PlannedExercise?>().firstWhere((p) => p?.exercise.name == ex.name, orElse: () => null);
}
