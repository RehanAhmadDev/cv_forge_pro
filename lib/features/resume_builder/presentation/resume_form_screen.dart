import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:image_picker/image_picker.dart'; // ⬅️ Naya Package
import '../data/resume_model.dart';
import '../domain/pdf_generator.dart';

class ResumeFormScreen extends StatefulWidget {
  final String selectedTemplate;

  const ResumeFormScreen({super.key, required this.selectedTemplate});

  @override
  State<ResumeFormScreen> createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  final ResumeModel _resumeData = ResumeModel();

  late PdfControllerPinch _pdfController;
  late TabController _tabController;

  final ImagePicker _picker = ImagePicker(); // ⬅️ Image Picker Initialize kiya

  @override
  void initState() {
    super.initState();
    _resumeData.selectedTemplate = widget.selectedTemplate;

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

  // --- PROFILE PICTURE UPLOAD LOGIC ---
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _resumeData.imagePath = image.path;
      });
      _updatePreview(); // Tasweer lagte hi preview update hoga
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selectedTemplate} Design', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              if (_currentStep < 3) { // ⬅️ Ab 4 steps hain (0, 1, 2, 3)
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
        title: const Text('Profile & Picture'),
        isActive: _currentStep >= 0,
        content: Column(
          children: [
            // ⬅️ TASWEER LAGANE WALA UI
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueGrey.shade100,
                backgroundImage: _resumeData.imagePath != null ? FileImage(File(_resumeData.imagePath!)) : null,
                child: _resumeData.imagePath == null
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.blueGrey)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            const Text("Tap to add picture", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            TextFormField(decoration: const InputDecoration(labelText: 'Full Name'), onChanged: (v) => _resumeData.fullName = v),
            TextFormField(decoration: const InputDecoration(labelText: 'Job Title'), onChanged: (v) => _resumeData.jobTitle = v),
          ],
        ),
      ),
      Step(
        title: const Text('Contact & Links'),
        isActive: _currentStep >= 1,
        content: Column(
          children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Email'), onChanged: (v) => _resumeData.email = v),
            TextFormField(decoration: const InputDecoration(labelText: 'Phone'), onChanged: (v) => _resumeData.phone = v),
            TextFormField(decoration: const InputDecoration(labelText: 'LinkedIn Profile (Optional)'), onChanged: (v) => _resumeData.linkedin = v),
            TextFormField(decoration: const InputDecoration(labelText: 'GitHub Profile (Optional)'), onChanged: (v) => _resumeData.github = v),
          ],
        ),
      ),
      Step(
        title: const Text('Experience & Education'),
        isActive: _currentStep >= 2,
        content: Column(
          children: [
            TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Work Experience (Company, Role, Years)'),
                onChanged: (v) => _resumeData.experience = v
            ),
            const SizedBox(height: 10),
            TextFormField(
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Education (Degree, University, Year)'),
                onChanged: (v) => _resumeData.education = v
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Skills & Summary'),
        isActive: _currentStep >= 3,
        content: Column(
          children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Skills (comma separated)'), onChanged: (v) => _resumeData.skills = v),
            TextFormField(maxLines: 3, decoration: const InputDecoration(labelText: 'Professional Summary'), onChanged: (v) => _resumeData.summary = v),
          ],
        ),
      ),
    ];
  }
}