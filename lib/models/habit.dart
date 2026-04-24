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
}
