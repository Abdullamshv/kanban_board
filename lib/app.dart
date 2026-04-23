import 'package:flutter/material.dart';
import 'features/board/presentation/ui/kanban_screen.dart';

class KanbanApp extends StatelessWidget {
  const KanbanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KPI Drive Kanban',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0079BF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0052CC), 
          foregroundColor: Colors.white,
        ),
      ),
      home: const KanbanScreen(),
    );
  }
}
