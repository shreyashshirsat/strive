import 'package:flutter/material.dart';
import '../models/habit.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final List<Habit> _habits = [
    Habit(id: '1', name: 'Drink 2L Water'),
  ];

  void _addHabit(String name) {
    setState(() {
      _habits.add(Habit(
        id: DateTime.now().toString(),
        name: name,
      ));
    });
  }

  void _editHabit(Habit habit, String newName) {
    setState(() {
      habit.name = newName;
    });
  }

  void _deleteHabit(String id) {
    setState(() {
      _habits.removeWhere((h) => h.id == id);
    });
  }

  void _showHabitDialog({Habit? habit}) {
    final TextEditingController controller = TextEditingController(text: habit?.name ?? "");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(habit == null ? "Add New Habit" : "Edit Habit"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter habit name"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                if (habit == null) {
                  _addHabit(controller.text);
                } else {
                  _editHabit(habit, controller.text);
                }
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Habits"),
        centerTitle: true,
      ),
      body: _habits.isEmpty
          ? const Center(child: Text("No habits yet. Add one to start tracking!"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(habit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showHabitDialog(habit: habit),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                          onPressed: () => _deleteHabit(habit.id),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabitDetailScreen(habit: habit),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHabitDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  DateTime _selectedDate = DateTime.now();

  String _getDateKey(int day) {
    return "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: "Select Month",
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final String monthName = DateFormat('MMMM yyyy').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Calendar Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => _selectDate(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                Text(
                                  monthName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          "${_calculateConsistency(daysInMonth)}% Consistency",
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: daysInMonth,
                      itemBuilder: (context, index) {
                        int day = index + 1;
                        String dateKey = _getDateKey(day);
                        int status = widget.habit.dayStatus[dateKey] ?? 0;

                        DateTime now = DateTime.now();
                        DateTime today = DateTime(now.year, now.month, now.day);
                        DateTime cellDate = DateTime(_selectedDate.year, _selectedDate.month, day);
                        bool isFuture = cellDate.isAfter(today);
                        
                        return GestureDetector(
                          onTap: isFuture ? null : () {
                            setState(() {
                              widget.habit.dayStatus[dateKey] = (status + 1) % 3;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isFuture ? Colors.grey.shade100 : _getStatusColor(status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "$day",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isFuture ? Colors.grey.shade400 : (status == 0 ? Colors.black : Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            const Text(
              "Statistics",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Stats Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem("Total Green", _getTotalDays(1, daysInMonth).toString(), Colors.green),
                        _buildStatItem("Total Red", _getTotalDays(2, daysInMonth).toString(), Colors.red),
                        _buildStatItem(
                          "Current Streak",
                          _calculateStreak() > 0 ? "${_calculateStreak()} Days" : "0",
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatItem(
                          "Best Streak",
                          _calculateBestStreak() > 0 ? "${_calculateBestStreak()} Days" : "0",
                          Colors.blueAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CustomPaint(
                            painter: PieChartPainter(
                              completed: _getTotalDays(1, daysInMonth),
                              missed: _getTotalDays(2, daysInMonth),
                              pending: daysInMonth - _getTotalDays(1, daysInMonth) - _getTotalDays(2, daysInMonth),
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem(Colors.green, "Completed"),
                              const SizedBox(height: 8),
                              _buildLegendItem(Colors.red, "Missed"),
                              const SizedBox(height: 8),
                              _buildLegendItem(Colors.grey.shade300, "Pending"),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(int status) {
    if (status == 1) return Colors.green;
    if (status == 2) return Colors.red;
    return Colors.grey.shade200;
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  int _getTotalDays(int status, int daysInMonth) {
    int count = 0;
    for (int i = 1; i <= daysInMonth; i++) {
      if (widget.habit.dayStatus[_getDateKey(i)] == status) {
        count++;
      }
    }
    return count;
  }

  int _calculateStreak() {
    int streak = 0;
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    String todayKey = DateFormat('yyyy-MM-dd').format(date);
    int todayStatus = widget.habit.dayStatus[todayKey] ?? 0;

    if (todayStatus == 2) return 0;

    DateTime checkDate = (todayStatus == 1) ? date : date.subtract(const Duration(days: 1));

    while (true) {
      String key = DateFormat('yyyy-MM-dd').format(checkDate);
      if (widget.habit.dayStatus[key] == 1) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int _calculateConsistency(int days) {
    int completed = _getTotalDays(1, days);
    return ((completed / days) * 100).toInt();
  }

  int _calculateBestStreak() {
    int maxStreak = 0;
    int currentTempStreak = 0;
    int daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;

    for (int i = 1; i <= daysInMonth; i++) {
      String key = _getDateKey(i);
      if (widget.habit.dayStatus[key] == 1) {
        currentTempStreak++;
        if (currentTempStreak > maxStreak) {
          maxStreak = currentTempStreak;
        }
      } else {
        currentTempStreak = 0;
      }
    }
    return maxStreak;
  }
}

class PieChartPainter extends CustomPainter {
  final int completed;
  final int missed;
  final int pending;

  PieChartPainter({required this.completed, required this.missed, required this.pending});

  @override
  void paint(Canvas canvas, Size size) {
    double total = (completed + missed + pending).toDouble();
    if (total == 0) return;

    double startAngle = -1.5708; // Start at top
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromLTRB(0, 0, size.width, size.height);

    // Completed (Green)
    double sweepAngle = (completed / total) * 6.28319;
    paint.color = Colors.green;
    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
    startAngle += sweepAngle;

    // Missed (Red)
    sweepAngle = (missed / total) * 6.28319;
    paint.color = Colors.red;
    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
    startAngle += sweepAngle;

    // Pending (Grey)
    sweepAngle = (pending / total) * 6.28319;
    paint.color = Colors.grey.shade300;
    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
