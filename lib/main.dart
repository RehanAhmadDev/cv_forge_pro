import 'package:flutter/material.dart';
// Nayi file import karein
import 'features/resume_builder/presentation/resume_form_screen.dart';

void main() {
  runApp(const ResumeBuilderApp());
}

class ResumeBuilderApp extends StatelessWidget {
  const ResumeBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV Forge Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
      ),
      // Yahan apna naya Stepper form laga dein
      home: const ResumeFormScreen(),
    );
  }
}