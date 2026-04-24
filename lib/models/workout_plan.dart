import 'exercise.dart';

class DayWorkout {
  final String day;
  final List<MuscleGroup> muscleGroups;
  final List<PlannedExercise> selectedExercises;
  final bool isGymWorkout;

  DayWorkout({
    required this.day,
    required this.muscleGroups,
    required this.selectedExercises,
    required this.isGymWorkout,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'muscleGroups': muscleGroups.map((e) => e.index).toList(),
      'selectedExercises': selectedExercises.map((e) => e.toMap()).toList(),
      'isGymWorkout': isGymWorkout,
    };
  }

  factory DayWorkout.fromMap(Map<String, dynamic> map) {
    return DayWorkout(
      day: map['day'],
      muscleGroups: (map['muscleGroups'] as List).map((e) => MuscleGroup.values[e]).toList(),
      selectedExercises: (map['selectedExercises'] as List).map((e) => PlannedExercise.fromMap(e)).toList(),
      isGymWorkout: map['isGymWorkout'],
    );
  }
}

class WorkoutPlan {
  final String id;
  String name;
  final List<DayWorkout> dayWorkouts;

  WorkoutPlan({
    required this.id,
    required this.name,
    required this.dayWorkouts,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dayWorkouts': dayWorkouts.map((e) => e.toMap()).toList(),
    };
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    return WorkoutPlan(
      id: map['id'],
      name: map['name'] ?? 'Workout Plan',
      dayWorkouts: (map['dayWorkouts'] as List).map((e) => DayWorkout.fromMap(e)).toList(),
    );
  }
}
