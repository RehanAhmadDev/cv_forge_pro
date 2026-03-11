import 'package:flutter/material.dart';
import 'resume_form_screen.dart';

class TemplateSelectionScreen extends StatelessWidget {
  const TemplateSelectionScreen({super.key});

  final List<Map<String, dynamic>> templates = const [
    {'name': 'Classic', 'color': Colors.grey, 'type': 'simple'},
    {'name': 'Modern', 'color': Colors.blueGrey, 'type': 'header'},
    {'name': 'Professional', 'color': Colors.blue, 'type': 'sidebar'},
    {'name': 'Minimalist', 'color': Colors.white, 'type': 'centered'},
    {'name': 'Creative', 'color': Colors.orange, 'type': 'sidebar'},
    {'name': 'Executive', 'color': Colors.black87, 'type': 'header'},
  ];

  // ⬅️ ASAL JADOO: Ye function choti CV draw karega
  Widget _buildMiniLayout(String type, Color primaryColor) {
    if (type == 'header') {
      return Column(children: [
        Container(height: 30, color: primaryColor),
        const SizedBox(height: 10),
        Container(height: 6, width: 60, color: Colors.grey.shade400),
        const SizedBox(height: 10),
        Container(height: 4, width: 80, color: Colors.grey.shade300),
      ]);
    } else if (type == 'sidebar') {
      return Row(children: [
        Container(width: 35, color: primaryColor),
        Expanded(child: Padding(padding: const EdgeInsets.all(8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 6, width: 40, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Container(height: 4, width: double.infinity, color: Colors.grey.shade300),
        ]))),
      ]);
    } else if (type == 'centered') {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(height: 8, width: 60, color: Colors.grey.shade500),
        const SizedBox(height: 10),
        Container(height: 4, width: 30, color: Colors.grey.shade400),
        const SizedBox(height: 15),
        Container(height: 3, width: 80, color: Colors.grey.shade300),
      ]);
    } else {
      return Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 8, width: 50, color: Colors.grey.shade500),
        const SizedBox(height: 10),
        Container(height: 4, width: double.infinity, color: Colors.grey.shade300),
        const SizedBox(height: 10),
        Container(height: 4, width: 70, color: Colors.grey.shade300),
      ]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a CV Design', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade200, // Background thora dark kiya hai taake white page clear dikhay
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final t = templates[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResumeFormScreen(selectedTemplate: t['name']),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias, // Design ko card se bahar nikalne se rokta hai
              child: Column(
                children: [
                  // ⬅️ Mini CV Page
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Colors.white, // Page ka rang safaid
                      child: _buildMiniLayout(t['type'], t['color']),
                    ),
                  ),
                  Container(height: 1, color: Colors.grey.shade200),
                  // ⬅️ Design Ka Naam
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    color: Colors.white,
                    child: Text(
                      t['name'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey.shade900),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}