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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // ⬅️ NAYA JADOO: Jab bhi user Preview Tab par aayega, CV khud update ho jayegi
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

  // ⬅️ Update function ko thora behtar kiya hai
  Future<void> _updatePreview() async {
    final pdfBytes = await PdfGenerator.generateResume(_resumeData);
    _pdfController.loadDocument(PdfDocument.openData(pdfBytes));
  }

  // --- 1-CLICK SILENT PDF SAVE ---
  Future<void> _handleSave() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving PDF...')),
    );

    try {
      final pdfBytes = await PdfGenerator.generateResume(_resumeData);
      final fileName = '${_resumeData.fullName.isNotEmpty ? _resumeData.fullName.replaceAll(' ', '_') : 'My'}_Resume';

      final savedPath = await PdfGenerator.savePdfToDevice(
        bytes: pdfBytes,
        fileName: fileName,
      );

      if (savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Auto-Saved at:\n$savedPath'),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Permission Denied!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Error: $e");
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
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: "Edit Details"),
            Tab(icon: Icon(Icons.visibility), text: "Live Preview"),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // swipe karne par keyboard band karne ke liye
        physics: const BouncingScrollPhysics(),
        children: [
          // --- TAB 1: EDIT FORM ---
          Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 2) {
                setState(() => _currentStep += 1);
              } else {
                FocusScope.of(context).unfocus(); // Keyboard band
                _updatePreview(); // ⬅️ Preview tab par jane se pehle refresh
                _tabController.animateTo(1);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Form Complete! Check preview and Save.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) setState(() => _currentStep -= 1);
            },
            steps: _buildSteps(),
          ),

          // --- TAB 2: LIVE PREVIEW ---
          Column(
            children: [
              Expanded(
                child: PdfViewPinch(
                  controller: _pdfController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
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
        title: const Text('Personal'),
        isActive: _currentStep >= 0,
        content: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Full Name'),
              onChanged: (v) => _resumeData.fullName = v, // ⬅️ Fuzool update calls hata diye
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Job Title'),
              onChanged: (v) => _resumeData.jobTitle = v,
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Contact'),
        isActive: _currentStep >= 1,
        content: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (v) => _resumeData.email = v,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Phone'),
              onChanged: (v) => _resumeData.phone = v,
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Skills'),
        isActive: _currentStep >= 2,
        content: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Skills'),
              onChanged: (v) => _resumeData.skills = v,
            ),
            TextFormField(
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Summary'),
              onChanged: (v) => _resumeData.summary = v,
            ),
          ],
        ),
      ),
    ];
  }
}