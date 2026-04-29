class Todo {
  String id;
  String title;
  bool isCompleted;
  bool isDaily;
  DateTime? reminderDateTime;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.isDaily = false,
    this.reminderDateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'isDaily': isDaily,
      'reminderDateTime': reminderDateTime?.toIso8601String(),
    };
  }

  factory Todo.fromMap(Map<dynamic, dynamic> map) {
    return Todo(
      id: map['id'].toString(),
      title: map['title'].toString(),
      isCompleted: map['isCompleted'] ?? false,
      isDaily: map['isDaily'] ?? false,
      reminderDateTime: map['reminderDateTime'] != null 
          ? DateTime.parse(map['reminderDateTime'].toString())
          : null,
    );
  }
}
