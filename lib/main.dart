import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Hive.initFlutter();
    
    // Open boxes sequentially to ensure they are ready
    await Hive.openBox('settings');
    await Hive.openBox('todos');
    await Hive.openBox('workout_plans');
    await Hive.openBox('habits');
  } catch (e) {
    debugPrint("Hive Initialization Error: $e");
  }

  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint("Notification Initialization Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Strive App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
