class Habit {
  String id;
  String name;
  // Key format: "YYYY-MM-DD"
  // Value: 0 = None, 1 = Completed, 2 = Missed
  Map<String, int> dayStatus;

  Habit({
    required this.id,
    required this.name,
    Map<String, int>? dayStatus,
  }) : dayStatus = dayStatus ?? {};

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dayStatus': dayStatus,
    };
  }

  factory Habit.fromMap(Map<dynamic, dynamic> map) {
    return Habit(
      id: map['id'].toString(),
      name: map['name'].toString(),
      dayStatus: Map<String, int>.from(map['dayStatus'] ?? {}),
    );
  }
}
