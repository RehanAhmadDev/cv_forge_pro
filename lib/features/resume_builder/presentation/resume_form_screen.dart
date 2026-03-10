import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../data/resume_model.dart';
import '../domain/pdf_generator.dart';

class ResumeFormScreen extends StatefulWidget {
  const ResumeFormScreen({super.key});

  @override
  State<ResumeFormScreen> createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  final ResumeModel _resumeData = ResumeModel();

  late PdfControllerPinch _pdfController;
  late TabController _tabController;

  // Template List
  final List<Map<String, dynamic>> templates = [
    {'name': 'Classic', 'color': Colors.grey.shade300, 'type': 'simple'},
    {'name': 'Modern', 'color': Colors.blueGrey.shade800, 'type': 'header'},
    {'name': 'Professional', 'color': Colors.blue.shade900, 'type': 'sidebar'},
    {'name': 'Minimalist', 'color': Colors.white, 'type': 'centered'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 1) {
        _updatePreview();
      }
    });

    _pdfController = PdfControllerPinch(
      document: PdfDocument.openData(PdfGenerator.generateResume(_resumeData)),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pdfController.dispose();
    super.dispose();
  }

  Future<void> _updatePreview() async {
    final pdfBytes = await PdfGenerator.generateResume(_resumeData);
    _pdfController.loadDocument(PdfDocument.openData(pdfBytes));
  }

  Future<void> _handleSave() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saving PDF...')));
    try {
      final pdfBytes = await PdfGenerator.generateResume(_resumeData);
      final fileName = '${_resumeData.fullName.isNotEmpty ? _resumeData.fullName.replaceAll(' ', '_') : 'My'}_Resume';
      final savedPath = await PdfGenerator.savePdfToDevice(bytes: pdfBytes, fileName: fileName);

      if (savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Auto-Saved at:\n$savedPath'), backgroundColor: Colors.green.shade700, duration: const Duration(seconds: 4)),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // --- MINI THUMBNAIL WIDGET ---
  Widget _buildTemplateThumbnail(Map<String, dynamic> template) {
    bool isSelected = _resumeData.selectedTemplate == template['name'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _resumeData.selectedTemplate = template['name']!;
        });
        _updatePreview();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 3 : 1),
          boxShadow: [
            if (isSelected) BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _buildMiniLayout(template['type'], template['color']),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(template['name']!, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12, color: isSelected ? Colors.blue : Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  // Thumbnail Layout Designs
  Widget _buildMiniLayout(String type, Color primaryColor) {
    if (type == 'header') {
      return Column(children: [
        Container(height: 20, color: primaryColor),
        const SizedBox(height: 5),
        Container(height: 4, width: 40, color: Colors.grey.shade400),
      ]);
    } else if (type == 'sidebar') {
      return Row(children: [
        Container(width: 25, color: primaryColor),
        Expanded(child: Padding(padding: const EdgeInsets.all(4.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 5, width: 30, color: Colors.grey.shade400),
          const SizedBox(height: 5),
          Container(height: 3, width: double.infinity, color: Colors.grey.shade300),
        ]))),
      ]);
    } else if (type == 'centered') {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(height: 5, width: 40, color: Colors.grey.shade500),
        const SizedBox(height: 5),
        Container(height: 3, width: 20, color: Colors.grey.shade400),
        const SizedBox(height: 10),
        Container(height: 2, width: 60, color: Colors.grey.shade300),
      ]);
    } else {
      return Padding(padding: const EdgeInsets.all(8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 6, width: 40, color: Colors.grey.shade500),
        const SizedBox(height: 5),
        Container(height: 3, width: double.infinity, color: Colors.grey.shade300),
        const SizedBox(height: 5),
        Container(height: 3, width: 50, color: Colors.grey.shade300),
      ]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Forge Pro', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(icon: Icon(Icons.edit), text: "Edit Details"), Tab(icon: Icon(Icons.visibility), text: "Live Preview")],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 2) {
                setState(() => _currentStep += 1);
              } else {
                FocusScope.of(context).unfocus();
                _updatePreview();
                _tabController.animateTo(1);
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) setState(() => _currentStep -= 1);
            },
            steps: _buildSteps(),
          ),
          Column(
            children: [
              Expanded(child: PdfViewPinch(controller: _pdfController)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade800, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                  icon: const Icon(Icons.download),
                  label: const Text("Save PDF"),
                  onPressed: _handleSave,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Template Selection'),
        isActive: _currentStep >= 0,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Swipe to choose a design:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            SizedBox(
              height: 140, // Horizontal carousel ki height
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  return _buildTemplateThumbnail(templates[index]);
                },
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(decoration: const InputDecoration(labelText: 'Full Name'), onChanged: (v) => _resumeData.fullName = v),
            TextFormField(decoration: const InputDecoration(labelText: 'Job Title'), onChanged: (v) => _resumeData.jobTitle = v),
          ],
        ),
      ),
      Step(
        title: const Text('Contact Details'),
        isActive: _currentStep >= 1,
        content: Column(
          children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Email'), onChanged: (v) => _resumeData.email = v),
            TextFormField(decoration: const InputDecoration(labelText: 'Phone'), onChanged: (v) => _resumeData.phone = v),
          ],
        ),
      ),
      Step(
        title: const Text('Skills & Summary'),
        isActive: _currentStep >= 2,
        content: Column(
          children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Skills'), onChanged: (v) => _resumeData.skills = v),
            TextFormField(maxLines: 2, decoration: const InputDecoration(labelText: 'Summary'), onChanged: (v) => _resumeData.summary = v),
          ],
        ),
      ),
    ];
  }
}