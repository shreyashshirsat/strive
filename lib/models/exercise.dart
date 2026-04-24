enum Equipment { dumbbells, machines, bodyweight }

enum MuscleGroup { chest, back, legs, shoulders, biceps, triceps, abs }

class Exercise {
  final String name;
  final MuscleGroup muscleGroup;
  final Equipment equipment;
  final String? imagePath; // Optional path for illustration

  const Exercise({
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'muscleGroup': muscleGroup.index,
      'equipment': equipment.index,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return exerciseLibrary.firstWhere(
      (e) => e.name == map['name'],
      orElse: () => Exercise(
        name: map['name'],
        muscleGroup: MuscleGroup.values[map['muscleGroup']],
        equipment: Equipment.values[map['equipment']],
      ),
    );
  }
}

// Initial data for exercises
const List<Exercise> exerciseLibrary = [
  // Chest
  Exercise(name: 'Dumbbell Press', muscleGroup: MuscleGroup.chest, equipment: Equipment.dumbbells),
  Exercise(name: 'Dumbbell Flys', muscleGroup: MuscleGroup.chest, equipment: Equipment.dumbbells),
  Exercise(name: 'Push-ups', muscleGroup: MuscleGroup.chest, equipment: Equipment.bodyweight),
  Exercise(name: 'Bench Press', muscleGroup: MuscleGroup.chest, equipment: Equipment.machines),
  Exercise(name: 'Chest Press Machine', muscleGroup: MuscleGroup.chest, equipment: Equipment.machines),
  Exercise(name: 'Pec Deck', muscleGroup: MuscleGroup.chest, equipment: Equipment.machines),

  // Back
  Exercise(name: 'Dumbbell Rows', muscleGroup: MuscleGroup.back, equipment: Equipment.dumbbells),
  Exercise(name: 'One-arm DB Row', muscleGroup: MuscleGroup.back, equipment: Equipment.dumbbells),
  Exercise(name: 'Pull-ups', muscleGroup: MuscleGroup.back, equipment: Equipment.bodyweight),
  Exercise(name: 'Lat Pulldown', muscleGroup: MuscleGroup.back, equipment: Equipment.machines),
  Exercise(name: 'Seated Cable Row', muscleGroup: MuscleGroup.back, equipment: Equipment.machines),

  // Legs
  Exercise(name: 'Dumbbell Squats', muscleGroup: MuscleGroup.legs, equipment: Equipment.dumbbells),
  Exercise(name: 'Goblet Squats', muscleGroup: MuscleGroup.legs, equipment: Equipment.dumbbells),
  Exercise(name: 'Lunges', muscleGroup: MuscleGroup.legs, equipment: Equipment.dumbbells),
  Exercise(name: 'Leg Press', muscleGroup: MuscleGroup.legs, equipment: Equipment.machines),
  Exercise(name: 'Leg Extension', muscleGroup: MuscleGroup.legs, equipment: Equipment.machines),
  Exercise(name: 'Leg Curl', muscleGroup: MuscleGroup.legs, equipment: Equipment.machines),

  // Shoulders
  Exercise(name: 'DB Shoulder Press', muscleGroup: MuscleGroup.shoulders, equipment: Equipment.dumbbells),
  Exercise(name: 'Lateral Raises', muscleGroup: MuscleGroup.shoulders, equipment: Equipment.dumbbells),
  Exercise(name: 'Front Raises', muscleGroup: MuscleGroup.shoulders, equipment: Equipment.dumbbells),
  Exercise(name: 'Shoulder Press Machine', muscleGroup: MuscleGroup.shoulders, equipment: Equipment.machines),

  // Biceps
  Exercise(name: 'Dumbbell Curls', muscleGroup: MuscleGroup.biceps, equipment: Equipment.dumbbells),
  Exercise(name: 'Hammer Curls', muscleGroup: MuscleGroup.biceps, equipment: Equipment.dumbbells),
  Exercise(name: 'Preacher Curl Machine', muscleGroup: MuscleGroup.biceps, equipment: Equipment.machines),

  // Triceps
  Exercise(name: 'Tricep Kickbacks', muscleGroup: MuscleGroup.triceps, equipment: Equipment.dumbbells),
  Exercise(name: 'Overhead Extension', muscleGroup: MuscleGroup.triceps, equipment: Equipment.dumbbells),
  Exercise(name: 'Dips', muscleGroup: MuscleGroup.triceps, equipment: Equipment.bodyweight),
  Exercise(name: 'Tricep Pushdown', muscleGroup: MuscleGroup.triceps, equipment: Equipment.machines),

  // Abs
  Exercise(name: 'Plank', muscleGroup: MuscleGroup.abs, equipment: Equipment.bodyweight),
  Exercise(name: 'Crunches', muscleGroup: MuscleGroup.abs, equipment: Equipment.bodyweight),
  Exercise(name: 'Leg Raises', muscleGroup: MuscleGroup.abs, equipment: Equipment.bodyweight),
];
